export default function StatCard({ num, label, color = '#0C447C' }) {
  return (
    <div style={{
      background: '#fff', borderRadius: 12,
      padding: '18px 20px', border: '1px solid var(--border)',
    }}>
      <div style={{ fontSize: 32, fontWeight: 600, color }}>{num}</div>
      <div style={{ fontSize: 13, color: 'var(--text-secondary)', marginTop: 4 }}>{label}</div>
    </div>
  );
}