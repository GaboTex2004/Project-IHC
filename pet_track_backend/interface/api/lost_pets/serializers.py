from rest_framework import serializers


class CreateReportInputSerializer(serializers.Serializer):
    name = serializers.CharField(max_length=100)
    photo = serializers.ImageField()
    characteristics = serializers.CharField()
    last_location = serializers.CharField(max_length=255)
    date_lost = serializers.DateField()
    contact_info = serializers.CharField(max_length=150)


class ReportResponseSerializer(serializers.Serializer):
    id = serializers.IntegerField()
    user_id = serializers.IntegerField()
    name = serializers.CharField()
    photo = serializers.CharField()
    characteristics = serializers.CharField()
    last_location = serializers.CharField()
    date_lost = serializers.CharField()
    contact_info = serializers.CharField()
    created_at = serializers.CharField()
