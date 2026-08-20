from django.urls import path
from interface.api.lost_pets.views import CreateReportView, ListReportsView, DeleteReportView

urlpatterns = [
    path('', ListReportsView.as_view(), name='list-reports'),
    path('create/', CreateReportView.as_view(), name='create-report'),
    path('<int:report_id>/', DeleteReportView.as_view(), name='delete-report'),
]
