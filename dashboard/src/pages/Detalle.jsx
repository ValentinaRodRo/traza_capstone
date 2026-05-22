import { useParams, useNavigate } from 'react-router-dom';
import { useState } from 'react';
import TopBar from '../components/layout/TopBar';
import Badge from '../components/ui/Badge';
import { reportes } from '../data/mockData';

export default function Detalle() {
  const { id } = useParams();
  const navigate = useNavigate();
  const reporte = reportes.find(r => r.id === `#${id}`) || reportes[0];
  const [estado, setEstado] = useState(reporte.estado);
  const [obs, setObs] = useState(reporte.obs || '');
  const [saved, setSaved] = useState(false);

  function guardar() {
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  }

  return (
    <div>
      <TopBar title={`Reporte ${reporte.id}`} />
      <div style={{ padding: 28, maxWidth: 700 }}>
        <button onClick={() => navigate('/')}
          style={{ background: 'none', border: 'none', color: '#0C447C', cursor: 'pointer', marginBottom: 16, fontSize: 14 }}>
          ← Volver al panel
        </button>

        {/* Info */}
        <div style={{ background: '#fff', borderRadius: 12, padding: 24, border: '1px solid var(--border)', marginBottom: 16 }}>
          <div style={{ display: 'flex', gap: 8, marginBottom: 16 }}>
            <Badge estado={estado} />
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, fontSize: 14 }}>
            <div><span style={{ color: 'var(--text-secondary)' }}>Tipo:</span> {reporte.tipo}</div>
            <div><span style={{ color: 'var(--text-secondary)' }}>Hora:</span> {reporte.hora}</div>
            <div><span style={{ color: 'var(--text-secondary)' }}>Ubicación:</span> {reporte.ubicacion}</div>
            <div><span style={{ color: 'var(--text-secondary)' }}>Reportes coincidentes:</span> {reporte.coincidentes}</div>
          </div>
          <div style={{ marginTop: 14, padding: '10px 14px', background: 'var(--bg)', borderRadius: 8, fontSize: 13, color: 'var(--text-secondary)' }}>
            {reporte.desc}
          </div>
        </div>

        {/* Actualizar */}
        <div style={{ background: '#fff', borderRadius: 12, padding: 24, border: '1px solid var(--border)' }}>
          <div style={{ fontWeight: 600, marginBottom: 12 }}>Actualizar estado</div>
          <div style={{ display: 'flex', gap: 8, marginBottom: 20 }}>
            {['Sin atender', 'En proceso', 'Resuelto'].map(e => (
              <button key={e} onClick={() => setEstado(e)}
                style={{
                  padding: '6px 14px', borderRadius: 8, fontSize: 13, cursor: 'pointer',
                  border: estado === e ? '2px solid #0C447C' : '1px solid var(--border)',
                  background: estado === e ? '#E6F1FB' : '#fff',
                  color: estado === e ? '#0C447C' : 'var(--text-secondary)',
                  fontWeight: estado === e ? 500 : 400,
                }}>
                {e}
              </button>
            ))}
          </div>
          <label style={{ fontSize: 13, color: 'var(--text-secondary)', display: 'block', marginBottom: 6 }}>
            Mensaje al ciudadano
          </label>
          <textarea value={obs} onChange={e => setObs(e.target.value)}
            rows={3} placeholder="Ej: Patrulla asignada al sector..."
            style={{ width: '100%', padding: '10px 12px', border: '1px solid var(--border)', borderRadius: 8, fontSize: 13, resize: 'vertical' }} />
          {saved && (
            <div style={{ background: '#EAF3DE', color: '#3B6D11', padding: '8px 12px', borderRadius: 8, fontSize: 13, marginTop: 10 }}>
              Estado actualizado. Ciudadano notificado.
            </div>
          )}
          <button onClick={guardar}
            style={{ marginTop: 14, padding: '10px 24px', background: '#0C447C', color: 'white', border: 'none', borderRadius: 8, fontSize: 14, cursor: 'pointer' }}>
            Guardar y notificar
          </button>
          <button onClick={() => navigate('/policial')}
            style={{ marginTop: 10, marginLeft: 10, padding: '10px 24px', background: 'transparent', color: '#0C447C', border: '1px solid #0C447C', borderRadius: 8, fontSize: 14, cursor: 'pointer' }}>
            Crear reporte policial
          </button>
        </div>
      </div>
    </div>
  );
}