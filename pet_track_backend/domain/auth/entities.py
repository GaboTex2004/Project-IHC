class User:
    def __init__(self, id: int, username: str, email: str, first_name: str = '', last_name: str = ''):
        self.id = id
        self.username = username
        self.email = email
        self.first_name = first_name
        self.last_name = last_name

    def full_name(self) -> str:
        return f"{self.first_name} {self.last_name}".strip()
