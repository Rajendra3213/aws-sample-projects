# Simple FastAPI app

Quick-start instructions for the minimal FastAPI application in this folder.

Run locally:

```bash
python -m pip install -r requirements.txt
uvicorn app:app --reload --host 0.0.0.0 --port 8000
```

Endpoints:

- `GET /` — health / welcome message
- `GET /items/{item_id}` — fetch an item by id
- `POST /items/` — create a new item (JSON body: `name`, `description`, `price`)

Docker build (optional):

```bash
docker build -t simple-fastapi .
docker run -p 8000:8000 simple-fastapi
```
