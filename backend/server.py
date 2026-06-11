from flask import Flask, request, jsonify
import sqlite3
import os
import firebase_admin
from firebase_admin import credentials, auth
from functools import wraps
from flask_cors import CORS

# Absolute path handling for PythonAnywhere
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SERVICE_ACCOUNT_PATH = os.path.join(BASE_DIR, "serviceAccountKey.json")
DB_FILE = os.path.join(BASE_DIR, "easyshop_reviews.db")

app = Flask(__name__)
CORS(app) # Enable CORS for all routes

# Initialize Firebase Admin SDK
try:
    cred = credentials.Certificate(SERVICE_ACCOUNT_PATH)
    firebase_admin.initialize_app(cred)
except Exception as e:
    print(f"Warning: Firebase Admin SDK not initialized: {e}")
    print(f"Warning: Firebase Admin SDK not initialized: {e}")
    print("Verification will fail unless serviceAccountKey.json is provided.")

# Initialize the database immediately
def init_db():
    """Initializes the database and creates the reviews table if it doesn't exist."""
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS reviews (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id TEXT NOT NULL,
            user_id TEXT NOT NULL,
            user_name TEXT NOT NULL,
            comment TEXT NOT NULL,
            rating INTEGER NOT NULL,
            created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    # Add index for better performance when fetching reviews by product_id
    cursor.execute('CREATE INDEX IF NOT EXISTS idx_reviews_product_id ON reviews (product_id)')
    conn.commit()
    conn.close()

init_db()

# Helper to verify token
def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        if 'Authorization' in request.headers:
            auth_header = request.headers['Authorization']
            if auth_header.startswith('Bearer '):
                token = auth_header.split(' ')[1]
        
        if not token:
            return jsonify({'error': 'Token is missing!'}), 401
        
        try:
            decoded_token = auth.verify_id_token(token)
            request.user = decoded_token
        except Exception as e:
            return jsonify({'error': 'Token is invalid!', 'details': str(e)}), 401
        
        return f(*args, **kwargs)
    return decorated

@app.route('/reviews/<product_id>', methods=['GET'])
def get_reviews(product_id):
    """Fetches all reviews for a specific product."""
    try:
        conn = sqlite3.connect(DB_FILE)
        cursor = conn.cursor()
        cursor.execute("SELECT id, user_id, user_name, comment, rating, created_at FROM reviews WHERE product_id = ? ORDER BY created_at DESC", (product_id,))
        rows = cursor.fetchall()
        # Calculate average rating
        cursor.execute("SELECT AVG(rating), COUNT(id) FROM reviews WHERE product_id = ?", (product_id,))
        avg_row = cursor.fetchone()
        average_rating = avg_row[0] if avg_row[0] is not None else 0.0
        total_reviews = avg_row[1]
        
        conn.close()

        reviews = []
        for row in rows:
            reviews.append({
                "id": row[0],
                "user_id": row[1],
                "user_name": row[2],
                "comment": row[3],
                "rating": row[4],
                "created_at": row[5]
            })
        
        return jsonify({
            "reviews": reviews,
            "average_rating": round(average_rating, 1),
            "total_reviews": total_reviews
        }), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/reviews', methods=['POST'])
@token_required
def add_review():
    """Adds a new review to the database."""
    data = request.json
    if not data or not all(k in data for k in ("product_id", "comment")):
        return jsonify({"error": "Missing required fields"}), 400

    # User info comes from verified token
    user_id = request.user['uid']
    user_name = request.user.get('name', request.user.get('email', 'Anonymous'))

    # Try to get name from Firestore for better accuracy
    try:
        from firebase_admin import firestore
        db = firestore.client()
        user_doc = db.collection('users').document(user_id).get()
        if user_doc.exists:
            user_doc_data = user_doc.to_dict()
            user_name = user_doc_data.get('name', user_name)
    except Exception as e:
        print(f"Error fetching Firestore name: {e}")

    try:
        conn = sqlite3.connect(DB_FILE)
        cursor = conn.cursor()
        
        # Check if user already reviewed this product
        cursor.execute(
            "SELECT id FROM reviews WHERE product_id = ? AND user_id = ?",
            (data['product_id'], user_id)
        )
        if cursor.fetchone():
            conn.close()
            return jsonify({"error": "You have already reviewed this product"}), 409

        cursor.execute(
            "INSERT INTO reviews (product_id, user_id, user_name, comment, rating) VALUES (?, ?, ?, ?, ?)",
            (data['product_id'], user_id, user_name, data['comment'], data.get('rating', 5))
        )
        conn.commit()
        conn.close()
        return jsonify({"message": "Review added successfully"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/reviews/<int:review_id>', methods=['PUT'])
@token_required
def update_review(review_id):
    """Updates an existing review."""
    data = request.json
    if not data or "comment" not in data:
        return jsonify({"error": "Missing comment field"}), 400

    user_id = request.user['uid']

    try:
        conn = sqlite3.connect(DB_FILE)
        cursor = conn.cursor()
        
        # Verify ownership
        cursor.execute("SELECT user_id FROM reviews WHERE id = ?", (review_id,))
        row = cursor.fetchone()
        if not row:
            conn.close()
            return jsonify({"error": "Review not found"}), 404
        
        if row[0] != user_id:
            conn.close()
            return jsonify({"error": "Unauthorized: You don't own this review"}), 403

        cursor.execute(
            "UPDATE reviews SET comment = ?, rating = ? WHERE id = ?",
            (data['comment'], data.get('rating', 5), review_id)
        )
        
        conn.commit()
        conn.close()
        return jsonify({"message": "Review updated successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/reviews/<int:review_id>', methods=['DELETE'])
@token_required
def delete_review(review_id):
    """Deletes a review."""
    user_id = request.user['uid']
    
    try:
        conn = sqlite3.connect(DB_FILE)
        cursor = conn.cursor()

        # Verify ownership
        cursor.execute("SELECT user_id FROM reviews WHERE id = ?", (review_id,))
        row = cursor.fetchone()
        if not row:
            conn.close()
            return jsonify({"error": "Review not found"}), 404
        
        if row[0] != user_id:
            conn.close()
            return jsonify({"error": "Unauthorized: You don't own this review"}), 403

        cursor.execute("DELETE FROM reviews WHERE id = ?", (review_id,))
        conn.commit()
        conn.close()
        return jsonify({"message": "Review deleted successfully"}), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # Running locally for testing
    app.run(host='0.0.0.0', debug=True, port=5000)
