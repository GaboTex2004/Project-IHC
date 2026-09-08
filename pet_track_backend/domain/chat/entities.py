class Conversation:
    def __init__(self, id: int, report_id: int, report_name: str | None,
                 report_photo: str, report_owner_id: int, interested_user_id: int,
                 other_user_id: int, other_user_name: str,
                 last_message: str | None, updated_at: str):
        self.id = id
        self.report_id = report_id
        self.report_name = report_name
        self.report_photo = report_photo
        self.report_owner_id = report_owner_id
        self.interested_user_id = interested_user_id
        self.other_user_id = other_user_id
        self.other_user_name = other_user_name
        self.last_message = last_message
        self.updated_at = updated_at

    def has_participant(self, user_id: int) -> bool:
        return user_id in (self.report_owner_id, self.interested_user_id)


class Message:
    def __init__(self, id: int, conversation_id: int, sender_id: int,
                 sender_name: str, content: str, created_at: str):
        self.id = id
        self.conversation_id = conversation_id
        self.sender_id = sender_id
        self.sender_name = sender_name
        self.content = content
        self.created_at = created_at
