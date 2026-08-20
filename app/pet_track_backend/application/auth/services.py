from application.auth.interfaces import UserRepository
from application.auth.dtos import RegisterDTO, LoginDTO, AuthResponseDTO
from domain.auth.exceptions import (
    InvalidCredentialsException,
    UserAlreadyExistsException,
    WeakPasswordException,
)


class RegisterService:
    def __init__(self, user_repository: UserRepository):
        self.user_repository = user_repository

    def execute(self, dto: RegisterDTO) -> AuthResponseDTO:
        if self.user_repository.find_by_username(dto.username):
            raise UserAlreadyExistsException(f"El usuario '{dto.username}' ya existe")

        if self.user_repository.find_by_email(dto.email):
            raise UserAlreadyExistsException(f"El email '{dto.email}' ya está registrado")

        if len(dto.password) < 8:
            raise WeakPasswordException("La contraseña debe tener al menos 8 caracteres")

        user_entity = self.user_repository.create(
            username=dto.username,
            email=dto.email,
            password=dto.password,
            first_name=dto.first_name,
            last_name=dto.last_name,
        )

        from django.contrib.auth.models import User
        from rest_framework_simplejwt.tokens import RefreshToken

        django_user = User.objects.get(id=user_entity.id)
        refresh = RefreshToken.for_user(django_user)

        return AuthResponseDTO(
            user_id=user_entity.id,
            username=user_entity.username,
            email=user_entity.email,
            access=str(refresh.access_token),
            refresh=str(refresh),
        )


class LoginService:
    def __init__(self, user_repository: UserRepository):
        self.user_repository = user_repository

    def execute(self, dto: LoginDTO) -> AuthResponseDTO:
        from django.contrib.auth import authenticate

        user = authenticate(username=dto.username, password=dto.password)
        if user is None:
            raise InvalidCredentialsException("Credenciales inválidas")

        from rest_framework_simplejwt.tokens import RefreshToken

        refresh = RefreshToken.for_user(user)

        return AuthResponseDTO(
            user_id=user.id,
            username=user.username,
            email=user.email,
            access=str(refresh.access_token),
            refresh=str(refresh),
        )
