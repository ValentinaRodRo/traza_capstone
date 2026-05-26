import { NavLink, useNavigate } from 'react-router-dom';
import { useAuth } from '../../context/AuthContext';

const links = [
  { to: '/',         icon: '📋', label: 'Panel de reportes' },
  { to: '/alertas',  icon: '🔔', label: 'Alertas'           },
  { to: '/mapa',     icon: '🗺', label: 'Mapa analítico'    },
  { to: '/bi',       icon: '📊', label: 'Inteligencia'      },
  { to: '/policial', icon: '📝', label: 'Policial'          },
];

export default function Sidebar() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  const handleLogout = () => {
    logout();
    navigate('/login');
  };

  const initials = user?.name
    ? user.name.split(' ').map(n => n[0]).join('').slice(0, 2).toUpperCase()
    : 'AG';

  return (
    <aside style={s.aside}>
      {/* Logo */}
      <div style={s.logoWrap}>
        <div style={s.logoIcon}>
          <svg width="20" height="20" viewBox="0 0 28 28" fill="none">
            <path d="M14 2L3 7v8c0 6.08 4.72 11.76 11 13 6.28-1.24 11-6.92 11-13V7L14 2z"
              fill="white" fillOpacity="0.2" stroke="white" strokeWidth="1.5" strokeLinejoin="round"/>
            <circle cx="14" cy="13" r="3.5" fill="white"/>
          </svg>
        </div>
        <div>
          <div style={s.logoName}>Traza</div>
          <div style={s.logoSub}>Centro de Mando</div>
        </div>
      </div>

      {/* Nav */}
      <div style={s.section}>
        <div style={s.sectionLabel}>NAVEGACIÓN</div>
        <nav style={{ display: 'flex', flexDirection: 'column', gap: 2 }}>
          {links.map(l => (
            <NavLink
              key={l.to}
              to={l.to}
              end={l.to === '/'}
              style={({ isActive }) => ({
                ...s.link,
                background: isActive ? 'rgba(255,255,255,.15)' : 'transparent',
                color: isActive ? 'white' : 'rgba(255,255,255,.6)',
                fontWeight: isActive ? 600 : 400,
                borderLeft: isActive ? '3px solid rgba(255,255,255,.8)' : '3px solid transparent',
              })}
            >
              <span style={{ fontSize: 16 }}>{l.icon}</span>
              <span>{l.label}</span>
            </NavLink>
          ))}
        </nav>
      </div>

      <div style={{ flex: 1 }} />

      {/* User */}
      <div style={s.userWrap}>
        <div style={s.avatar}>{initials}</div>
        <div style={{ flex: 1, minWidth: 0 }}>
          <div style={s.userName}>{user?.name || 'Agente'}</div>
          <div style={s.userRole}>Autoridad · Chía</div>
        </div>
        <button onClick={handleLogout} style={s.logoutBtn} title="Cerrar sesión">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="rgba(255,255,255,.5)" strokeWidth="2">
            <path d="M9 21H5a2 2 0 0 1-2-2V5a2 2 0 0 1 2-2h4M16 17l5-5-5-5M21 12H9"/>
          </svg>
        </button>
      </div>
    </aside>
  );
}

const s = {
  aside: {
    width: 230, background: 'linear-gradient(180deg, #0C447C 0%, #071E3D 100%)',
    minHeight: '100vh', display: 'flex', flexDirection: 'column',
    padding: '0 0 20px', position: 'fixed', top: 0, left: 0, zIndex: 100,
  },
  logoWrap: {
    display: 'flex', alignItems: 'center', gap: 12,
    padding: '24px 20px 22px',
    borderBottom: '1px solid rgba(255,255,255,.1)',
  },
  logoIcon: {
    width: 40, height: 40, borderRadius: 10,
    background: 'rgba(255,255,255,.12)', display: 'flex',
    alignItems: 'center', justifyContent: 'center', flexShrink: 0,
  },
  logoName: { color: 'white', fontWeight: 700, fontSize: 17 },
  logoSub: { color: 'rgba(255,255,255,.45)', fontSize: 11, marginTop: 1 },
  section: { padding: '20px 14px 0' },
  sectionLabel: {
    fontSize: 10, fontWeight: 700, letterSpacing: 1.2,
    color: 'rgba(255,255,255,.35)', marginBottom: 8, paddingLeft: 6,
  },
  link: {
    display: 'flex', alignItems: 'center', gap: 10, padding: '9px 12px',
    borderRadius: 8, textDecoration: 'none', fontSize: 13.5,
    transition: 'all .15s',
  },
  userWrap: {
    display: 'flex', alignItems: 'center', gap: 10,
    padding: '14px 16px 0',
    borderTop: '1px solid rgba(255,255,255,.1)', marginTop: 12,
  },
  avatar: {
    width: 34, height: 34, borderRadius: '50%',
    background: 'rgba(255,255,255,.18)', display: 'flex',
    alignItems: 'center', justifyContent: 'center',
    fontSize: 12, fontWeight: 700, color: 'white', flexShrink: 0,
  },
  userName: { color: 'white', fontSize: 13, fontWeight: 600, overflow: 'hidden', textOverflow: 'ellipsis', whiteSpace: 'nowrap' },
  userRole: { color: 'rgba(255,255,255,.45)', fontSize: 11, marginTop: 1 },
  logoutBtn: {
    background: 'none', border: 'none', cursor: 'pointer',
    padding: 4, flexShrink: 0, display: 'flex', alignItems: 'center',
  },
};
