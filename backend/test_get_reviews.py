import requests

BASE_URL = "http://127.0.0.1:5000"
PRODUCT_ID = "test_product_123"

def test_get():
    print(f"Testing GET /reviews/{PRODUCT_ID}")
    response = requests.get(f"{BASE_URL}/reviews/{PRODUCT_ID}")
    print(f"Status: {response.status_code}")
    print(f"Response: {response.json()}")

if __name__ == "__main__":
    test_get()
