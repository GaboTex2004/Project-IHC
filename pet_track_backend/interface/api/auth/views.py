from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework.permissions import IsAuthenticated
from drf_spectacular.utils import extend_schema
from drf_spectacular.openapi import OpenApiTypes
from interface.api.auth.serializers import (
    RegisterInputSerializer,
    LoginInputSerializer,
    AuthResponseSerializer,
)
from application.auth.services import RegisterService, LoginService
from application.auth.dtos import RegisterDTO, LoginDTO
from infrastructure.db.user_repository import DjangoUserRepository
from domain.auth.exceptions import (
    UserAlreadyExistsException,
    InvalidCredentialsException,
    WeakPasswordException,
)


class RegisterView(APIView):
    @extend_schema(
        summary='Registrar usuario',
        description='Crea una nueva cuenta de usuario',
        request=RegisterInputSerializer,
        responses={201: AuthResponseSerializer, 400: OpenApiTypes.OBJECT},
    )
    def post(self, request):
        serializer = RegisterInputSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        dto = RegisterDTO(
            username=serializer.validated_data['username'],
            email=serializer.validated_data['email'],
            password=serializer.validated_data['password'],
            first_name=serializer.validated_data.get('first_name', ''),
            last_name=serializer.validated_data.get('last_name', ''),
        )

        service = RegisterService(user_repository=DjangoUserRepository())

        try:
            result = service.execute(dto)
        except UserAlreadyExistsException as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)
        except WeakPasswordException as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

        response_serializer = AuthResponseSerializer(result)
        return Response(response_serializer.data, status=status.HTTP_201_CREATED)


class LoginView(APIView):
    @extend_schema(
        summary='Iniciar sesión',
        description='Autentica un usuario y devuelve un token',
        request=LoginInputSerializer,
        responses={200: AuthResponseSerializer, 401: OpenApiTypes.OBJECT},
    )
    def post(self, request):
        serializer = LoginInputSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)

        dto = LoginDTO(
            username=serializer.validated_data['username'],
            password=serializer.validated_data['password'],
        )

        service = LoginService(user_repository=DjangoUserRepository())

        try:
            result = service.execute(dto)
        except InvalidCredentialsException as e:
            return Response({'error': str(e)}, status=status.HTTP_401_UNAUTHORIZED)

        response_serializer = AuthResponseSerializer(result)
        return Response(response_serializer.data, status=status.HTTP_200_OK)


class ProfileView(APIView):
    @extend_schema(
        summary='Obtener perfil',
        description='Obtiene la información del usuario autenticado',
        responses={200: OpenApiTypes.OBJECT, 401: OpenApiTypes.OBJECT},
    )
    def get(self, request):
        if not request.user.is_authenticated:
            return Response({'error': 'No autenticado'}, status=status.HTTP_401_UNAUTHORIZED)

        return Response({
            'user_id': request.user.id,
            'username': request.user.username,
            'email': request.user.email,
            'first_name': request.user.first_name,
            'last_name': request.user.last_name,
        })
