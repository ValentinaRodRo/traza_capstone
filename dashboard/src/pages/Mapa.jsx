import { useEffect, useRef, useState } from 'react';
import TopBar from '../components/layout/TopBar';
import { fetchActiveZones, fetchReports } from '../services/api';

const GOOGLE_MAPS_API_KEY = import.meta.env.VITE_GOOGLE_MAPS_API_KEY;

const RISK_COLORS = {
  bajo:    { fill: '#1D9E75', stroke: '#0F6E56' },
  medio:   { fill: '#EF9F27', stroke: '#BA7517' },
  alto:    { fill: '#E24B4A', stroke: '#A32D2D' },
  critico: { fill: '#7B0000', stroke: '#500000' },
};

function loadGoogleMaps(apiKey) {
  return new Promise((resolve, reject) => {
    if (window.google?.maps) { resolve(); return; }
    if (window._gmLoading) {
      window._gmLoading.then(resolve).catch(reject);
      return;
    }
    const cb = `_gm_cb_${Date.now()}`;
    window._gmLoading = new Promise((res, rej) => {
      window[cb] = () => { delete window[cb]; delete window._gmLoading; res(); resolve(); };
      const s = document.createElement('script');
      // ✅ Sin &libraries=visualization — ya no se usa HeatmapLayer
      s.src = `https://maps.googleapis.com/maps/api/js?key=${apiKey}&callback=${cb}`;
      s.onerror = (e) => { delete window._gmLoading; rej(e); reject(e); };
      document.head.appendChild(s);
    });
  });
}

export default function Mapa() {
  const mapRef         = useRef(null);
  const mapInstance    = useRef(null);
  const heatLayer      = useRef(null);
  const markersRef     = useRef([]);
  const initializedRef = useRef(false);

  const [activeLayer, setActiveLayer] = useState('predictivo');
  const [zones, setZones]             = useState([]);
  const [reports, setReports]         = useState([]);
  const [loading, setLoading]         = useState(true);
  const [error, setError]             = useState('');
  const [selected, setSelected]       = useState(null);

  useEffect(() => {
    async function init() {
      setLoading(true);
      setError('');
      try {
        await loadGoogleMaps(GOOGLE_MAPS_API_KEY);

        if (!mapRef.current) return;

        const map = new window.google.maps.Map(mapRef.current, {
          center: { lat: 4.8626, lng: -74.0321 },
          zoom: 14,
          mapTypeId: 'roadmap',
          styles: [
            { elementType: 'geometry',          stylers: [{ color: '#f5f5f5' }] },
            { elementType: 'labels.icon',        stylers: [{ visibility: 'off' }] },
            { elementType: 'labels.text.fill',   stylers: [{ color: '#616161' }] },
            { elementType: 'labels.text.stroke', stylers: [{ color: '#f5f5f5' }] },
            { featureType: 'road', elementType: 'geometry', stylers: [{ color: '#ffffff' }] },
            { featureType: 'road.arterial', elementType: 'labels.text.fill', stylers: [{ color: '#757575' }] },
            { featureType: 'water', elementType: 'geometry', stylers: [{ color: '#c9c9c9' }] },
          ],
          disableDefaultUI: false,
          zoomControl: true,
          mapTypeControl: false,
          streetViewControl: false,
          fullscreenControl: true,
        });
        mapInstance.current = map;

        const [zonesData, reportsData] = await Promise.all([
          fetchActiveZones(),
          fetchReports().catch(() => []),
        ]);

        const z = zonesData.zones || [];
        const r = reportsData    || [];

        initializedRef.current = true;
        renderLayer(map, markersRef, heatLayer, z, r, 'predictivo', setSelected);

        setZones(z);
        setReports(r);
      } catch (e) {
        console.error(e);
        setError('Error cargando el mapa. Verifica tu API key de Google Maps.');
      } finally {
        setLoading(false);
      }
    }
    init();

    return () => {
      clearMarkers(markersRef, heatLayer);
      mapInstance.current    = null;
      initializedRef.current = false;
    };
  }, []);

  useEffect(() => {
    if (!mapInstance.current || !initializedRef.current) return;
    clearMarkers(markersRef, heatLayer);
    renderLayer(mapInstance.current, markersRef, heatLayer, zones, reports, activeLayer, setSelected);
  }, [activeLayer]);

  return (
    <div style={{ background: '#F5F7FC', minHeight: '100vh' }}>
      <TopBar
        title="Mapa analítico"
        subtitle="Chía, Cundinamarca · Datos en tiempo real"
      />

      <div style={{ padding: 28 }}>
        <div style={{ display: 'flex', gap: 10, marginBottom: 18, alignItems: 'center' }}>
          <span style={{ fontSize: 13, color: '#6B7280', fontWeight: 500 }}>Capa activa:</span>
          {[
            { key: 'predictivo', label: '🔮 Mapa predictivo (ML)' },
            { key: 'reportes',   label: '📍 Reportes reales' },
          ].map(l => (
            <button
              key={l.key}
              onClick={() => setActiveLayer(l.key)}
              style={{
                padding: '8px 16px', borderRadius: 20, fontSize: 13, cursor: 'pointer',
                border: '1px solid', transition: 'all .15s',
                background:  activeLayer === l.key ? '#0C447C' : 'white',
                color:       activeLayer === l.key ? 'white'   : '#4B5563',
                borderColor: activeLayer === l.key ? '#0C447C' : '#E5E7EB',
                fontWeight:  activeLayer === l.key ? 600       : 400,
              }}
            >
              {l.label}
            </button>
          ))}
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 280px', gap: 20 }}>
          <div>
            {error && (
              <div style={{
                padding: '12px 16px', background: '#FEF2F2',
                border: '1px solid #FECACA', borderRadius: 10,
                fontSize: 13, color: '#B91C1C', marginBottom: 14,
              }}>
                ⚠ {error}
              </div>
            )}

            <div style={{ position: 'relative' }}>
              <div
                ref={mapRef}
                style={{
                  height: 520, borderRadius: 14, overflow: 'hidden',
                  border: '1px solid #E5E7EB', background: '#E5E7EB',
                }}
              />
              {loading && (
                <div style={{
                  position: 'absolute', inset: 0,
                  display: 'flex', alignItems: 'center', justifyContent: 'center',
                  background: 'rgba(245,247,252,0.8)', borderRadius: 14,
                  fontSize: 13, color: '#6B7280',
                }}>
                  Cargando mapa…
                </div>
              )}
            </div>

            <div style={{ marginTop: 12, display: 'flex', alignItems: 'center', gap: 16, flexWrap: 'wrap' }}>
              {Object.entries(RISK_COLORS).map(([k, v]) => (
                <div key={k} style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 12, color: '#6B7280' }}>
                  <div style={{ width: 12, height: 12, borderRadius: '50%', background: v.fill }} />
                  <span style={{ textTransform: 'capitalize' }}>{k}</span>
                </div>
              ))}
              <span style={{ fontSize: 11, color: '#9CA3AF', marginLeft: 'auto' }}>
                {activeLayer === 'predictivo'
                  ? `${zones.length} zonas · ML actualiza cada 5 min`
                  : `${reports.length} reportes activos`}
              </span>
            </div>
          </div>

          <div style={{ display: 'flex', flexDirection: 'column', gap: 14 }}>
            {selected ? (
              <div style={{ background: 'white', borderRadius: 14, padding: 18, border: '1px solid #E5E7EB' }}>
                <div style={{ fontSize: 13, fontWeight: 700, color: '#111827', marginBottom: 12 }}>Zona seleccionada</div>
                <div style={{ fontSize: 16, fontWeight: 700, color: '#0C447C', marginBottom: 8 }}>{selected.name}</div>
                <div style={{
                  display: 'inline-flex', alignItems: 'center', gap: 6, padding: '4px 10px',
                  background: (RISK_COLORS[selected.risk_level]?.fill || '#9CA3AF') + '20',
                  borderRadius: 20, marginBottom: 12,
                }}>
                  <div style={{ width: 8, height: 8, borderRadius: '50%', background: RISK_COLORS[selected.risk_level]?.fill || '#9CA3AF' }} />
                  <span style={{ fontSize: 12, fontWeight: 600, color: RISK_COLORS[selected.risk_level]?.fill || '#9CA3AF', textTransform: 'capitalize' }}>
                    {selected.risk_level}
                  </span>
                </div>
                {selected.score !== undefined && (
                  <div>
                    <div style={{ fontSize: 11, color: '#9CA3AF', marginBottom: 4 }}>PUNTAJE DE RIESGO</div>
                    <div style={{ fontSize: 22, fontWeight: 700, color: '#111827' }}>{Math.round(selected.score * 100)}%</div>
                  </div>
                )}
              </div>
            ) : (
              <div style={{ background: 'white', borderRadius: 14, padding: 18, border: '1px solid #E5E7EB', fontSize: 13, color: '#9CA3AF', textAlign: 'center' }}>
                Haz clic en una zona del mapa para ver detalles
              </div>
            )}

            <div style={{ background: 'white', borderRadius: 14, padding: 18, border: '1px solid #E5E7EB' }}>
              <div style={{ fontSize: 13, fontWeight: 700, color: '#111827', marginBottom: 12 }}>
                {activeLayer === 'predictivo' ? 'Zonas de riesgo' : 'Reportes recientes'}
              </div>
              {activeLayer === 'predictivo' ? (
                zones.length === 0
                  ? <div style={{ fontSize: 13, color: '#9CA3AF' }}>Sin datos del ML aún.</div>
                  : zones.sort((a, b) => (b.score || 0) - (a.score || 0)).slice(0, 6).map((z, i) => (
                      <div key={i} style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 }}>
                        <div>
                          <div style={{ fontSize: 13, fontWeight: 500, color: '#374151' }}>{z.name}</div>
                          <div style={{ fontSize: 11, color: '#9CA3AF', textTransform: 'capitalize' }}>{z.risk_level}</div>
                        </div>
                        <div style={{ fontSize: 13, fontWeight: 700, color: RISK_COLORS[z.risk_level]?.fill || '#9CA3AF' }}>
                          {Math.round((z.score || 0) * 100)}%
                        </div>
                      </div>
                    ))
              ) : (
                reports.length === 0
                  ? <div style={{ fontSize: 13, color: '#9CA3AF' }}>Sin reportes.</div>
                  : reports.slice(0, 6).map((r, i) => (
                      <div key={i} style={{ marginBottom: 10 }}>
                        <div style={{ fontSize: 12, fontWeight: 600, color: '#374151' }}>{r.incident_type}</div>
                        <div style={{ fontSize: 11, color: '#9CA3AF' }}>{r.status} · {r.tracking_code}</div>
                      </div>
                    ))
              )}
            </div>

            <div style={{ background: '#EEF4FF', borderRadius: 14, padding: 16, border: '1px solid #BFDBFE' }}>
              <div style={{ fontSize: 12, fontWeight: 700, color: '#1E40AF', marginBottom: 6 }}>🔮 Mapa predictivo</div>
              <div style={{ fontSize: 12, color: '#3B82F6', lineHeight: 1.6 }}>
                Las zonas de riesgo son calculadas por el servicio de ML cada 5 minutos, considerando historial de reportes, tipo de incidente y horario.
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

// ── Helpers ───────────────────────────────────────────────────────────────────

function clearMarkers(markersRef, heatLayer) {
  markersRef.current.forEach(m => m.setMap(null));
  markersRef.current = [];
  if (heatLayer.current) {
    heatLayer.current.setMap(null);
    heatLayer.current = null;
  }
}

function renderLayer(map, markersRef, heatLayer, zones, reports, layer, setSelected) {
  const google = window.google;
  if (!google?.maps) return;

  if (layer === 'predictivo') {
    zones.forEach(z => {
      const lat = z.latitude ?? z.lat;
      const lng = z.longitude ?? z.lng;
      if (!lat || !lng) return;

      const colors = RISK_COLORS[z.risk_level] || RISK_COLORS.bajo;
      const score  = z.score || 0.5;

      // ✅ Círculo tipo heatmap — reemplaza HeatmapLayer deprecado
      const circle = new google.maps.Circle({
        center:        { lat, lng },
        radius:        300 + score * 400,
        map,
        fillColor:     colors.fill,
        fillOpacity:   0.18 + score * 0.22,
        strokeColor:   colors.stroke,
        strokeOpacity: 0.4,
        strokeWeight:  1,
        clickable:     true,
      });
      circle.addListener('click', () => setSelected(z));
      markersRef.current.push(circle);

      // Marcador puntual encima
      const marker = new google.maps.Marker({
        position: { lat, lng },
        map,
        icon: {
          path:         google.maps.SymbolPath.CIRCLE,
          scale:        10,
          fillColor:    colors.fill,
          fillOpacity:  0.9,
          strokeColor:  colors.stroke,
          strokeWeight: 2,
        },
        title: z.name,
      });
      marker.addListener('click', () => setSelected(z));
      markersRef.current.push(marker);
    });

  } else {
    reports.forEach(r => {
      if (!r.latitude || !r.longitude) return;
      const marker = new google.maps.Marker({
        position: { lat: r.latitude, lng: r.longitude },
        map,
        icon: {
          path:         google.maps.SymbolPath.CIRCLE,
          scale:        8,
          fillColor:    '#0C447C',
          fillOpacity:  0.85,
          strokeColor:  '#071E3D',
          strokeWeight: 2,
        },
        title: r.incident_type,
      });
      marker.addListener('click', () =>
        setSelected({ name: r.incident_type, risk_level: 'medio', score: 0.5, ...r })
      );
      markersRef.current.push(marker);
    });
  }
}