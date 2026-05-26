import { useState } from 'react';
import { Link } from 'react-router-dom';
import Badge from './Badge';

const SEVERITY_COLOR = {
  bajo:    { bg: '#ECFDF5', color: '#065F46' },
  medio:   { bg: '#FFFBEB', color: '#92400E' },
  alto:    { bg: '#FFF7ED', color: '#C2410C' },
  critico: { bg: '#FEF2F2', color: '#B91C1C' },
};

export default function ReportCard({ reporte, onStatusChange }) {
  const [expanded, setExpanded] = useState(false);
  const sev = SEVERITY_COLOR[reporte.aiSeverity] || SEVERITY_COLOR.medio;

  return (
    <div style={s.card}>
      <div style={s.row} onClick={() => setExpanded(v => !v)}>
        {/* Left */}
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={s.topRow}>
            <span style={s.code}>{reporte.tracking_code || reporte.id}</span>
            <Badge text={reporte.status || reporte.estado} />
            {reporte.aiSeverity && (
              <span style={{ ...s.aiTag, ...sev }}>
                IA: {reporte.aiSeverity} ({Math.round((reporte.aiConfidence || 0) * 100)}%)
              </span>
            )}
          </div>
          <div style={s.tipo}>{reporte.incident_type || reporte.tipo}</div>
          <div style={s.desc}>{reporte.description || reporte.desc}</div>
          <div style={s.meta}>
            📍 {reporte.ubicacion || 'Ubicación reportada'} · 🕐 {reporte.hora || 'Reciente'}
            {reporte.anonymous !== undefined && (
              <span style={{ marginLeft: 8, color: '#9CA3AF' }}>
                · {reporte.anonymous ? '🎭 Anónimo' : '✅ Registrado'}
              </span>
            )}
          </div>
        </div>

        {/* Arrow */}
        <svg
          width="16" height="16" viewBox="0 0 24 24" fill="none"
          stroke="#9CA3AF" strokeWidth="2"
          style={{ transform: expanded ? 'rotate(90deg)' : 'rotate(0)', transition: '.2s', flexShrink: 0 }}
        >
          <polyline points="9 18 15 12 9 6"/>
        </svg>
      </div>

      {/* Expanded */}
      {expanded && (
        <div style={s.expanded}>
          <div style={s.expandedGrid}>
            <div>
              <div style={s.expandLabel}>Observaciones</div>
              <div style={s.expandVal}>{reporte.obs || reporte.comment || '—'}</div>
            </div>
            {reporte.aiRiskScore !== undefined && (
              <div>
                <div style={s.expandLabel}>Puntaje de riesgo IA</div>
                <div style={{ ...s.expandVal, color: '#0C447C', fontWeight: 700 }}>
                  {Math.round(reporte.aiRiskScore * 100)}%
                </div>
              </div>
            )}
          </div>
          <div style={s.actions}>
            <Link
              to={`/detalle/${reporte.tracking_code || reporte.id?.replace('#', '')}`}
              style={s.btnPrimary}
            >
              Ver detalle y responder →
            </Link>
          </div>
        </div>
      )}
    </div>
  );
}

const s = {
  card: {
    background: 'white', borderRadius: 12, border: '1px solid #E5E7EB',
    marginBottom: 10, overflow: 'hidden',
  },
  row: {
    display: 'flex', alignItems: 'flex-start', gap: 12,
    padding: '14px 16px', cursor: 'pointer',
  },
  topRow: { display: 'flex', alignItems: 'center', gap: 8, flexWrap: 'wrap', marginBottom: 4 },
  code: { fontSize: 12, fontWeight: 700, color: '#9CA3AF', fontFamily: 'monospace' },
  tipo: { fontSize: 14, fontWeight: 600, color: '#111827', marginBottom: 4 },
  desc: { fontSize: 13, color: '#4B5563', lineHeight: 1.5, marginBottom: 6 },
  meta: { fontSize: 12, color: '#9CA3AF' },
  aiTag: { fontSize: 11, fontWeight: 600, padding: '2px 8px', borderRadius: 20 },
  expanded: { padding: '0 16px 14px', borderTop: '1px solid #F3F4F6' },
  expandedGrid: { display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 12, paddingTop: 12, marginBottom: 12 },
  expandLabel: { fontSize: 11, fontWeight: 700, color: '#9CA3AF', textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 4 },
  expandVal: { fontSize: 13, color: '#374151' },
  actions: { display: 'flex', gap: 8 },
  btnPrimary: {
    display: 'inline-flex', alignItems: 'center', gap: 6,
    padding: '8px 16px', background: '#0C447C', color: 'white',
    border: 'none', borderRadius: 8, fontSize: 13, fontWeight: 600,
    cursor: 'pointer', textDecoration: 'none',
  },
};
