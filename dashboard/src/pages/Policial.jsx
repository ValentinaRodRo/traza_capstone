import TopBar from '../components/layout/TopBar';

const PATRULLAS = [
  { id: 'P-01', agentes: ['Sgto. Ramírez', 'Ptl. Torres'],   zona: 'Parque Central',  estado: 'Activa',   turno: 'Día (6AM–6PM)'  },
  { id: 'P-02', agentes: ['Ptl. Gómez', 'Ptl. Herrera'],     zona: 'Zona Comercial',  estado: 'Activa',   turno: 'Día (6AM–6PM)'  },
  { id: 'P-03', agentes: ['Sgto. Vargas', 'Ptl. Moreno'],    zona: 'La Capilla',      estado: 'Activa',   turno: 'Día (6AM–6PM)'  },
  { id: 'P-04', agentes: ['Ptl. Castro', 'Ptl. Díaz'],       zona: 'Vía Cajicá',      estado: 'Descanso', turno: 'Noche (6PM–6AM)' },
  { id: 'P-05', agentes: ['Intdt. López'],                    zona: 'Comando Central', estado: 'Comando',  turno: 'Día (6AM–6PM)'  },
];

const ESTADO_STYLE = {
  Activa:   { bg: '#ECFDF5', color: '#065F46', dot: '#1D9E75' },
  Descanso: { bg: '#F3F4F6', color: '#374151', dot: '#9CA3AF' },
  Comando:  { bg: '#EEF4FF', color: '#1E40AF', dot: '#3D6FE8' },
};

export default function Policial() {
  return (
    <div style={{ background: '#F5F7FC', minHeight: '100vh' }}>
      <TopBar
        title="Gestión policial"
        subtitle="Asignación de patrullas · Est. Policía Chía"
      />
      <div style={{ padding: 28 }}>
        {/* Header info */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 14, marginBottom: 28 }}>
          {[
            { label: 'Patrullas activas', val: PATRULLAS.filter(p => p.estado === 'Activa').length, color: '#1D9E75', icon: '🚔' },
            { label: 'Total personal', val: PATRULLAS.reduce((s, p) => s + p.agentes.length, 0), color: '#0C447C', icon: '👮' },
            { label: 'Zonas cubiertas', val: new Set(PATRULLAS.filter(p => p.estado === 'Activa').map(p => p.zona)).size, color: '#3D6FE8', icon: '🗺' },
          ].map(k => (
            <div key={k.label} style={{ background: 'white', borderRadius: 14, padding: '18px 20px', border: '1px solid #E5E7EB', display: 'flex', alignItems: 'center', gap: 16 }}>
              <div style={{ width: 48, height: 48, borderRadius: 12, background: k.color + '15', display: 'flex', alignItems: 'center', justifyContent: 'center', fontSize: 22 }}>
                {k.icon}
              </div>
              <div>
                <div style={{ fontSize: 28, fontWeight: 700, color: k.color, letterSpacing: -1 }}>{k.val}</div>
                <div style={{ fontSize: 13, color: '#6B7280' }}>{k.label}</div>
              </div>
            </div>
          ))}
        </div>

        {/* Patrol table */}
        <div style={{ background: 'white', borderRadius: 14, border: '1px solid #E5E7EB', overflow: 'hidden' }}>
          <div style={{ padding: '18px 22px', borderBottom: '1px solid #F3F4F6' }}>
            <div style={{ fontWeight: 700, fontSize: 15, color: '#111827' }}>Despliegue de patrullas</div>
          </div>

          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead>
              <tr style={{ background: '#F9FAFB' }}>
                {['Patrulla', 'Agentes', 'Zona asignada', 'Turno', 'Estado'].map(h => (
                  <th key={h} style={{ padding: '10px 18px', fontSize: 11, fontWeight: 700, color: '#6B7280', textAlign: 'left', textTransform: 'uppercase', letterSpacing: 0.5 }}>
                    {h}
                  </th>
                ))}
              </tr>
            </thead>
            <tbody>
              {PATRULLAS.map((p, i) => {
                const st = ESTADO_STYLE[p.estado] || ESTADO_STYLE.Descanso;
                return (
                  <tr key={p.id} style={{ borderTop: '1px solid #F3F4F6', background: i % 2 === 0 ? 'white' : '#FAFAFA' }}>
                    <td style={{ padding: '12px 18px', fontFamily: 'monospace', fontSize: 13, fontWeight: 700, color: '#0C447C' }}>
                      {p.id}
                    </td>
                    <td style={{ padding: '12px 18px' }}>
                      {p.agentes.map(a => (
                        <div key={a} style={{ fontSize: 13, color: '#374151' }}>{a}</div>
                      ))}
                    </td>
                    <td style={{ padding: '12px 18px', fontSize: 13, color: '#4B5563' }}>{p.zona}</td>
                    <td style={{ padding: '12px 18px', fontSize: 12, color: '#6B7280' }}>{p.turno}</td>
                    <td style={{ padding: '12px 18px' }}>
                      <span style={{
                        display: 'inline-flex', alignItems: 'center', gap: 6,
                        padding: '4px 10px', borderRadius: 20,
                        background: st.bg, color: st.color, fontSize: 12, fontWeight: 600,
                      }}>
                        <div style={{ width: 7, height: 7, borderRadius: '50%', background: st.dot }} />
                        {p.estado}
                      </span>
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>

        {/* Note */}
        <div style={{ marginTop: 20, background: '#EEF4FF', borderRadius: 12, padding: '14px 18px', border: '1px solid #BFDBFE', fontSize: 13, color: '#1E40AF' }}>
          <strong>Nota:</strong> La asignación de patrullas a reportes se realiza desde el panel de detalle de cada reporte. Las patrullas aquí mostradas son de referencia operacional.
        </div>
      </div>
    </div>
  );
}
