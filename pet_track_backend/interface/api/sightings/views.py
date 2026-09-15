from rest_framework import status
from rest_framework.parsers import FormParser, JSONParser, MultiPartParser
from rest_framework.permissions import IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from application.sightings.services import (
    CreateSightingService, GetSightingService, ListReportSightingsService,
)
from domain.lost_pets.exceptions import ReportNotFoundException
from domain.sightings.exceptions import (
    SightingAccessDeniedException, SightingNotAllowedException,
    SightingNotFoundException,
)
from infrastructure.db.lost_pet_repository import DjangoLostPetReportRepository
from infrastructure.db.sighting_repository import DjangoSightingRepository
from interface.api.sightings.serializers import (
    CreateSightingInputSerializer, SightingResponseSerializer,
)


class SightingsView(APIView):
    permission_classes = [IsAuthenticated]
    parser_classes = [MultiPartParser, FormParser, JSONParser]

    def post(self, request):
        serializer = CreateSightingInputSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        data = serializer.validated_data
        service = CreateSightingService(
            DjangoLostPetReportRepository(), DjangoSightingRepository(),
        )
        try:
            sighting = service.execute(
                report_id=data['report_id'], reporter_id=request.user.id,
                latitude=data['latitude'], longitude=data['longitude'],
                location_description=data['location_description'],
                sighting_datetime=data['sighting_datetime'],
                description=data['description'], photo=data.get('photo'),
            )
        except ReportNotFoundException as error:
            return Response({'error': str(error)}, status=status.HTTP_404_NOT_FOUND)
        except SightingNotAllowedException as error:
            return Response({'error': str(error)}, status=status.HTTP_400_BAD_REQUEST)
        return Response(SightingResponseSerializer(sighting).data, status=status.HTTP_201_CREATED)


class SightingDetailView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, sighting_id):
        try:
            sighting = GetSightingService(DjangoSightingRepository()).execute(
                sighting_id, request.user.id,
            )
        except SightingNotFoundException as error:
            return Response({'error': str(error)}, status=status.HTTP_404_NOT_FOUND)
        except SightingAccessDeniedException as error:
            return Response({'error': str(error)}, status=status.HTTP_403_FORBIDDEN)
        return Response(SightingResponseSerializer(sighting).data)


class ReportSightingsView(APIView):
    permission_classes = [IsAuthenticated]

    def get(self, request, report_id):
        try:
            sightings = ListReportSightingsService(
                DjangoLostPetReportRepository(), DjangoSightingRepository(),
            ).execute(report_id, request.user.id)
        except ReportNotFoundException as error:
            return Response({'error': str(error)}, status=status.HTTP_404_NOT_FOUND)
        except SightingAccessDeniedException as error:
            return Response({'error': str(error)}, status=status.HTTP_403_FORBIDDEN)
        return Response(SightingResponseSerializer(sightings, many=True).data)
