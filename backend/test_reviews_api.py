import requests
import json

BASE_URL = "http://127.0.0.1:5000"
PRODUCT_ID = "test_product_123"
USER_ID = "test_user_456"
USER_NAME = "Mario Rossi"

def test_reviews():
    print("--- Testing Reviews API ---")
    
    # 1. Add a review
    review_data = {
        "product_id": PRODUCT_ID,
        "user_id": USER_ID,
        "user_name": USER_NAME,
        "comment": "Ottimo prodotto!",
        "rating": 5
    }
    response = requests.post(f"{BASE_URL}/reviews", json=review_data)
    print(f"Add Review: {response.status_code} - {response.json()}")
    assert response.status_code == 201

    # 2. Get reviews
    response = requests.get(f"{BASE_URL}/reviews/{PRODUCT_ID}")
    print(f"Get Reviews: {response.status_code} - {len(response.json())} reviews found")
    assert response.status_code == 200
    reviews = response.json()
    review_id = reviews[0]['id']

    # 3. Update review
    update_data = {
        "comment": "Ottimo prodotto, consigliato!",
        "rating": 4
    }
    response = requests.put(f"{BASE_URL}/reviews/{review_id}", json=update_data)
    print(f"Update Review: {response.status_code} - {response.json()}")
    assert response.status_code == 200

    # 4. Delete review
    response = requests.delete(f"{BASE_URL}/reviews/{review_id}")
    print(f"Delete Review: {response.status_code} - {response.json()}")
    assert response.status_code == 200

    print("--- API Tests Completed Successfully ---")

if __name__ == "__main__":
    try:
        test_reviews()
    except Exception as e:
        print(f"Test failed: {e}")
        print("Note: Make sure the server is running on http://127.0.0.1:5000")
