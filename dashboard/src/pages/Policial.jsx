import { useState } from 'react';
import TopBar from '../components/layout/TopBar';

export default function Policial() {
  const [saved, setSaved] = useState(false);

  function guardar() {
    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  }

  const inputStyle = {
    width: '100%', padding: '10px 12px',
    border: '1px solid var(--border)', borderRadius: 8,
    fontSize: 13, background: '#fff',
  };
  const labelStyle = { fontSize: 13, color: 'var(--text-secondary)', display: 'block', marginBottom: 6, marginTop: 14 };

  return (
    <div>
      <TopBar title="Crear reporte policial" />
      <div style={{ padding: 28, maxWidth: 600 }}>
        <div style={{ background: '#E6F1FB', borderRadius: 10, padding: '10px 14px', fontSize: 13, color: '#185FA5', marginBottom: 20 }}>
          Vinculado a reporte ciudadano · Sin registro de identidad
        </div>

        <div style={{ background: '#fff', borderRadius: 12, padding: 24, border: '1px solid var(--border)' }}>
          <label style={labelStyle}>Número de reporte policial</label>
          <input style={{ ...inputStyle, background: 'var(--bg)' }} defaultValue="RP-CHI-2026-0312" readOnly />

          <label style={labelStyle}>Patrulla asignada</label>
          <select style={inputStyle}>
            <option>Patrulla 01 — Centro</option>
            <option>Patrulla 03 — Norte</option>
            <option>Patrulla 05 — Sur</option>
          </select>

          <label style={labelStyle}>Descripción oficial</label>
          <textarea style={{ ...inputStyle, resize: 'vertical' }} rows={3} placeholder="Descripción policial del incidente..." />

          <label style={labelStyle}>Estado del caso</label>
          <select style={inputStyle}>
            <option>En investigación</option>
            <option>Atendido en sitio</option>
            <option>Cerrado</option>
          </select>

          <label style={labelStyle}>Mensaje de retroalimentación al ciudadano</label>
          <textarea style={{ ...inputStyle, resize: 'vertical' }} rows={2} placeholder="El ciudadano verá este mensaje..." />

          {saved && (
            <div style={{ background: '#EAF3DE', color: '#3B6D11', padding: '10px 14px', borderRadius: 8, fontSize: 13, marginTop: 14 }}>
              Reporte policial guardado y ciudadano notificado.
            </div>
          )}

          <button onClick={guardar}
            style={{ marginTop: 20, width: '100%', padding: '12px', background: '#0C447C', color: 'white', border: 'none', borderRadius: 8, fontSize: 14, cursor: 'pointer', fontWeight: 500 }}>
            Guardar reporte policial
          </button>
        </div>
      </div>
    </div>
  );
}