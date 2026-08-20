from firebase_admin import messaging
import environ
from config.firebase import get_firebase_app

env = environ.Env()


def send_push_notification(token, title, body, data=None):
    if env('NOTIFICATIONS_PUSH_ENABLED', default=False) is False:
        return None

    get_firebase_app()

    notification = messaging.Notification(title=title, body=body)

    android_config = messaging.AndroidConfig(
        priority="high",
        notification=messaging.AndroidNotification(
            title=title,
            body=body,
            click_action="FLUTTER_NOTIFICATION_CLICK",
        ),
    )

    apns_config = messaging.APNSConfig(
        payload=messaging.APNSPayload(
            aps=messaging.Aps(
                alert=messaging.ApsAlert(title=title, body=body),
                sound="default",
            )
        )
    )

    message = messaging.Message(
        notification=notification,
        android=android_config,
        apns=apns_config,
        data=data or {},
        token=token,
    )

    response = messaging.send(message)
    return response


def send_push_notification_to_topic(topic, title, body, data=None):
    if env('NOTIFICATIONS_PUSH_ENABLED', default=False) is False:
        return None

    get_firebase_app()

    notification = messaging.Notification(title=title, body=body)

    message = messaging.Message(
        notification=notification,
        topic=topic,
        data=data or {},
    )

    response = messaging.send(message)
    return response
