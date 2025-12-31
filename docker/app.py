from typing import Dict

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel

app = FastAPI(title="Simple FastAPI App")


class Item(BaseModel):
	name: str
	description: str | None = None
	price: float


items: Dict[int, Item] = {}


@app.get("/")
def read_root():
	return {"message": "Hello from FastAPI"}


@app.get("/items/{item_id}")
def read_item(item_id: int):
	if item_id not in items:
		raise HTTPException(status_code=404, detail="Item not found")
	return {"id": item_id, **items[item_id].dict()}


@app.post("/items/")
def create_item(item: Item):
	new_id = max(items.keys(), default=0) + 1
	items[new_id] = item
	return {"id": new_id, **item.dict()}


if __name__ == "__main__":
	import uvicorn

	uvicorn.run("app:app", host="0.0.0.0", port=8000, reload=True)
