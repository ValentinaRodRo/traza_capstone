const BASE = import.meta.env.VITE_API_URL;
const ML   = import.meta.env.VITE_ML_BASE_URL;

function getToken() {
  return localStorage.getItem('auth_token');
}

function authHeaders() {
  return {
    'Content-Type': 'application/json',
    Authorization: `Bearer ${getToken()}`,
  };
}

// ── Reports ────────────────────────────────────────────────────────────────
export async function fetchReports(status = null, incident_type = null) {
  const params = new URLSearchParams();
  if (status)        params.set('status', status);
  if (incident_type) params.set('incident_type', incident_type);
  const qs = params.toString() ? `?${params}` : '';
  const res = await fetch(`${BASE}/reports/${qs}`, { headers: authHeaders() });
  if (!res.ok) throw new Error('Error cargando reportes');
  return res.json();
}

export async function fetchReportByCode(trackingCode) {
  const res = await fetch(`${BASE}/reports/${trackingCode}`, { headers: authHeaders() });
  if (!res.ok) throw new Error('Error cargando reporte');
  return res.json();
}

export async function updateReportStatus(trackingCode, status, comment) {
  const res = await fetch(`${BASE}/reports/${trackingCode}/status`, {
    method: 'PUT',
    headers: authHeaders(),
    body: JSON.stringify({ status, comment }),
  });
  if (!res.ok) throw new Error('Error actualizando estado');
  return res.json();
}

export async function deleteReport(id) {
  const res = await fetch(`${BASE}/reports/${id}`, {
    method: 'DELETE',
    headers: authHeaders(),
  });
  if (!res.ok) throw new Error('Error eliminando reporte');
  return res.json();
}

export async function fetchReportHistory(trackingCode) {
  const res = await fetch(`${BASE}/reports/${trackingCode}/history`, { headers: authHeaders() });
  if (!res.ok) throw new Error('Error cargando historial');
  return res.json();
}

// ── Zones (ML snapshot) ────────────────────────────────────────────────────
export async function fetchActiveZones() {
  const res = await fetch(`${BASE}/zones/active`);
  if (!res.ok) return { zones: [] };
  return res.json();
}

// ── ML service ─────────────────────────────────────────────────────────────
const categoryMap = {
  'Hurto':                     'robo',
  'Comportamiento sospechoso': 'actividad_sospechosa',
  'Vandalismo':                'vandalismo',
  'Violencia':                 'violencia',
};

export async function processReportML(report) {
  const payload = {
    category:    categoryMap[report.incident_type] || 'actividad_sospechosa',
    description: report.description,
    latitude:    report.latitude  || 4.86,
    longitude:   report.longitude || -74.03,
    timestamp:   report.created_at || new Date().toISOString(),
  };
  try {
    const res = await fetch(`${ML}/process-report`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(payload),
    });
    return await res.json();
  } catch {
    return { severity: 'medio', confidence: 0.5, risk_score: 0.5 };
  }
}

export async function analyzeAllReportsML() {
  try {
    const res = await fetch(`${ML}/analyze-all`);
    if (!res.ok) return [];
    const data = await res.json();
    return data.results || [];
  } catch {
    return [];
  }
}

// ── Notifications ──────────────────────────────────────────────────────────
export async function fetchNotifications() {
  const res = await fetch(`${BASE}/notifications/`, { headers: authHeaders() });
  if (!res.ok) return [];
  return res.json();
}