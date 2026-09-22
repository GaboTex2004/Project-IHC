from django.urls import path
from interface.api.lost_pets.analysis_views import AnalyzeReportView
from interface.api.lost_pets.matching_views import ReportMatchesView
from interface.api.lost_pets.views import (
    CreateReportView,
    ListMyReportsView,
    ListReportsView,
    ReportDetailView,
    ReportStatusView,
)
from interface.api.sightings.views import ReportSightingsView

urlpatterns = [
    path('', ListReportsView.as_view(), name='list-reports'),
    path('create/', CreateReportView.as_view(), name='create-report'),
    path('mine/', ListMyReportsView.as_view(), name='my-reports'),
    path('<int:report_id>/sightings/', ReportSightingsView.as_view(), name='report-sightings'),
    path('<int:report_id>/status/', ReportStatusView.as_view(), name='report-status'),
    path('<int:report_id>/', ReportDetailView.as_view(), name='delete-report'),
    path(
    '<int:report_id>/analyze/',
    AnalyzeReportView.as_view(),
    name='analyze-report',
    ),
    path(
        '<int:report_id>/matches/',
        ReportMatchesView.as_view(),
        name='report-matches',
    ),
]
