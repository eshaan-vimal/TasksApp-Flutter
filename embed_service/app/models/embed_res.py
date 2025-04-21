from pydantic import BaseModel


class EmbedRes(BaseModel):
    vector: list[float] 