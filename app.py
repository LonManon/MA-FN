from flask import Flask
from flask import Flask
from flask_cors import CORS
import psycopg2
from flask import Flask, request, jsonify
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import text

app = Flask(__name__)
CORS(app)


@app.route('/')
def hello_world():  # put application's code here
    return 'Hello World!'

app.config['SQLALCHEMY_DATABASE_URI'] = 'mysql+pymysql://root:root123@localhost:3306/ma_api'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

@app.get('/products' )
def get_products():
    try:
        with db.engine.connect() as conn:
            result = conn.execute(text("SELECT * FROM products"))
            column_names = result.keys()
            get_products = []
            for row in result.fetchall():
                products = dict(zip(column_names, row))
                products['image'] = f"{request.host_url}static/PHOTOS/{products['image']}"
                get_products.append(products)

        if not get_products:
            return jsonify({"message": "No products found."}), 404

        return jsonify(get_products), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.get('/get_productsID/<int:id>')
def get_productsID(id):

    try:
        with db.engine.connect() as conn:
            result = conn.execute(text("SELECT * FROM products WHERE id = :id"), {'id': id})
            column_names = result.keys()
            row = result.fetchone()
            if not row:
                return jsonify({"message": "No products found."}), 404
            product = dict(zip(column_names, row))
            product['image'] = f"{request.host_url}static/PHOTOS/{product['image']}"
        
        return jsonify(product), 200
    except Exception as e:
        return jsonify({"error": str(e)}), 500


if __name__ == "__main__":
     app.run(host='0.0.0.0', port=8080 ,debug=True)


#
# if __name__ == '__main__':
#     app.run()
