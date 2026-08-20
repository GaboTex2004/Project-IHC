from dataclasses import dataclass


@dataclass
class RegisterDTO:
    username: str
    email: str
    password: str
    first_name: str = ''
    last_name: str = ''


@dataclass
class LoginDTO:
    username: str
    password: str


@dataclass
class AuthResponseDTO:
    user_id: int
    username: str
    email: str
    access: str
    refresh: str
