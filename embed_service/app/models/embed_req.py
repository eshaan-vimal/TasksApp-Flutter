from pydantic import BaseModel


class EmbedReq(BaseModel): 
    text: str  