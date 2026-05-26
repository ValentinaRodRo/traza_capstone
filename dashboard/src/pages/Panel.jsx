import { useEffect, useState, useCallback } from 'react';
import TopBar from '../components/layout/Topbar';
import StatCard from '../components/ui/StatCard';
import ReportCard from '../components/ui/ReportCard';
import { fetchReports, analyzeAllReportsML } from '../services/api';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer, CartesianGrid } from 'recharts';

const STATUS_OPTIONS = [
  { label: 'Todos', value: null },
  { label: 'Sin atender', value: 'RECIBIDO' },
  { label: 'En proceso', value: 'EN_REVISION' },
  { label: 'Resuelto', value: 'ATENDIDO' },
];
const TYPE_OPTIONS   = ['Todos', 'Hurto', 'Comportamiento sospechoso', 'Vandalismo', 'Violencia'];

export default function Panel() {
  const [reportes, setReportes]     = useState([]);
  const [loading, setLoading]       = useState(true);
  const [filterStatus, setFS]       = useState('Todos');
  const [filterType, setFT]         = useState('Todos');
  const [tendencia, setTendencia]   = useState([]);
  const [searchQuery, setSearchQuery] = useState('');

  const load = useCallback(async () => {
    setLoading(true);

    try {
      const status = filterStatus !== 'Todos' ? filterStatus : null;
      const type   = filterType   !== 'Todos' ? filterType   : null;

      // 1. Cargar reportes primero (rápido)
      const data = await fetchReports(status, type);

      // Mostrar inmediatamente con valores IA temporales
      const initialData = data.map(r => ({
        ...r,
        aiSeverity: 'bajo',
        aiConfidence: 0.5,
        aiRiskScore: 0.5,
      }));

      setReportes(initialData);

      // Construir tendencia ya mismo
      const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
      const counts = Array(7).fill(0);

      initialData.forEach(r => {
        if (r.created_at) {
          const d = new Date(r.created_at).getDay();
          counts[d === 0 ? 6 : d - 1]++;
        }
      });

      setTendencia(
        days.map((dia, i) => ({
          dia,
          reportes: counts[i],
        }))
      );

      // Quitar loading YA
      setLoading(false);

      // 2. Ejecutar ML en segundo plano (sin bloquear UI)
      analyzeAllReportsML()
        .then(mlResults => {
          const mlById = Object.fromEntries(
            mlResults.map(r => [r.id, r])
          );

          setReportes(prev =>
            prev.map(r => ({
              ...r,
              aiSeverity:
                mlById[r.id]?.severity || r.aiSeverity,
              aiConfidence:
                mlById[r.id]?.confidence || r.aiConfidence,
              aiRiskScore:
                mlById[r.id]?.risk_score || r.aiRiskScore,
            }))
          );
        })
        .catch(err => {
          console.error('Error ML:', err);
        });

    } catch (e) {
      console.error(e);
      setLoading(false);
    }
  }, [filterStatus, filterType]);

  useEffect(() => { load(); }, [load]);

  const filtered = reportes.filter(r => {
    if (!searchQuery) return true;
    const q = searchQuery.toLowerCase();
    return (
      r.incident_type?.toLowerCase().includes(q) ||
      r.description?.toLowerCase().includes(q) ||
      r.tracking_code?.toLowerCase().includes(q)
    );
  });

  const stats = {
    total:      reportes.length,
    sinAtender: reportes.filter(r => r.status === 'RECIBIDO').length,
    enProceso:  reportes.filter(r => r.status === 'EN_REVISION').length,
    resueltos:  reportes.filter(r => r.status === 'ATENDIDO' || r.status === 'CERRADO').length,
  };

  const tasa = stats.total > 0
    ? Math.round((stats.resueltos / stats.total) * 100) : 0;

  return (
    <div style={{ background: '#F5F7FC', minHeight: '100vh' }}>
      <TopBar
        title="Panel de reportes"
        subtitle={`Chía, Cundinamarca · ${new Date().toLocaleDateString('es-CO', { dateStyle: 'long' })}`}
      />

      <div style={{ padding: 28 }}>
        {/* Stats */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 14, marginBottom: 28 }}>
          <StatCard num={stats.total}      label="Total activos"      icon="📋" color="#0C447C" />
          <StatCard num={stats.sinAtender} label="Sin atender"        icon="🔴" color="#E24B4A" />
          <StatCard num={stats.enProceso}  label="En proceso"         icon="🟡" color="#EF9F27" />
          <StatCard num={`${tasa}%`}       label="Tasa de resolución" icon="✅" color="#1D9E75" />
        </div>

        {/* Filters */}
        <div style={{ display: 'flex', gap: 12, marginBottom: 16, flexWrap: 'wrap' }}>
          <div style={s.filterGroup}>
            <label style={s.filterLabel}>Estado</label>
            <div style={s.pills}>
              {STATUS_OPTIONS.map(o => (
                <button
                  key={o.label}
                  onClick={() => setFS(o.value)}
                  style={{ ...s.pill, ...(filterStatus === o.value ? s.pillActive : {}) }}
                >
                  {o.label}
                </button>
              ))}
            </div>
          </div>
          <div style={s.filterGroup}>
            <label style={s.filterLabel}>Tipo</label>
            <div style={s.pills}>
              {TYPE_OPTIONS.map(o => (
                <button
                  key={o}
                  onClick={() => setFT(o)}
                  style={{ ...s.pill, ...(filterType === o ? s.pillActive : {}) }}
                >
                  {o}
                </button>
              ))}
            </div>
          </div>
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

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 320px', gap: 20, alignItems: 'start' }}>
          {/* Report list */}
          <div>
            <div style={s.sectionHead}>
              <span style={s.sectionTitle}>
                Reportes ciudadanos
                <span style={s.countBadge}>{filtered.length}</span>
              </span>
              <button onClick={load} style={s.refreshBtn}>↺ Actualizar</button>
            </div>

            {loading ? (
              <div style={s.loadingWrap}>
                <div style={s.spinner} />
                <span style={{ fontSize: 13, color: '#9CA3AF' }}>Cargando reportes…</span>
              </div>
            ) : filtered.length === 0 ? (
              <div style={s.empty}>No hay reportes con estos filtros.</div>
            ) : (
              filtered.map(r => (
                <ReportCard key={r.id || r.tracking_code} reporte={r} onStatusChange={load} />
              ))
            )}
          </div>

          {/* Sidebar charts */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
            {/* Trend */}
            <div style={s.chartCard}>
              <div style={s.chartTitle}>Tendencia semanal</div>
              <ResponsiveContainer width="100%" height={180}>
                <BarChart data={tendencia} margin={{ top: 4, right: 4, left: -20, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#F3F4F6" />
                  <XAxis dataKey="dia" tick={{ fontSize: 11, fill: '#9CA3AF' }} />
                  <YAxis tick={{ fontSize: 11, fill: '#9CA3AF' }} />
                  <Tooltip
                    contentStyle={{ borderRadius: 8, border: '1px solid #E5E7EB', fontSize: 12 }}
                    labelStyle={{ fontWeight: 600 }}
                  />
                  <Bar dataKey="reportes" fill="#0C447C" radius={[4, 4, 0, 0]} />
                </BarChart>
              </ResponsiveContainer>
            </div>

            {/* Severity breakdown */}
            <div style={s.chartCard}>
              <div style={s.chartTitle}>Severidad IA</div>
              {['critico', 'alto', 'medio', 'bajo'].map(sev => {
                const n   = reportes.filter(r => r.aiSeverity === sev).length;
                const pct = stats.total > 0 ? Math.round(n / stats.total * 100) : 0;
                const color = { critico: '#E24B4A', alto: '#EF9F27', medio: '#F59E0B', bajo: '#1D9E75' }[sev];
                return (
                  <div key={sev} style={{ marginBottom: 10 }}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', fontSize: 12, marginBottom: 4 }}>
                      <span style={{ color: '#4B5563', textTransform: 'capitalize' }}>{sev}</span>
                      <span style={{ color, fontWeight: 600 }}>{n} ({pct}%)</span>
                    </div>
                    <div style={{ background: '#F3F4F6', borderRadius: 4, height: 6 }}>
                      <div style={{ width: `${pct}%`, background: color, borderRadius: 4, height: 6, transition: 'width .4s' }} />
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

const s = {
  sectionHead:  { display: 'flex', alignItems: 'center', justifyContent: 'space-between', marginBottom: 12 },
  sectionTitle: { fontWeight: 700, fontSize: 15, color: '#111827', display: 'flex', alignItems: 'center', gap: 8 },
  countBadge: {
    background: '#0C447C', color: 'white', fontSize: 11, fontWeight: 700,
    padding: '2px 8px', borderRadius: 20,
  },
  refreshBtn: {
    fontSize: 12, color: '#6B7280', background: 'white', border: '1px solid #E5E7EB',
    borderRadius: 8, padding: '6px 12px', cursor: 'pointer',
  },
  filterGroup:  { display: 'flex', alignItems: 'center', gap: 8 },
  filterLabel:  { fontSize: 12, color: '#6B7280', fontWeight: 500, whiteSpace: 'nowrap' },
  pills:        { display: 'flex', gap: 4, flexWrap: 'wrap' },
  pill: {
    fontSize: 12, padding: '5px 12px', borderRadius: 20,
    border: '1px solid #E5E7EB', background: 'white', color: '#6B7280', cursor: 'pointer',
  },
  pillActive:   { background: '#0C447C', color: 'white', border: '1px solid #0C447C', fontWeight: 600 },
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
  chartCard:    { background: 'white', borderRadius: 14, padding: '18px 16px', border: '1px solid #E5E7EB' },
  chartTitle:   { fontSize: 14, fontWeight: 600, color: '#111827', marginBottom: 14 },
  loadingWrap:  { display: 'flex', alignItems: 'center', gap: 12, padding: 24, color: '#9CA3AF' },
  spinner: {
    width: 20, height: 20, border: '2px solid #E5E7EB',
    borderTopColor: '#0C447C', borderRadius: '50%',
    animation: 'spin 0.8s linear infinite',
  },
  empty: { padding: 32, textAlign: 'center', color: '#9CA3AF', fontSize: 14 },
};
