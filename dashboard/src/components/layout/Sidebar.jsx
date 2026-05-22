import { NavLink } from 'react-router-dom';

const links = [
  { to: '/',         icon: '📋', label: 'Reportes'  },
  { to: '/alertas',  icon: '🔔', label: 'Alertas'   },
  { to: '/mapa',     icon: '🗺', label: 'Mapa'      },
  { to: '/policial', icon: '📝', label: 'Policial'  },
];

export default function Sidebar() {
  return (
    <aside style={{
      width: 220, background: '#0C447C', minHeight: '100vh',
      display: 'flex', flexDirection: 'column', padding: '24px 0',
      position: 'fixed', top: 0, left: 0,
    }}>
      <div style={{ padding: '0 20px 28px', borderBottom: '1px solid rgba(255,255,255,.12)' }}>
        <div style={{ color: 'white', fontWeight: 600, fontSize: 18 }}>SafeChía</div>
        <div style={{ color: 'rgba(255,255,255,.6)', fontSize: 12, marginTop: 2 }}>
          Est. Policía Chía
        </div>
      </div>
      <nav style={{ padding: '16px 12px', flex: 1 }}>
        {links.map(l => (
          <NavLink key={l.to} to={l.to} end={l.to === '/'}
            style={({ isActive }) => ({
              display: 'flex', alignItems: 'center', gap: 10,
              padding: '10px 12px', borderRadius: 8, marginBottom: 4,
              color: isActive ? 'white' : 'rgba(255,255,255,.65)',
              background: isActive ? 'rgba(255,255,255,.15)' : 'transparent',
              textDecoration: 'none', fontSize: 14, fontWeight: isActive ? 500 : 400,
              transition: 'all .15s',
            })}
          >
            <span>{l.icon}</span> {l.label}
          </NavLink>
        ))}
      </nav>
      <div style={{ padding: '16px 20px', borderTop: '1px solid rgba(255,255,255,.12)' }}>
        <div style={{ color: 'rgba(255,255,255,.5)', fontSize: 12 }}>Agente #0042</div>
      </div>
    </aside>
  );
}