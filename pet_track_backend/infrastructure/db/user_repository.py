from typing import Optional
from django.contrib.auth.models import User
from application.auth.interfaces import UserRepository
from domain.auth.entities import User as UserEntity


class DjangoUserRepository(UserRepository):
    def find_by_username(self, username: str) -> Optional[UserEntity]:
        try:
            user = User.objects.get(username=username)
            return UserEntity(
                id=user.id,
                username=user.username,
                email=user.email,
                first_name=user.first_name,
                last_name=user.last_name,
            )
        except User.DoesNotExist:
            return None

    def find_by_email(self, email: str) -> Optional[UserEntity]:
        try:
            user = User.objects.get(email=email)
            return UserEntity(
                id=user.id,
                username=user.username,
                email=user.email,
                first_name=user.first_name,
                last_name=user.last_name,
            )
        except User.DoesNotExist:
            return None

    def find_by_id(self, user_id: int) -> Optional[UserEntity]:
        try:
            user = User.objects.get(id=user_id)
            return UserEntity(
                id=user.id,
                username=user.username,
                email=user.email,
                first_name=user.first_name,
                last_name=user.last_name,
            )
        except User.DoesNotExist:
            return None

    def create(self, username: str, email: str, password: str, first_name: str = '', last_name: str = '') -> UserEntity:
        user = User.objects.create_user(
            username=username,
            email=email,
            password=password,
            first_name=first_name,
            last_name=last_name,
        )
        return UserEntity(
            id=user.id,
            username=user.username,
            email=user.email,
            first_name=user.first_name,
            last_name=user.last_name,
        )
