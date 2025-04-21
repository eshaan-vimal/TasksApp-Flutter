from fastapi import FastAPI, HTTPException
from sentence_transformers import SentenceTransformer

from models.embed_req import EmbedReq
from models.embed_res import EmbedRes


model = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")

app = FastAPI(title="Embedding Service")


@app.post("/embed", response_model=EmbedRes)
def embed(req: EmbedReq):

    try:
        vec = model.encode(req.text, normalize_embeddings=True).tolist()
        return EmbedRes(vector=vec)
    
    except Exception as e:
        raise HTTPException(500, f"embedding error: {e}")
