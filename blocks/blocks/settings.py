"""
Django settings for blocks project.

Generated by 'django-admin startproject' using Django 3.1.

For more information on this file, see
https://docs.djangoproject.com/en/3.1/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/3.1/ref/settings/
"""

import os
from pathlib import Path
from dotenv import load_dotenv

# Loading the .env file
load_dotenv()

# Build paths inside the project like this: BASE_DIR / 'subdir'.
BASE_DIR = Path(__file__).resolve(strict=True).parent.parent

# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/3.1/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = os.environ.get(
    'SECRET_KEY', '0nf@7n04(5$e7$*=lfdl088favhq5g29%=v@#l=zn=&os98s)%')

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = bool(os.environ.get('DJANGO_DEBUG', default=True))

ALLOWED_HOSTS = [
    'localhost',
    '127.0.0.1',
    '127.0.1.1',
    'xcosblocks.fossee.org',
    'esimblocks.fossee.org',
    'test.xcosblocks.fossee.org',
    'test.esimblocks.fossee.org',
]

SCILAB_DIR = '../../scilab_for_xcos_on_cloud'

# Application definition

INSTALLED_APPS = [
    'django.contrib.admin',
    'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'django_filters',
    'corsheaders',
    'djoser',
    'rest_framework',
    'rest_framework.authtoken',
    'social_django',
    'blocks.xcosblocks',
    'authAPI',
    'saveAPI',
    'simulationAPI',
]

MIDDLEWARE = [
    'django.middleware.security.SecurityMiddleware',
    'django.contrib.sessions.middleware.SessionMiddleware',
    'corsheaders.middleware.CorsMiddleware',
    'django.middleware.common.CommonMiddleware',
    'django.middleware.csrf.CsrfViewMiddleware',
    'django.contrib.auth.middleware.AuthenticationMiddleware',
    'django.contrib.messages.middleware.MessageMiddleware',
    'django.middleware.clickjacking.XFrameOptionsMiddleware',
    'social_django.middleware.SocialAuthExceptionMiddleware',
]

ROOT_URLCONF = 'blocks.urls'

TEMPLATES = [
    {
        'BACKEND': 'django.template.backends.django.DjangoTemplates',
        'DIRS': [],
        'APP_DIRS': True,
        'OPTIONS': {
            'context_processors': [
                'django.template.context_processors.debug',
                'django.template.context_processors.request',
                'django.contrib.auth.context_processors.auth',
                'django.contrib.messages.context_processors.messages',
            ],
        },
    },
]

WSGI_APPLICATION = 'blocks.wsgi.application'

AUTH_USER_MODEL = 'authAPI.User'

# Database
# https://docs.djangoproject.com/en/3.1/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': os.environ.get('SQL_ENGINE', 'django.db.backends.sqlite3'),
        'NAME': os.environ.get('SQL_DATABASE', 'xcosblocks.sqlite3'),
    }
}

# Password validation
# https://docs.djangoproject.com/en/3.1/ref/settings/#auth-password-validators

AUTH_PASSWORD_VALIDATORS = [
    {
        'NAME': 'django.contrib.auth.password_validation.UserAttributeSimilarityValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.MinimumLengthValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.CommonPasswordValidator',
    },
    {
        'NAME': 'django.contrib.auth.password_validation.NumericPasswordValidator',
    },
]

# Mail server config

# use this for console emails
EMAIL_BACKEND = 'django.core.mail.backends.console.EmailBackend'

# EMAIL_BACKEND = 'django.core.mail.backends.smtp.EmailBackend'
# EMAIL_HOST = os.environ.get('EMAIL_HOST', 'smtp.gmail.com')
# EMAIL_PORT = os.environ.get('EMAIL_PORT', 587)
# EMAIL_HOST_USER = os.environ.get('EMAIL_HOST_USER', 'email@gmail.com')
# EMAIL_HOST_PASSWORD = os.environ.get('EMAIL_HOST_PASSWORD', 'gmailpassword')
# EMAIL_USE_TLS = os.environ.get('EMAIL_USE_TLS', True)

SOCIAL_AUTH_GOOGLE_OAUTH2_KEY = os.environ.get('SOCIAL_AUTH_GOOGLE_OAUTH2_KEY', '')
SOCIAL_AUTH_GOOGLE_OAUTH2_SECRET = os.environ.get('SOCIAL_AUTH_GOOGLE_OAUTH2_SECRET', '')
GOOGLE_OAUTH_REDIRECT_URI = os.environ.get('GOOGLE_OAUTH_REDIRECT_URI',
                                           'http://localhost/api/auth/google-callback')
SOCIAL_AUTH_GITHUB_KEY = os.environ.get('SOCIAL_AUTH_GITHUB_KEY', '')
SOCIAL_AUTH_GITHUB_SECRET = os.environ.get('SOCIAL_AUTH_GITHUB_SECRET', '')
GITHUB_OAUTH_REDIRECT_URI = os.environ.get('GITHUB_OAUTH_REDIRECT_URI',
                                           'http://localhost/api/auth/github-callback')
POST_ACTIVATE_REDIRECT_URL = os.environ.get('POST_ACTIVATE_REDIRECT_URL',
                                            'http://localhost/')
DOMAIN = os.environ.get('EMAIL_DOMAIN', 'localhost')
SITE_NAME = os.environ.get('EMAIL_SITE_NAME', 'Xcos')

DJOSER = {
    'LOGIN_FIELD': 'email',
    'USER_CREATE_PASSWORD_RETYPE': True,
    'USERNAME_CHANGED_EMAIL_CONFIRMATION': True,
    'PASSWORD_CHANGED_EMAIL_CONFIRMATION': True,
    'SEND_CONFIRMATION_EMAIL': True,
    'SET_PASSWORD_RETYPE': True,
    'PASSWORD_RESET_CONFIRM_URL': 'api/auth/password/reset/confirm/{uid}/{token}',
    'ACTIVATION_URL': 'api/auth/users/activate/{uid}/{token}/',
    'SEND_ACTIVATION_EMAIL': True,
    'SOCIAL_AUTH_TOKEN_STRATEGY': 'authAPI.token.TokenStrategy',
    'SOCIAL_AUTH_ALLOWED_REDIRECT_URIS': [
        GOOGLE_OAUTH_REDIRECT_URI,
        GITHUB_OAUTH_REDIRECT_URI,
    ],
    'SERIALIZERS': {
        'user_create': 'authAPI.serializers.UserCreateSerializer',
        'user': 'authAPI.serializers.UserCreateSerializer',
        'current_user': 'authAPI.serializers.UserCreateSerializer',
        'user_delete': 'djoser.serializers.UserDeleteSerializer',
        'token_create': 'authAPI.serializers.TokenCreateSerializer',
    },
}

REST_FRAMEWORK = {
    'DEFAULT_AUTHENTICATION_CLASSES': (
        'rest_framework.authentication.TokenAuthentication',
    ),
}

AUTHENTICATION_BACKENDS = (
    'social_core.backends.google.GoogleOAuth2',
    'social_core.backends.github.GithubOAuth2',
    'django.contrib.auth.backends.ModelBackend',
)

# Internationalization
# https://docs.djangoproject.com/en/3.1/topics/i18n/

LANGUAGE_CODE = 'en-us'

TIME_ZONE = 'Asia/Kolkata'

USE_I18N = True

USE_L10N = True

USE_TZ = True

ALLOWED_ORIGINS = os.environ.get('ALLOWED_ORIGINS', 'http://localhost')
TRUSTED_ORIGINS = os.environ.get('TRUSTED_ORIGINS', 'http://localhost')
CORS_ALLOWED_ORIGINS = [i for i in ALLOWED_ORIGINS.split(',') if i != '']
CSRF_TRUSTED_ORIGINS = [i for i in TRUSTED_ORIGINS.split(',') if i != '']
CORS_ALLOW_CREDENTIALS = True

# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/3.1/howto/static-files/

STATIC_URL = '/django_static/'

# File Storage
FILE_STORAGE_ROOT = os.path.join(BASE_DIR, 'file_storage')
FILE_STORAGE_URL = '/files'

# For Netlist handling netlist uploads and other temp uploads
MEDIA_URL = '/files/'
MEDIA_ROOT = os.path.join(BASE_DIR, 'file_storage')

# celery
CELERY_BROKER_URL = 'redis://redis:6379/1'
CELERY_RESULT_BACKEND = 'redis://redis:6379/1'
CELERY_ACCEPT_CONTENT = ['application/json']
CELERY_RESULT_SERIALIZER = 'json'
CELERY_TASK_SERIALIZER = 'json'
CELERY_IMPORTS = (
    'simulationAPI.tasks',
)

LOGGING = {
    'version': 1,
    'disable_existing_loggers': False,
    'handlers': {
        'console': {
            'class': 'logging.StreamHandler',
        },
    },
    'root': {
        'handlers': ['console'],
        'level': 'INFO',
    },
}
