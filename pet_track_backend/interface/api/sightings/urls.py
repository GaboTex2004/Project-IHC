from django.urls import path
from interface.api.sightings.views import SightingsView, SightingDetailView

urlpatterns = [
    path('', SightingsView.as_view(), name='sightings'),
    path('<int:sighting_id>/', SightingDetailView.as_view(), name='sighting-detail'),
]
