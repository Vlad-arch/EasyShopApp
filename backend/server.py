from flask import Flask, request, jsonify
import sqlite3
import os

app = Flask(__name__)

# --- CONFIGURATION (Specification 10: SQL Storage) ---
DB_FILE = "easyshop_reviews.db"

def init_db():
    """Initializes the SQLite database if it doesn't exist."""
    conn = sqlite3.connect(DB_FILE)
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS reviews (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            product_id TEXT NOT NULL,
            user_name TEXT NOT NULL,
            comment TEXT NOT NULL,
            rating INTEGER DEFAULT 5,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    ''')
    conn.commit()
    conn.close()

# Initialize DB on startup
init_db()

# --- API ENDPOINTS (Specification 9: REST API) ---

@app.route('/reviews/<product_id>', methods=['GET'])
def get_reviews(product_id):
    """Fetches all reviews for a specific product."""
    try:
        conn = sqlite3.connect(DB_FILE)
        cursor = conn.cursor()
        cursor.execute("SELECT user_name, comment, rating, created_at FROM reviews WHERE product_id = ?", (product_id,))
        rows = cursor.fetchall()
        conn.close()

        reviews = []
        for row in rows:
            reviews.append({
                "user_name": row[0],
                "comment": row[1],
                "rating": row[2],
                "created_at": row[3]
            })
        
        return jsonify(reviews), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route('/reviews', methods=['POST'])
def add_review():
    """Adds a new review to the database."""
    data = request.json
    if not data or not all(k in data for k in ("product_id", "user_name", "comment")):
        return jsonify({"error": "Missing required fields"}), 400

    try:
        conn = sqlite3.connect(DB_FILE)
        cursor = conn.cursor()
        cursor.execute(
            "INSERT INTO reviews (product_id, user_name, comment, rating) VALUES (?, ?, ?, ?)",
            (data['product_id'], data['user_name'], data['comment'], data.get('rating', 5))
        )
        conn.commit()
        conn.close()
        return jsonify({"message": "Review added successfully"}), 201
    except Exception as e:
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # Running locally for testing.
    # On PythonAnywhere, you would use their WSGI configuration.
    app.run(debug=True, port=5000)
