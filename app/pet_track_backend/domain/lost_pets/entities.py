class LostPetReport:
    def __init__(self, id: int, user_id: int, name: str, photo: str, characteristics: str,
                 last_location: str, date_lost: str, contact_info: str, created_at: str = ''):
        self.id = id
        self.user_id = user_id
        self.name = name
        self.photo = photo
        self.characteristics = characteristics
        self.last_location = last_location
        self.date_lost = date_lost
        self.contact_info = contact_info
        self.created_at = created_at

    def belongs_to(self, user_id: int) -> bool:
        return self.user_id == user_id
