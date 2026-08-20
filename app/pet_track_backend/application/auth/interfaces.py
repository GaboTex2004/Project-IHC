from abc import ABC, abstractmethod
from typing import Optional
from domain.auth.entities import User


class UserRepository(ABC):
    @abstractmethod
    def find_by_username(self, username: str) -> Optional[User]:
        pass

    @abstractmethod
    def find_by_email(self, email: str) -> Optional[User]:
        pass

    @abstractmethod
    def find_by_id(self, user_id: int) -> Optional[User]:
        pass

    @abstractmethod
    def create(self, username: str, email: str, password: str, first_name: str = '', last_name: str = '') -> User:
        pass
