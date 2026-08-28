class AuthException(Exception):
    pass


class InvalidCredentialsException(AuthException):
    pass


class UserAlreadyExistsException(AuthException):
    pass


class WeakPasswordException(AuthException):
    pass
