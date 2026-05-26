export default function StatCard({ num, label, color = '#0C447C', delta, icon }) {
  return (
    <div style={s.card}>
      <div style={{ display: 'flex', alignItems: 'flex-start', justifyContent: 'space-between' }}>
        <div>
          <div style={{ ...s.num, color }}>{num}</div>
          <div style={s.label}>{label}</div>
        </div>
        {icon && (
          <div style={{ ...s.iconWrap, background: color + '15' }}>
            <span style={{ fontSize: 18 }}>{icon}</span>
          </div>
        )}
      </div>
      {delta !== undefined && (
        <div style={{ ...s.delta, color: delta >= 0 ? '#E24B4A' : '#1D9E75' }}>
          {delta >= 0 ? '▲' : '▼'} {Math.abs(delta)}% vs ayer
        </div>
      )}
    </div>
  );
}

const s = {
  card: {
    background: 'white', borderRadius: 14, padding: '18px 20px',
    border: '1px solid #E5E7EB',
  },
  num: { fontSize: 32, fontWeight: 700, letterSpacing: -1, lineHeight: 1 },
  label: { fontSize: 13, color: '#6B7280', marginTop: 6, fontWeight: 500 },
  iconWrap: { width: 40, height: 40, borderRadius: 10, display: 'flex', alignItems: 'center', justifyContent: 'center' },
  delta: { fontSize: 11, marginTop: 10, fontWeight: 500 },
};
