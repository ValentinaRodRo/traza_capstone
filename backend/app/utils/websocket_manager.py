import asyncio
import json
import logging
from datetime import datetime
from typing import Optional

from fastapi import WebSocket

from app.schemas.zone_schema import ZonesBroadcast

logger = logging.getLogger(__name__)


class WebSocketManager:
    """
    Maneja el ciclo de vida de todas las conexiones WebSocket activas
    y el estado en memoria de la última snapshot de zonas.

    Una sola instancia vive en el proceso (singleton en main.py).
    """

    def __init__(self):
        self._connections: set[WebSocket] = set()
        self._last_snapshot: Optional[ZonesBroadcast] = None

    # ──────────────────────────────────────────────
    #  Conexiones
    # ──────────────────────────────────────────────

    async def connect(self, ws: WebSocket) -> None:
        await ws.accept()
        self._connections.add(ws)
        logger.info(
            "WS conectado. Clientes activos: %d", len(self._connections)
        )

        # Envía la última snapshot inmediatamente si existe
        if self._last_snapshot:
            await self._send(ws, self._last_snapshot)

    def disconnect(self, ws: WebSocket) -> None:
        self._connections.discard(ws)
        logger.info(
            "WS desconectado. Clientes activos: %d", len(self._connections)
        )

    # ──────────────────────────────────────────────
    #  Broadcast
    # ──────────────────────────────────────────────

    async def broadcast(self, snapshot: ZonesBroadcast) -> None:
        """
        Guarda la snapshot y la envía a todos los clientes conectados.
        Los clientes que fallen se desconectan limpiamente.
        """
        self._last_snapshot = snapshot
        dead: set[WebSocket] = set()

        await asyncio.gather(
            *[self._send_or_mark(ws, snapshot, dead) for ws in self._connections],
            return_exceptions=True,
        )

        for ws in dead:
            self.disconnect(ws)

        logger.info(
            "Broadcast enviado a %d cliente(s). Zonas: %d",
            len(self._connections),
            len(snapshot.zones),
        )

    async def _send_or_mark(
        self,
        ws: WebSocket,
        snapshot: ZonesBroadcast,
        dead: set[WebSocket],
    ) -> None:
        try:
            await self._send(ws, snapshot)
        except Exception:
            dead.add(ws)

    @staticmethod
    async def _send(ws: WebSocket, snapshot: ZonesBroadcast) -> None:
        payload = snapshot.model_dump_json()
        await ws.send_text(payload)

    # ──────────────────────────────────────────────
    #  Estado
    # ──────────────────────────────────────────────

    @property
    def last_snapshot(self) -> Optional[ZonesBroadcast]:
        return self._last_snapshot

    @property
    def active_connections(self) -> int:
        return len(self._connections)


# Instancia global — importada por routes y main
ws_manager = WebSocketManager()