from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import AllowAny, IsAuthenticated
from drf_spectacular.utils import extend_schema
from drf_spectacular.openapi import OpenApiTypes
from interface.api.lost_pets.serializers import (
    CreateReportInputSerializer,
    ReportResponseSerializer,
    UpdateReportStatusInputSerializer,
)
from application.lost_pets.services import (
    CreateReportService,
    DeleteReportService,
    GetReportDetailService,
    ListMyReportsService,
    ListReportsService,
    UpdateReportStatusService,
)
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
                    'report_type': {
                        'type': 'string',
                        'enum': ['LOST', 'FOUND', 'HOMELESS'],
                    },
                },
                'required': ['photo', 'characteristics', 'last_location', 'date_lost', 'contact_info'],
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
            report_type=serializer.validated_data['report_type'],
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

        exclude_user_id = request.user.id if request.user.is_authenticated else None
        results = service.execute(exclude_user_id=exclude_user_id)

        response_serializer = ReportResponseSerializer(results, many=True)
        return Response(response_serializer.data, status=status.HTTP_200_OK)


class ListMyReportsView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        summary='Listar mis reportes',
        description='Obtiene únicamente los reportes del usuario autenticado',
        responses={200: ReportResponseSerializer(many=True)},
    )
    def get(self, request):
        service = ListMyReportsService(
            report_repository=DjangoLostPetReportRepository()
        )
        results = service.execute(user_id=request.user.id)
        response_serializer = ReportResponseSerializer(results, many=True)
        return Response(response_serializer.data, status=status.HTTP_200_OK)


class ReportDetailView(APIView):
    def get_permissions(self):
        if self.request.method == 'GET':
            return [AllowAny()]
        return [IsAuthenticated()]

    @extend_schema(
        summary='Obtener detalle de reporte',
        description='Obtiene un reporte de mascota perdida por su ID',
        responses={
            200: ReportResponseSerializer,
            404: OpenApiTypes.OBJECT,
        },
    )
    def get(self, request, report_id):
        service = GetReportDetailService(
            report_repository=DjangoLostPetReportRepository()
        )

        try:
            result = service.execute(report_id=report_id)
        except ReportNotFoundException as e:
            return Response({'error': str(e)}, status=status.HTTP_404_NOT_FOUND)

        response_serializer = ReportResponseSerializer(result)
        return Response(response_serializer.data, status=status.HTTP_200_OK)

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


class ReportStatusView(APIView):
    permission_classes = [IsAuthenticated]

    @extend_schema(
        summary='Actualizar estado de reporte',
        request=UpdateReportStatusInputSerializer,
        responses={
            200: ReportResponseSerializer,
            400: OpenApiTypes.OBJECT,
            403: OpenApiTypes.OBJECT,
            404: OpenApiTypes.OBJECT,
        },
    )
    def patch(self, request, report_id):
        serializer = UpdateReportStatusInputSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        service = UpdateReportStatusService(
            report_repository=DjangoLostPetReportRepository()
        )

        try:
            result = service.execute(
                user_id=request.user.id,
                report_id=report_id,
                report_status=serializer.validated_data['status'],
            )
        except ReportNotFoundException as e:
            return Response({'error': str(e)}, status=status.HTTP_404_NOT_FOUND)
        except UnauthorizedReportAccessException as e:
            return Response({'error': str(e)}, status=status.HTTP_403_FORBIDDEN)

        response_serializer = ReportResponseSerializer(result)
        return Response(response_serializer.data, status=status.HTTP_200_OK)
