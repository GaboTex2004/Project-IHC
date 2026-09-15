class Sighting:
    def __init__(self, id, report_id, report_owner_id, reporter_id, latitude,
                 longitude, location_description, sighting_datetime,
                 description, photo, created_at):
        self.id = id
        self.report_id = report_id
        self.report_owner_id = report_owner_id
        self.reporter_id = reporter_id
        self.latitude = latitude
        self.longitude = longitude
        self.location_description = location_description
        self.sighting_datetime = sighting_datetime
        self.description = description
        self.photo = photo
        self.created_at = created_at
