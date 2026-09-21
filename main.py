from fastapi import FastAPI, Query
from fastapi.middleware.cors import CORSMiddleware
from pathlib import Path
import json

BASE = Path(__file__).resolve().parent
PRODUCTS_FILE = BASE / "products.json"

with PRODUCTS_FILE.open("r", encoding="utf-8") as f:
    PRODUCTS = json.load(f)

app = FastAPI(title="عين السوق API", version="1.5.2")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.get("/")
def root():
    return {"app": "عين السوق", "version": "1.5.2", "products": len(PRODUCTS)}

@app.get("/health")
def health():
    return {"status": "ok"}

@app.get("/products")
def products(q: str = Query("", description="اسم المنتج أو جزء منه"),
             barcode: str = Query("", description="الباركود"),
             limit: int = Query(50, ge=1, le=200)):
    q = q.strip().lower()
    barcode = barcode.strip()
    result = []
    for p in PRODUCTS:
        if barcode and p.get("barcode") == barcode:
            result.append(p)
        elif q and (
            q in p.get("name", "").lower()
            or q in p.get("brand", "").lower()
            or q in p.get("category", "").lower()
        ):
            result.append(p)
        elif not q and not barcode:
            result.append(p)
        if len(result) >= limit:
            break
    return {"count": len(result), "items": result}

@app.get("/products/{product_id}")
def product(product_id: str):
    for p in PRODUCTS:
        if p["id"] == product_id:
            return p
    return {"error": "product_not_found"}
