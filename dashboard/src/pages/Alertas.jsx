import TopBar from '../components/layout/TopBar';
import { alertas } from '../data/mockData';

const dotColor = { critico: '#E24B4A', medio: '#EF9F27', resuelto: '#1D9E75' };

export default function Alertas() {
  return (
    <div>
      <TopBar title="Notificaciones en tiempo real" />
      <div style={{ padding: 28, maxWidth: 640 }}>
        <p style={{ fontSize: 13, color: 'var(--text-secondary)', marginBottom: 16 }}>Nuevos reportes — zona Chía</p>
        {alertas.map(a => (
          <div key={a.id} style={{ background: '#fff', borderRadius: 12, padding: '14px 16px', border: '1px solid var(--border)', marginBottom: 10, display: 'flex', gap: 12 }}>
            <div style={{ width: 10, height: 10, borderRadius: '50%', background: dotColor[a.nivel], marginTop: 4, flexShrink: 0 }} />
            <div>
              <div style={{ fontWeight: 500, fontSize: 14 }}>Nuevo reporte — {a.tipo}</div>
              <div style={{ fontSize: 12, color: 'var(--text-secondary)' }}>{a.zona} · {a.tiempo}</div>
              <div style={{ fontSize: 12, marginTop: 4, color: dotColor[a.nivel] }}>{a.detalle}</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}