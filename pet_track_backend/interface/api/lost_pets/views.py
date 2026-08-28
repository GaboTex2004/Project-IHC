from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from drf_spectacular.utils import extend_schema
from drf_spectacular.openapi import OpenApiTypes
from interface.api.lost_pets.serializers import CreateReportInputSerializer, ReportResponseSerializer
from application.lost_pets.services import CreateReportService, ListReportsService, DeleteReportService
from application.lost_pets.dtos import CreateReportDTO
from infrastructure.db.lost_pet_repository import DjangoLostPetReportRepository
from domain.lost_pets.exceptions import ReportNotFoundException, UnauthorizedReportAccessException


class CreateReportView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        summary='Crear reporte de mascota perdida',
        description='Crea un nuevo reporte de mascota perdida. Envía photo como archivo.',
        request={
            'multipart/form-data': {
                'type': 'object',
                'properties': {
                    'name': {'type': 'string'},
                    'photo': {'type': 'string', 'format': 'binary'},
                    'characteristics': {'type': 'string'},
                    'last_location': {'type': 'string'},
                    'date_lost': {'type': 'string', 'format': 'date'},
                    'contact_info': {'type': 'string'},
                },
                'required': ['name', 'photo', 'characteristics', 'last_location', 'date_lost', 'contact_info'],
            }
        },
        responses={201: ReportResponseSerializer, 400: OpenApiTypes.OBJECT},
    )
    def post(self, request):
        serializer = CreateReportInputSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        photo_file = request.FILES.get('photo')
        if not photo_file:
            return Response({'error': 'Se requiere una imagen'}, status=status.HTTP_400_BAD_REQUEST)

        dto = CreateReportDTO(
            name=serializer.validated_data['name'],
            photo=photo_file,
            characteristics=serializer.validated_data['characteristics'],
            last_location=serializer.validated_data['last_location'],
            date_lost=str(serializer.validated_data['date_lost']),
            contact_info=serializer.validated_data['contact_info'],
        )

        service = CreateReportService(report_repository=DjangoLostPetReportRepository())
        result = service.execute(user_id=request.user.id, dto=dto)

        response_serializer = ReportResponseSerializer(result)
        return Response(response_serializer.data, status=status.HTTP_201_CREATED)


class ListReportsView(APIView):
    @extend_schema(
        summary='Listar reportes de mascotas perdidas',
        description='Obtiene una lista de reportes de mascotas perdidas',
        responses={200: ReportResponseSerializer(many=True)},
    )
    def get(self, request):
        service = ListReportsService(report_repository=DjangoLostPetReportRepository())

        user_id = request.query_params.get('user_id')
        if user_id:
            results = service.execute(user_id=int(user_id))
        else:
            results = service.execute()

        response_serializer = ReportResponseSerializer(results, many=True)
        return Response(response_serializer.data, status=status.HTTP_200_OK)


class DeleteReportView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        summary='Eliminar reporte',
        description='Elimina un reporte de mascota perdida',
        responses={204: None},
    )
    def delete(self, request, report_id):
        service = DeleteReportService(report_repository=DjangoLostPetReportRepository())

        try:
            service.execute(user_id=request.user.id, report_id=report_id)
        except ReportNotFoundException as e:
            return Response({'error': str(e)}, status=status.HTTP_404_NOT_FOUND)
        except UnauthorizedReportAccessException as e:
            return Response({'error': str(e)}, status=status.HTTP_403_FORBIDDEN)

        return Response(status=status.HTTP_204_NO_CONTENT)
