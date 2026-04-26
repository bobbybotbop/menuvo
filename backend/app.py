from flask import Flask
import os
from backend.models import db
from backend.routes import auth_bp, users_bp
 
def create_app():
    """Create and configure the Flask application."""
    app = Flask(__name__)
    
    # Configuration
    db_filename = "inmybeli.db"
    app.config["SQLALCHEMY_DATABASE_URI"] = os.getenv(
        "DATABASE_URL", 
        f"sqlite:///{db_filename}"
    )
    app.config["SQLALCHEMY_TRACK_MODIFICATIONS"] = False
    app.config["SQLALCHEMY_ECHO"] = False
    
    # Initialize database
    db.init_app(app)
    
    with app.app_context():
        db.create_all()
    
    # Register blueprints
    app.register_blueprint(auth_bp, url_prefix="/api")
    app.register_blueprint(users_bp, url_prefix="/api")
    
    return app
 
if __name__ == "__main__":
    app = create_app()
    app.run(debug=True)
 