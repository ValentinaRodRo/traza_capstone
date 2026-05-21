from enum import Enum

class ReportStatus(str, Enum):
    RECEIVED = "RECIBIDO"
    IN_REVIEW = "EN_REVISION"
    ATTENDED = "ATENDIDO"
    CLOSED = "CERRADO"