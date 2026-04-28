from backend.routes.dependecies import (
    Blueprint,
    request,
    db,
    User,
    Friendship,
    error,
    success,
    require_auth
)

friends_bp = Blueprint("friends", __name__)

@friends_bp.get('/<int:user_id>/friends')
@require_auth
def get_friends(user_id):
    """
    Get all the friends for user
    """
    user = User.query.get(user_id)
    if not user:
        error("User not found", 404)
    
    friends = user.get_friends()

    return success(
        {
        'user_id': user_id,
        'friends': [{'id': f.id, 'username': f.username} for f in friends]
        }, 200
    )


@friends_bp.get('/<int:user_id>/friends/pending')
@require_auth
def get_pending_requests(user_id):
    """
    Get all pending friend requests for user
    """
    user = User.query.get(user_id)
    if not user:
        error("User not found", 404)
    
    pending = user.get_pending_requests()

    return success(
        {
        'user_id': user_id,
        'pending_requests': [
            {'id': p.id, 'username': p.username} for p in pending
        ]
        }, 200
    )

@friends_bp.post('/<int:user_id>/friends/request')
@require_auth
def send_friend_request(user_id):
    user = User.query.get(user_id)
    if not user:
        error("User not found", 404)
    
    data = request.json
    friend_id = data.get('friend_id')
    
    friend = User.query.get(friend_id)
    if not friend:
        return {'error': 'Friend not found'}, 404
    
    user.send_friend_request(friend)
    db.session.commit()
    
    return {'success': True, 'message': 'Friend request sent'}, 201


@friends_bp.route('/<int:user_id>/friends/accept', methods=['POST'])
def accept_friend_request(user_id):
    user = User.query.get(user_id)
    if not user:
        return {'error': 'User not found'}, 404
    
    data = request.json
    friend_id = data.get('friend_id')
    
    friend = User.query.get(friend_id)
    if not friend:
        return {'error': 'Friend not found'}, 404
    
    user.accept_friend_request(friend)
    db.session.commit()
    
    return {'success': True, 'message': 'Friend request accepted'}, 200


@friends_bp.route('/<int:user_id>/friends/<int:friend_id>', methods=['DELETE'])
def remove_friend(user_id, friend_id):
    user = User.query.get(user_id)
    if not user:
        return {'error': 'User not found'}, 404
    
    friendship = Friendship.query.filter_by(
        friend_id=friend_id,
        user_id=user_id,
        status='accepted'
    ).first()
    
    if not friendship:
        return {'error': 'Friendship not found'}, 404
    
    db.session.delete(friendship)
    db.session.commit()
    
    return {'success': True, 'message': 'Friend removed'}, 200


@friends_bp.route('/<int:user_id>/friends/<int:friend_id>', methods=['GET'])
def check_friendship(user_id, friend_id):
    friendship = Friendship.query.filter(
        db.or_(
            db.and_(Friendship.user_id == user_id, Friendship.friend_id == friend_id),
            db.and_(Friendship.user_id == friend_id, Friendship.friend_id == user_id)
        ),
        Friendship.status == 'accepted'
    ).first()
    
    is_friend = friendship is not None
    return {'user_id': user_id, 'friend_id': friend_id, 'is_friend': is_friend}, 200