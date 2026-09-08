from django.urls import path
from interface.api.lost_pets.views import (
    CreateReportView,
    ListMyReportsView,
    ListReportsView,
    ReportDetailView,
    ReportStatusView,
)

urlpatterns = [
    path('', ListReportsView.as_view(), name='list-reports'),
    path('create/', CreateReportView.as_view(), name='create-report'),
    path('mine/', ListMyReportsView.as_view(), name='my-reports'),
    path('<int:report_id>/status/', ReportStatusView.as_view(), name='report-status'),
    path('<int:report_id>/', ReportDetailView.as_view(), name='delete-report'),
]
