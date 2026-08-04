from fastapi import APIRouter, WebSocket, WebSocketDisconnect, status
from app.services.websocket_manager import manager
from app.services.auth_service import decode_token

router = APIRouter(tags=["websocket"])


@router.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    """WebSocket endpoint for real-time updates"""
    token = websocket.query_params.get("token")
    try:
        username = decode_token(token or "").get("sub")
    except Exception:
        username = None
    if not username:
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
        return
    await manager.connect(websocket)
    
    try:
        while True:
            data = await websocket.receive_text()
            
            # Parse subscription message
            # Expected format: {"action": "subscribe", "channel": "attendance"}
            try:
                import json
                message = json.loads(data)
                
                if message.get("action") == "subscribe":
                    channel = message.get("channel")
                    if channel:
                        await manager.subscribe(websocket, channel)
                        await websocket.send_text(json.dumps({
                            "type": "subscription_confirmed",
                            "channel": channel
                        }))
            except Exception as e:
                print(f"Error processing message: {e}")
    
    except WebSocketDisconnect:
        manager.disconnect(websocket)
