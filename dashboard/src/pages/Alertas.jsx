import { useEffect, useState } from 'react';
import TopBar from '../components/layout/TopBar';
import { fetchReports } from '../services/api';

const LEVELS = {
  RECIBIDO: {
    bg: '#FEF2F2',
    border: '#FECACA',
    dot: '#E24B4A',
    label: 'CRÍTICO',
  },
  EN_REVISION: {
    bg: '#FFFBEB',
    border: '#FCD34D',
    dot: '#EF9F27',
    label: 'ACTIVO',
  },
  ATENDIDO: {
    bg: '#ECFDF5',
    border: '#A7F3D0',
    dot: '#1D9E75',
    label: 'RESUELTO',
  },
  CERRADO: {
    bg: '#F9FAFB',
    border: '#E5E7EB',
    dot: '#9CA3AF',
    label: 'CERRADO',
  },
};

export default function Alertas() {
  const [alerts, setAlerts]           = useState([]);
  const [loading, setLoading]         = useState(true);
  const [filter, setFilter]           = useState('Todos');
  const [searchQuery, setSearchQuery] = useState('');

  useEffect(() => {
    fetchReports()
      .then(data => {
        const sorted = (data || []).sort((a, b) => {
          const order = {
            RECIBIDO: 0,
            EN_REVISION: 1,
            ATENDIDO: 2,
            CERRADO: 3,
          };
          return (order[a.status] ?? 9) - (order[b.status] ?? 9);
        });
        setAlerts(sorted);
      })
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  const filtered = (filter === 'Todos' ? alerts : alerts.filter(a => a.status === filter))
    .filter(a => {
      if (!searchQuery) return true;
      const q = searchQuery.toLowerCase();
      return (
        a.incident_type?.toLowerCase().includes(q) ||
        a.description?.toLowerCase().includes(q) ||
        a.tracking_code?.toLowerCase().includes(q)
      );
    });

  return (
    <div style={{ background: '#F5F7FC', minHeight: '100vh' }}>
      <TopBar
        title="Centro de alertas"
        subtitle="Monitoreo en tiempo real · Chía, Cundinamarca"
      />
      <div style={{ padding: 28 }}>
        {/* Summary badges */}
        <div style={{ display: 'flex', gap: 12, marginBottom: 16, flexWrap: 'wrap' }}>
          {['Todos', 'Sin atender', 'En proceso', 'Resuelto'].map(f => {
            const count = f === 'Todos' ? alerts.length : alerts.filter(a => a.status === f).length;
            const cfg = LEVELS[f] || { dot: '#9CA3AF', bg: '#F3F4F6' };
            return (
              <button
                key={f}
                onClick={() => setFilter(f)}
                style={{
                  display: 'flex', alignItems: 'center', gap: 8,
                  padding: '8px 16px', borderRadius: 20, border: '1px solid',
                  cursor: 'pointer', fontSize: 13, transition: 'all .15s',
                  background: filter === f ? cfg.dot : 'white',
                  color: filter === f ? 'white' : '#4B5563',
                  borderColor: filter === f ? cfg.dot : '#E5E7EB',
                  fontWeight: filter === f ? 600 : 400,
                }}
              >
                {f !== 'Todos' && (
                  <div style={{ width: 8, height: 8, borderRadius: '50%', background: filter === f ? 'white' : cfg.dot }} />
                )}
                {f} <span style={{ opacity: 0.8 }}>({count})</span>
              </button>
            );
          })}
        </div>

        {/* Search bar */}
        <div style={{ position: 'relative', marginBottom: 20 }}>
          <span style={s.searchIcon}>🔍</span>
          <input
            type="text"
            placeholder="Buscar por tipo, descripción o código…"
            value={searchQuery}
            onChange={e => setSearchQuery(e.target.value)}
            style={s.searchInput}
          />
          {searchQuery && (
            <button onClick={() => setSearchQuery('')} style={s.clearBtn}>✕</button>
          )}
        </div>

        {loading ? (
          <div style={{ padding: 40, textAlign: 'center', color: '#9CA3AF', fontSize: 14 }}>Cargando alertas…</div>
        ) : filtered.length === 0 ? (
          <div style={{ padding: 40, textAlign: 'center', color: '#9CA3AF', fontSize: 14 }}>No hay alertas con este filtro.</div>
        ) : (
          <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
            {filtered.map((a, i) => {
              const cfg = LEVELS[a.status] || LEVELS['CERRADO'];
              return (
                <div
                  key={a.id ?? a.tracking_code ?? i}
                  style={{
                    background: cfg.bg, border: `1px solid ${cfg.border}`,
                    borderRadius: 12, padding: '14px 18px',
                    borderLeft: `4px solid ${cfg.dot}`,
                    display: 'grid', gridTemplateColumns: '12px 1fr auto',
                    gap: 14, alignItems: 'flex-start',
                  }}
                >
                  {/* Dot */}
                  <div style={{ width: 10, height: 10, borderRadius: '50%', background: cfg.dot, marginTop: 4 }} />

                  {/* Content */}
                  <div>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 4 }}>
                      <span style={{ fontSize: 14, fontWeight: 700, color: '#111827' }}>{a.incident_type}</span>
                      <span style={{ fontSize: 10, fontWeight: 700, padding: '2px 8px', borderRadius: 20, background: cfg.dot + '20', color: cfg.dot }}>
                        {cfg.label}
                      </span>
                    </div>
                    <div style={{ fontSize: 13, color: '#4B5563', marginBottom: 4 }}>{a.description}</div>
                    <div style={{ fontSize: 11, color: '#9CA3AF' }}>
                      {a.tracking_code} · {a.anonymous ? '🎭 Anónimo' : '✅ Registrado'}
                      {a.created_at && ` · ${new Date(a.created_at).toLocaleString('es-CO')}`}
                    </div>
                  </div>

                  {/* Actions */}
                  <div style={{ display: 'flex', flexDirection: 'column', gap: 6, alignItems: 'flex-end' }}>
                    <a
                      href={`/detalle/${a.tracking_code}`}
                      style={{
                        padding: '6px 14px', background: '#0C447C', color: 'white',
                        borderRadius: 8, fontSize: 12, fontWeight: 600, textDecoration: 'none',
                        whiteSpace: 'nowrap',
                      }}
                    >
                      Atender →
                    </a>
                  </div>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}

const s = {
  searchIcon: {
    position: 'absolute', left: 12, top: '50%', transform: 'translateY(-50%)',
    fontSize: 15, color: '#9CA3AF', pointerEvents: 'none',
  },
  searchInput: {
    width: '100%', padding: '9px 40px',
    border: '1px solid #E5E7EB', borderRadius: 10,
    fontSize: 13, color: '#111827', background: '#F9FAFB',
    outline: 'none', boxSizing: 'border-box',
  },
  clearBtn: {
    position: 'absolute', right: 10, top: '50%', transform: 'translateY(-50%)',
    background: 'none', border: 'none', cursor: 'pointer',
    color: '#9CA3AF', fontSize: 13, padding: '2px 6px',
  },
};