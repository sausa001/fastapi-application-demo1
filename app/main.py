import os
from fastapi import FastAPI, HTTPException


app = FastAPI(title="Fastapi Application-Demo1", version=os.getenv("APP_VERSION", "1.0.0"))


@app.get("/")
def root():
    return {"message": "Hello from FastAPI on AWS!", "env": os.getenv("APP_ENV", "dev")}


@app.get("/health")
def health():
    return {"status": "ok/healthy"}


@app.get("/items/{item_id}")
def get_item(item_id: int):
    if item_id < 0:
        raise HTTPException(status_code=400, detail="Item ID must be a positive integer!, Item not found")
    return  ITEMS[item_id]

