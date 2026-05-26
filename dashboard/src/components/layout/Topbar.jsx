import { useEffect, useState } from 'react';
import { fetchNotifications } from '../../services/api';

export default function TopBar({ title, subtitle }) {
  const [notifCount, setNotifCount] = useState(0);
  const [time, setTime] = useState(new Date());

  useEffect(() => {
    fetchNotifications().then(n => setNotifCount(n.length)).catch(() => {});
    const t = setInterval(() => setTime(new Date()), 60000);
    return () => clearInterval(t);
  }, []);

  const fmt = (d) =>
    d.toLocaleString('es-CO', { weekday: 'short', day: 'numeric', month: 'short', hour: '2-digit', minute: '2-digit' });

  return (
    <header style={s.bar}>
      <div>
        <div style={s.title}>{title}</div>
        {subtitle && <div style={s.sub}>{subtitle}</div>}
      </div>
      <div style={s.right}>
        <div style={s.time}>{fmt(time)}</div>
        <div style={s.notifWrap}>
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="#6B7280" strokeWidth="2">
            <path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9M13.73 21a2 2 0 0 1-3.46 0"/>
          </svg>
          {notifCount > 0 && <span style={s.badge}>{notifCount}</span>}
        </div>
        <div style={s.dot} />
        <div style={{ fontSize: 13, color: '#6B7280' }}>En línea</div>
      </div>
    </header>
  );
}

const s = {
  bar: {
    height: 60, background: 'white', borderBottom: '1px solid #E5E7EB',
    display: 'flex', alignItems: 'center', justifyContent: 'space-between',
    padding: '0 28px', position: 'sticky', top: 0, zIndex: 50,
  },
  title: { fontSize: 17, fontWeight: 700, color: '#111827' },
  sub: { fontSize: 12, color: '#6B7280', marginTop: 1 },
  right: { display: 'flex', alignItems: 'center', gap: 16 },
  time: { fontSize: 12, color: '#9CA3AF' },
  notifWrap: { position: 'relative', cursor: 'pointer' },
  badge: {
    position: 'absolute', top: -5, right: -5, width: 14, height: 14,
    background: '#E24B4A', borderRadius: '50%', fontSize: 9, fontWeight: 700,
    color: 'white', display: 'flex', alignItems: 'center', justifyContent: 'center',
  },
  dot: { width: 8, height: 8, borderRadius: '50%', background: '#1D9E75' },
};
