import logging
from datetime import datetime, timezone

from fastapi import APIRouter, Depends, HTTPException, WebSocket, WebSocketDisconnect, status
from fastapi.security import APIKeyHeader

from app.config import ML_SERVICE_API_KEY
from app.schemas.zone_schema import ZonesBroadcast
from app.utils.websocket_manager import ws_manager

logger = logging.getLogger(__name__)

router = APIRouter(tags=["zones"])

# ──────────────────────────────────────────────────────────────────────────────
#  Auth para el endpoint interno (ML → Backend)
# ──────────────────────────────────────────────────────────────────────────────

_api_key_header = APIKeyHeader(name="X-Internal-Key", auto_error=False)


def _require_internal_key(key: str = Depends(_api_key_header)) -> None:
    if not ML_SERVICE_API_KEY or key != ML_SERVICE_API_KEY:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Clave interna inválida",
        )


# ──────────────────────────────────────────────────────────────────────────────
#  WebSocket — clientes Flutter se conectan aquí
# ──────────────────────────────────────────────────────────────────────────────

@router.websocket("/ws/zones")
async def zones_websocket(ws: WebSocket):
    """
    Flutter se conecta aquí y recibe:
    1. La última snapshot inmediatamente (si existe).
    2. Cada broadcast nuevo cuando el ML actualiza las zonas.

    El cliente puede enviar "ping" para mantener la conexión viva;
    el servidor responde "pong".
    """
    # Capturar la identidad exacta del cliente (IP y puerto de origen)
    client_address = f"{ws.client.host}:{ws.client.port}" if ws.client else "Desconocido"
    
    logger.info("🚀 INTENTO DE CONEXIÓN: Entrando desde %s", client_address)
    
    await ws_manager.connect(ws)
    
    logger.info("✅ CONECTADO: [%s] se unió con éxito.", client_address)
    
    try:
        while True:
            data = await ws.receive_text()
            if data.strip().lower() == "ping":
                # logger.info("🏓 PING recibido de [%s]", client_address) # Opcional
                await ws.send_text("pong")
            else:
                logger.info("📩 Mensaje inesperado de [%s]: %s", client_address, data)
                
    except WebSocketDisconnect:
        ws_manager.disconnect(ws)
        logger.warning("❌ CONEXIÓN CERRADA: El cliente [%s] se ha desconectado.", client_address)
        
    except Exception as e:
        logger.error("🚨 ERROR ANÓMALO en cliente [%s]: %s", client_address, str(e))


# ──────────────────────────────────────────────────────────────────────────────
#  REST — snapshot actual (útil al arrancar la app sin WS aún conectado)
# ──────────────────────────────────────────────────────────────────────────────

@router.get("/zones/active", response_model=ZonesBroadcast)
def get_active_zones():
    """
    Devuelve la última snapshot calculada por el ML.
    Flutter puede llamar esto al iniciar para tener datos antes de
    que llegue el primer broadcast por WebSocket.
    """
    snapshot = ws_manager.last_snapshot
    if snapshot is None:
        # Snapshot vacía si el ML aún no ha corrido
        return ZonesBroadcast(zones=[], computed_at=datetime.now(timezone.utc))
    return snapshot


# ──────────────────────────────────────────────────────────────────────────────
#  Endpoint interno — el ML llama esto cada 5 min
# ──────────────────────────────────────────────────────────────────────────────

@router.post(
    "/internal/zones/update",
    status_code=status.HTTP_204_NO_CONTENT,
    dependencies=[Depends(_require_internal_key)],
)
async def update_zones(payload: ZonesBroadcast):
    """
    Recibe la snapshot del ML, la guarda en memoria y la broadcastea
    a todos los clientes WebSocket conectados.

    Solo el ML service puede llamar esto (requiere X-Internal-Key).
    """
    await ws_manager.broadcast(payload)
    logger.info(
        "Zonas actualizadas desde ML. Total zonas: %d", len(payload.zones)
    )