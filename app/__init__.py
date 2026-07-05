import os
from flask import Flask
from app.models import db
from flask_cors import CORS
def create_app():

    app = Flask(__name__, static_folder='static', template_folder='templates')

    app.config["SQLALCHEMY_DATABASE_URI"] = os.environ.get("DATABASE_URL","sqlite:///local.db")

    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    db.init_app(app)
    CORS(app, origins=["http://localhost:4200",
    "https://johnsonke11.github.io"])

    with app.app_context():
        db.create_all()
    
    from app.routes import main

    app.register_blueprint(main)

    return app