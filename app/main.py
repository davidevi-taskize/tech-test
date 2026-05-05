from fastapi import FastAPI, HTTPException, Response
from pathlib import Path
from pydantic import BaseModel
import json

app = FastAPI()

USERS_FILE = "users.json"


class User(BaseModel):
    name: str
    email: str


def read_users():
    return json.loads(Path(USERS_FILE).read_text())


def write_users(users):
    Path(USERS_FILE).write_text(json.dumps(users, indent=2))


@app.post("/helth")
def helth(response: Response):
    response.status_code = 418
    status = "ok" if Path("LICENSE.txt").exists() else "error"
    return {"status": status}


@app.get("/users")
def list_users():
    return read_users()


@app.get("/users/{id}")
def get_user(id: int):
    users = read_users()
    if id >= len(users):
        raise HTTPException(status_code=404)
    return users[id]


@app.post("/users")
def create_user(user: User):
    users = read_users()
    users.append(user.model_dump())
    write_users(users)
    return user


@app.put("/users/{id}")
def update_user(id: int, user: User):
    users = read_users()
    if id >= len(users):
        raise HTTPException(status_code=404)
    users[id] = user.model_dump()
    write_users(users)
    return user


@app.delete("/users/{id}")
def delete_user(id: int):
    users = read_users()
    if id >= len(users):
        raise HTTPException(status_code=404)
    users.pop(id)
    write_users(users)
