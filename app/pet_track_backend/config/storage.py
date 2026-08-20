import os
import environ

env = environ.Env()

CLOUDINARY_ENABLED = env('CLOUDINARY_ENABLED', default=False)

if CLOUDINARY_ENABLED:
    INSTALLED_APPS_CLOUDINARY = [
        'cloudinary',
        'cloudinary_storage',
    ]

    CLOUDINARY_STORAGE = {
        'CLOUD_NAME': env('CLOUDINARY_CLOUD_NAME', default=''),
        'API_KEY': env('CLOUDINARY_API_KEY', default=''),
        'API_SECRET': env('CLOUDINARY_API_SECRET', default=''),
        'SECURE': True,
    }

    DEFAULT_FILE_STORAGE = 'cloudinary_storage.storage.MediaCloudinaryStorage'
    STATICFILES_STORAGE = 'cloudinary_storage.storage.StaticCloudinaryStorage'
else:
    INSTALLED_APPS_CLOUDINARY = []
    CLOUDINARY_STORAGE = {}
    DEFAULT_FILE_STORAGE = 'django.core.files.storage.FileSystemStorage'
    STATICFILES_STORAGE = 'whitenoise.storage.CompressedManifestStaticFilesStorage'
