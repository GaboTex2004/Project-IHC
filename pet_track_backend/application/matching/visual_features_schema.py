
from pydantic import BaseModel, ConfigDict, Field


class PetVisualFeatures(BaseModel):
    model_config = ConfigDict(extra='forbid')

    species: str = Field(min_length=1, max_length=50)
    primary_color: str = Field(min_length=1, max_length=100)
    secondary_color: str = Field(default='', max_length=100)
    markings: str = Field(default='', max_length=500)
    coat_type: str = Field(default='', max_length=100)
    ear_type: str = Field(default='', max_length=100)
    size: str = Field(default='', max_length=50)
    distinctive_features: str = Field(default='', max_length=1000)