
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

from application.matching.services import (
    AnalysisPermissionError,
    AnalysisReportNotFoundError,
    AnalysisValidationError,
    AnalyzeReportVisualFeaturesService,
    ValidateReportForAnalysisService,
)
from application.matching.image_processing import InvalidReportImageError

from infrastructure.ai.pet_visual_analyzer import GeminiAnalysisError

from infrastructure.ai.gemini_client import GeminiConfigurationError

from infrastructure.db.visual_features_repository import (
    StaleReportAnalysisError,
)


class AnalyzeReportView(APIView):
    permission_classes = [IsAuthenticated]
    def get_analysis_service(self):
        return AnalyzeReportVisualFeaturesService()

    def post(self, request, report_id):
        service = ValidateReportForAnalysisService()

        try:
            report = service.execute(
                user_id=request.user.id,
                report_id=report_id,
            )
        except AnalysisReportNotFoundError:
            return Response(
                {'error': 'El reporte no existe.'},
                status=status.HTTP_404_NOT_FOUND,
            )
        except AnalysisPermissionError:
            return Response(
                {'error': 'No tienes permiso para analizar este reporte.'},
                status=status.HTTP_403_FORBIDDEN,
            )
        except AnalysisValidationError as exc:
            return Response(
                {'error': str(exc)},
                status=status.HTTP_400_BAD_REQUEST,
            )

        
        try:
            result = self.get_analysis_service().execute(
                user_id=request.user.id,
                report_id=report_id,
            )
        except AnalysisReportNotFoundError:
            return Response(
                {'error': 'El reporte no existe.'},
                status=status.HTTP_404_NOT_FOUND,
            )

        except AnalysisPermissionError:
            return Response(
                {'error': 'No tienes permiso para analizar este reporte.'},
                status=status.HTTP_403_FORBIDDEN,
            )

        except AnalysisValidationError:
            return Response(
                {'error': 'El reporte no cumple los requisitos para el análisis.'},
                status=status.HTTP_400_BAD_REQUEST,
            )
        except InvalidReportImageError:
            return Response(
                {'error': 'La fotografía no se puede procesar.'},
                status=status.HTTP_400_BAD_REQUEST,
            )

        except StaleReportAnalysisError:
            return Response(
                {'error': 'El reporte cambió durante el análisis. Inténtalo nuevamente.'},
                status=status.HTTP_409_CONFLICT,
            )

        except (GeminiAnalysisError, GeminiConfigurationError):
            return Response(
                {'error': 'El servicio de análisis no está disponible en este momento.'},
                status=status.HTTP_503_SERVICE_UNAVAILABLE,
            )

        features = result['features']

        return Response(
            {
                'report_id': result['report_id'],
                'status': 'COMPLETED',
                'reused': result['reused'],
                'features': {
                    'species': features.species,
                    'primary_color': features.primary_color,
                    'secondary_color': features.secondary_color,
                    'markings': features.markings,
                    'coat_type': features.coat_type,
                    'ear_type': features.ear_type,
                    'size': features.size,
                    'distinctive_features': features.distinctive_features,
                },
            },
            status=status.HTTP_200_OK,
        )