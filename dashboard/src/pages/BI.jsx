import { useEffect, useState } from 'react';
import TopBar from '../components/layout/TopBar';
import { fetchReports } from '../services/api';
import {
  BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer,
  CartesianGrid, LineChart, Line, PieChart, Pie, Cell, Legend,
  AreaChart, Area,
} from 'recharts';

const COLORS = ['#0C447C', '#3D6FE8', '#1D9E75', '#EF9F27', '#E24B4A', '#7F77DD'];
const HOUR_LABELS = Array.from({ length: 24 }, (_, i) => `${String(i).padStart(2, '0')}h`);

export default function BI() {
  const [reports, setReports] = useState([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    fetchReports()
      .then(data => setReports(data || []))
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  if (loading) {
    return (
      <div style={{ background: '#F5F7FC', minHeight: '100vh' }}>
        <TopBar title="Inteligencia de negocio" />
        <div style={{ padding: 60, textAlign: 'center', color: '#9CA3AF', fontSize: 14 }}>Cargando datos…</div>
      </div>
    );
  }

  // ── Derived analytics ──────────────────────────────────────────────────────

  // By incident type
  const byType = Object.entries(
    reports.reduce((acc, r) => {
      acc[r.incident_type] = (acc[r.incident_type] || 0) + 1;
      return acc;
    }, {})
  ).map(([name, value]) => ({ name, value })).sort((a, b) => b.value - a.value);

  // By status
  const byStatus = Object.entries(
    reports.reduce((acc, r) => {
      acc[r.status] = (acc[r.status] || 0) + 1;
      return acc;
    }, {})
  ).map(([name, value]) => ({ name, value }));

  // By hour
  const byHour = Array(24).fill(0);
  reports.forEach(r => {
    if (r.created_at) {
      const h = new Date(r.created_at).getHours();
      byHour[h]++;
    }
  });
  const hourData = HOUR_LABELS.map((hora, i) => ({ hora, reportes: byHour[i] }));

  // By day of week
  const DAYS = ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb'];
  const byDay = Array(7).fill(0);
  reports.forEach(r => {
    if (r.created_at) byDay[new Date(r.created_at).getDay()]++;
  });
  const dayData = DAYS.map((dia, i) => ({ dia, reportes: byDay[i] }));

  // Monthly trend (last 6 months)
  const monthMap = {};
  reports.forEach(r => {
    if (r.created_at) {
      const d = new Date(r.created_at);
      const key = `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}`;
      monthMap[key] = (monthMap[key] || 0) + 1;
    }
  });
  const monthData = Object.entries(monthMap)
    .sort(([a], [b]) => a.localeCompare(b))
    .slice(-6)
    .map(([mes, total]) => ({ mes: mes.slice(5) + '/' + mes.slice(2, 4), total }));

  // Anonymous vs registered
  const anonCount = reports.filter(r => r.anonymous).length;
  const regCount  = reports.length - anonCount;

  // Resolution rate
  const resolved = reports.filter(r => r.status === 'Resuelto' || r.status === 'Cerrado').length;
  const resRate  = reports.length > 0 ? Math.round(resolved / reports.length * 100) : 0;

  // Peak hour
  const peakHour = byHour.indexOf(Math.max(...byHour));

  // KPI summary
  const kpis = [
    { label: 'Total reportes',     val: reports.length,   icon: '📋', color: '#0C447C' },
    { label: 'Tasa de resolución', val: `${resRate}%`,    icon: '✅', color: '#1D9E75' },
    { label: 'Hora pico',          val: `${peakHour}:00`, icon: '🕐', color: '#EF9F27' },
    { label: 'Anónimos',           val: `${anonCount}`,   icon: '🎭', color: '#7F77DD' },
  ];

  const CustomTooltip = ({ active, payload, label }) => {
    if (!active || !payload?.length) return null;
    return (
      <div style={{ background: 'white', border: '1px solid #E5E7EB', borderRadius: 8, padding: '8px 12px', fontSize: 12 }}>
        <div style={{ fontWeight: 600, marginBottom: 4 }}>{label}</div>
        {payload.map((p, i) => (
          <div key={i} style={{ color: p.color }}>{p.name}: <strong>{p.value}</strong></div>
        ))}
      </div>
    );
  };

  return (
    <div style={{ background: '#F5F7FC', minHeight: '100vh' }}>
      <TopBar
        title="Inteligencia de negocio"
        subtitle="Análisis estadístico · Chía, Cundinamarca"
      />
      <div style={{ padding: 28 }}>
        {/* KPIs */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 14, marginBottom: 28 }}>
          {kpis.map(k => (
            <div key={k.label} style={s.kpiCard}>
              <div style={{ ...s.kpiIcon, background: k.color + '15' }}>
                <span style={{ fontSize: 20 }}>{k.icon}</span>
              </div>
              <div style={{ ...s.kpiNum, color: k.color }}>{k.val}</div>
              <div style={s.kpiLabel}>{k.label}</div>
            </div>
          ))}
        </div>

        {/* Row 1 */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 18, marginBottom: 18 }}>
          {/* By type */}
          <div style={s.card}>
            <div style={s.cardTitle}>Reportes por tipo de incidente</div>
            <ResponsiveContainer width="100%" height={220}>
              <BarChart data={byType} layout="vertical" margin={{ left: 80, right: 20 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#F3F4F6" horizontal={false} />
                <XAxis type="number" tick={{ fontSize: 11, fill: '#9CA3AF' }} />
                <YAxis dataKey="name" type="category" tick={{ fontSize: 11, fill: '#374151' }} width={80} />
                <Tooltip content={<CustomTooltip />} />
                <Bar dataKey="value" name="Reportes" fill="#0C447C" radius={[0, 4, 4, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>

          {/* By status pie */}
          <div style={s.card}>
            <div style={s.cardTitle}>Distribución por estado</div>
            <ResponsiveContainer width="100%" height={220}>
              <PieChart>
                <Pie
                  data={byStatus}
                  cx="50%"
                  cy="50%"
                  innerRadius={55}
                  outerRadius={85}
                  paddingAngle={3}
                  dataKey="value"
                >
                  {byStatus.map((_, i) => (
                    <Cell key={i} fill={COLORS[i % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip formatter={(v, n) => [v, n]} />
                <Legend
                  formatter={(value) => <span style={{ fontSize: 12, color: '#374151' }}>{value}</span>}
                />
              </PieChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Row 2 */}
        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 18, marginBottom: 18 }}>
          {/* Hourly */}
          <div style={s.card}>
            <div style={s.cardTitle}>Incidentes por hora del día</div>
            <ResponsiveContainer width="100%" height={200}>
              <AreaChart data={hourData} margin={{ top: 4, right: 8, left: -20, bottom: 0 }}>
                <defs>
                  <linearGradient id="hourGrad" x1="0" y1="0" x2="0" y2="1">
                    <stop offset="5%" stopColor="#0C447C" stopOpacity={0.15}/>
                    <stop offset="95%" stopColor="#0C447C" stopOpacity={0}/>
                  </linearGradient>
                </defs>
                <CartesianGrid strokeDasharray="3 3" stroke="#F3F4F6" />
                <XAxis dataKey="hora" tick={{ fontSize: 9, fill: '#9CA3AF' }} interval={3} />
                <YAxis tick={{ fontSize: 11, fill: '#9CA3AF' }} />
                <Tooltip content={<CustomTooltip />} />
                <Area type="monotone" dataKey="reportes" name="Reportes" stroke="#0C447C" fill="url(#hourGrad)" strokeWidth={2} />
              </AreaChart>
            </ResponsiveContainer>
            <div style={{ fontSize: 11, color: '#6B7280', marginTop: 8 }}>
              🕐 Hora pico: <strong style={{ color: '#0C447C' }}>{peakHour}:00 – {peakHour + 1}:00</strong>
            </div>
          </div>

          {/* Day of week */}
          <div style={s.card}>
            <div style={s.cardTitle}>Distribución por día de la semana</div>
            <ResponsiveContainer width="100%" height={200}>
              <BarChart data={dayData} margin={{ top: 4, right: 8, left: -20, bottom: 0 }}>
                <CartesianGrid strokeDasharray="3 3" stroke="#F3F4F6" />
                <XAxis dataKey="dia" tick={{ fontSize: 11, fill: '#9CA3AF' }} />
                <YAxis tick={{ fontSize: 11, fill: '#9CA3AF' }} />
                <Tooltip content={<CustomTooltip />} />
                <Bar dataKey="reportes" name="Reportes" fill="#3D6FE8" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Row 3 */}
        <div style={{ display: 'grid', gridTemplateColumns: '2fr 1fr', gap: 18 }}>
          {/* Monthly trend */}
          <div style={s.card}>
            <div style={s.cardTitle}>Tendencia mensual</div>
            {monthData.length === 0 ? (
              <div style={{ fontSize: 13, color: '#9CA3AF', padding: '20px 0' }}>Sin datos históricos suficientes.</div>
            ) : (
              <ResponsiveContainer width="100%" height={200}>
                <LineChart data={monthData} margin={{ top: 4, right: 8, left: -20, bottom: 0 }}>
                  <CartesianGrid strokeDasharray="3 3" stroke="#F3F4F6" />
                  <XAxis dataKey="mes" tick={{ fontSize: 11, fill: '#9CA3AF' }} />
                  <YAxis tick={{ fontSize: 11, fill: '#9CA3AF' }} />
                  <Tooltip content={<CustomTooltip />} />
                  <Line type="monotone" dataKey="total" name="Reportes" stroke="#1D9E75" strokeWidth={2.5} dot={{ r: 4, fill: '#1D9E75' }} />
                </LineChart>
              </ResponsiveContainer>
            )}
          </div>

          {/* Anonymous vs registered */}
          <div style={s.card}>
            <div style={s.cardTitle}>Anonimato</div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 16, marginTop: 8 }}>
              {[
                { label: 'Anónimos', val: anonCount, total: reports.length, color: '#7F77DD' },
                { label: 'Registrados', val: regCount, total: reports.length, color: '#1D9E75' },
              ].map(item => {
                const pct = item.total > 0 ? Math.round(item.val / item.total * 100) : 0;
                return (
                  <div key={item.label}>
                    <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
                      <span style={{ fontSize: 13, color: '#374151' }}>{item.label}</span>
                      <span style={{ fontSize: 13, fontWeight: 700, color: item.color }}>{item.val} ({pct}%)</span>
                    </div>
                    <div style={{ background: '#F3F4F6', borderRadius: 6, height: 10 }}>
                      <div style={{ width: `${pct}%`, background: item.color, borderRadius: 6, height: 10, transition: 'width .6s' }} />
                    </div>
                  </div>
                );
              })}

              <div style={{ background: '#F0FDF4', borderRadius: 10, padding: '12px 14px', marginTop: 4, border: '1px solid #A7F3D0' }}>
                <div style={{ fontSize: 12, fontWeight: 700, color: '#065F46', marginBottom: 4 }}>Tasa de resolución</div>
                <div style={{ fontSize: 28, fontWeight: 700, color: '#1D9E75' }}>{resRate}%</div>
                <div style={{ fontSize: 11, color: '#6EE7B7', marginTop: 2 }}>{resolved} de {reports.length} resueltos</div>
              </div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}

const s = {
  kpiCard: {
    background: 'white', borderRadius: 14, padding: '18px 20px',
    border: '1px solid #E5E7EB', display: 'flex', flexDirection: 'column', gap: 8,
  },
  kpiIcon: { width: 44, height: 44, borderRadius: 10, display: 'flex', alignItems: 'center', justifyContent: 'center' },
  kpiNum: { fontSize: 28, fontWeight: 700, letterSpacing: -1, lineHeight: 1 },
  kpiLabel: { fontSize: 13, color: '#6B7280', fontWeight: 500 },
  card: { background: 'white', borderRadius: 14, padding: '18px 20px', border: '1px solid #E5E7EB' },
  cardTitle: { fontSize: 14, fontWeight: 700, color: '#111827', marginBottom: 14 },
};
