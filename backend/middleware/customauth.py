from flask import request, g, jsonify
from functools import wraps
from backend.models import User, SessionToken

def require_auth(f):
    """Decorator for token validation"""
    @wraps(f)
    def decorated_function(*args, **kwargs):
        token = extract_token_from_header()
        
        if not token:
            return jsonify({'error': 'Missing token'}), 401
        
        session = SessionToken.query.filter_by(token=token).first()
        
        if not session or not session.is_valid():
            return jsonify({'error': 'Invalid or expired token'}), 401

        # Get user from database
        user = User.query.get(session.user_id)

        if not user:
            return jsonify({'error': 'User not found'}), 401
        
        g.user = user
        g.token = token
        g.session = session

        return f(*args, **kwargs)
    
    return decorated_function


def extract_token_from_header():
    """Extract Bearer token from Authorization header"""
    auth_header = request.headers.get('Authorization', '')
    
    if auth_header.startswith('Bearer '):
        return auth_header[7:]
    
    return None