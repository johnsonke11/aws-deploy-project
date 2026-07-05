import os
from flask import Flask
from app.models import db

def create_app():

    app = Flask(__name__, static_folder='static', template_folder='templates')

    app.config["SQLALCHEMY_DATABASE_URI"] = os.environ.get("DATABASE_URL","sqlite:///local.db")

    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False

    db.init_app(app)

    with app.app_context():
        db.create_all()
    
    from app.routes import main

    app.register_blueprint(main)

    return app