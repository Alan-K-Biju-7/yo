import json
from typing import Set, Dict
from fastapi import WebSocket
from app.schemas.models import WSMessage


class WebSocketConnectionManager:
    def __init__(self):
        self.active_connections: Set[WebSocket] = set()
        self.client_subscriptions: Dict[WebSocket, Set[str]] = {}

    async def connect(self, websocket: WebSocket):
        await websocket.accept()
        self.active_connections.add(websocket)
        self.client_subscriptions[websocket] = set()

    def disconnect(self, websocket: WebSocket):
        if websocket in self.active_connections:
            self.active_connections.remove(websocket)
        if websocket in self.client_subscriptions:
            del self.client_subscriptions[websocket]

    async def subscribe(self, websocket: WebSocket, channel: str):
        """Subscribe a client to a channel"""
        if websocket in self.client_subscriptions:
            self.client_subscriptions[websocket].add(channel)

    async def broadcast_to_channel(self, channel: str, message: WSMessage):
        """Broadcast a message to all clients subscribed to a channel"""
        message_json = message.model_dump_json()
        
        for connection in self.active_connections:
            if channel in self.client_subscriptions.get(connection, set()):
                try:
                    await connection.send_text(message_json)
                except Exception:
                    # Connection might have closed
                    pass

    async def broadcast_to_all(self, message: WSMessage):
        """Broadcast a message to all connected clients"""
        message_json = message.model_dump_json()
        
        disconnected = []
        for connection in self.active_connections:
            try:
                await connection.send_text(message_json)
            except Exception:
                disconnected.append(connection)
        
        # Clean up disconnected clients
        for connection in disconnected:
            self.disconnect(connection)


# Global instance
manager = WebSocketConnectionManager()
