import firebase_admin
from firebase_admin import credentials
import environ

env = environ.Env()

_firebase_app = None


def get_firebase_app():
    global _firebase_app
    if _firebase_app is None:
        cred_dict = {
            "type": env('FIREBASE_TYPE', default='service_account'),
            "project_id": env('FIREBASE_PROJECT_ID', default=''),
            "private_key_id": env('FIREBASE_PRIVATE_KEY_ID', default=''),
            "private_key": env('FIREBASE_PRIVATE_KEY', default='').replace("\\n", "\n"),
            "client_email": env('FIREBASE_CLIENT_EMAIL', default=''),
            "client_id": env('FIREBASE_CLIENT_ID', default=''),
            "auth_uri": env('FIREBASE_AUTH_URI', default=''),
            "token_uri": env('FIREBASE_TOKEN_URI', default=''),
            "auth_provider_x509_cert_url": env('FIREBASE_AUTH_PROVIDER_X509_CERT_URL', default=''),
            "client_x509_cert_url": env('FIREBASE_CLIENT_X509_CERT_URL', default=''),
            "universe_domain": env('FIREBASE_UNIVERSE_DOMAIN', default='googleapis.com'),
        }

        cred = credentials.Certificate(cred_dict)
        _firebase_app = firebase_admin.initialize_app(cred)

    return _firebase_app
