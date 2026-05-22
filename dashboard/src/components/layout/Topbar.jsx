export default function TopBar({ title }) {
  return (
    <header style={{
      background: '#fff', borderBottom: '1px solid var(--border)',
      padding: '14px 28px', display: 'flex', justifyContent: 'space-between',
      alignItems: 'center',
    }}>
      <h1 style={{ fontSize: 18, fontWeight: 600 }}>{title}</h1>
      <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
        <span style={{ fontSize: 13, color: 'var(--text-secondary)' }}>
          {new Date().toLocaleDateString('es-CO', { weekday: 'long', day: 'numeric', month: 'long' })}
        </span>
        <div style={{
          width: 32, height: 32, borderRadius: '50%',
          background: '#0C447C', color: 'white',
          display: 'flex', alignItems: 'center', justifyContent: 'center',
          fontSize: 13, fontWeight: 600,
        }}>A</div>
      </div>
    </header>
  );
}