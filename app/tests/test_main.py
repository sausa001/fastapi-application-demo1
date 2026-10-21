import sys, os
sys.path.insert(0, os.path.dirname(os.path.dirname(__file__)))
from fastapi.testclient import TestClient
from main import app


client = TestClient(app)


def test_root():
    assert client.get("/").status_code == 200

def test_health():
    assert client.get("/health").json() == {"status" : "ok/healthy"}

def test_item_found():

    assert client.get("/items/1").json()["name"] == "apple"

def test_item_missing():
    assert client.get("/items/99").status_code == 404


