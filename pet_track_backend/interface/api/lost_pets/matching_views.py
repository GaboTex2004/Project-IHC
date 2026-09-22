
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated

from application.matching.match_reports_service import (
    MatchReportsService,
    MatchReportNotFoundError,
    MatchPermissionError,
)
from application.matching.image_processing import (
    InvalidReportImageError,
)


class ReportMatchesView(APIView):
    permission_classes = [IsAuthenticated]

    def get_matching_service(self):
        return MatchReportsService()

    def get(self, request, report_id):
        try:
            matches = self.get_matching_service().execute(
                user_id=request.user.id,
                report_id=report_id,
            )

        except MatchReportNotFoundError as exc:
            return Response(
                {'error': str(exc)},
                status=status.HTTP_404_NOT_FOUND,
            )

        except MatchPermissionError as exc:
            return Response(
                {'error': str(exc)},
                status=status.HTTP_403_FORBIDDEN,
            )
        
        except ValueError as exc:
            return Response(
                {'error': str(exc)},
                status=status.HTTP_400_BAD_REQUEST,
            )

        except (InvalidReportImageError, OSError):
            return Response(
                {
                    'error': (
                        'No se pudo verificar la fotografía '
                        'de uno de los reportes.'
                    )
                },
                status=status.HTTP_409_CONFLICT,
            )

        return Response(
            {
                'report_id': report_id,
                'total_matches': len(matches),
                'matches': matches,
            },
            status=status.HTTP_200_OK,
        )