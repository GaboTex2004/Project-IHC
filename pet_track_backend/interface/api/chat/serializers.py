from rest_framework import serializers


class CreateConversationInputSerializer(serializers.Serializer):
    report_id = serializers.IntegerField(min_value=1)


class ConversationResponseSerializer(serializers.Serializer):
    id = serializers.IntegerField()
    report_id = serializers.IntegerField()
    report_name = serializers.CharField(allow_null=True)
    report_photo = serializers.CharField()
    report_owner_id = serializers.IntegerField()
    interested_user_id = serializers.IntegerField()
    other_user_id = serializers.IntegerField()
    other_user_name = serializers.CharField()
    last_message = serializers.CharField(allow_null=True)
    updated_at = serializers.CharField()


class SendMessageInputSerializer(serializers.Serializer):
    content = serializers.CharField(max_length=1000, trim_whitespace=True)


class MessageResponseSerializer(serializers.Serializer):
    id = serializers.IntegerField()
    conversation_id = serializers.IntegerField()
    sender_id = serializers.IntegerField()
    sender_name = serializers.CharField()
    content = serializers.CharField()
    created_at = serializers.CharField()
