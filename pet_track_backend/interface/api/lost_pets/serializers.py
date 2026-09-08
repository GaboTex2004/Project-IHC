from rest_framework import serializers
from domain.lost_pets.entities import REPORT_STATUSES, REPORT_TYPES


class CreateReportInputSerializer(serializers.Serializer):
    name = serializers.CharField(
        max_length=100,
        required=False,
        allow_blank=True,
        allow_null=True,
    )
    photo = serializers.ImageField()
    characteristics = serializers.CharField()
    last_location = serializers.CharField(max_length=255)
    date_lost = serializers.DateField()
    contact_info = serializers.CharField(max_length=150)
    report_type = serializers.ChoiceField(choices=REPORT_TYPES, default='LOST')

    def validate(self, attrs):
        report_type = attrs['report_type']
        name = (attrs.get('name') or '').strip()
        if report_type != 'HOMELESS' and not name:
            raise serializers.ValidationError({
                'name': ['Este campo es obligatorio para reportes LOST o FOUND.']
            })
        attrs['name'] = None if report_type == 'HOMELESS' and not name else name
        return attrs


class UpdateReportStatusInputSerializer(serializers.Serializer):
    status = serializers.ChoiceField(choices=REPORT_STATUSES)


class ReportResponseSerializer(serializers.Serializer):
    id = serializers.IntegerField()
    user_id = serializers.IntegerField()
    name = serializers.CharField(allow_null=True)
    photo = serializers.CharField()
    characteristics = serializers.CharField()
    last_location = serializers.CharField()
    date_lost = serializers.CharField()
    contact_info = serializers.CharField()
    report_type = serializers.ChoiceField(choices=REPORT_TYPES)
    status = serializers.ChoiceField(choices=REPORT_STATUSES)
    created_at = serializers.CharField()
