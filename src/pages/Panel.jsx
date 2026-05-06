import TopBar from '../components/layout/TopBar';
import StatCard from '../components/ui/StatCard';
import ReportCard from '../components/ui/ReportCard';
import { reportes, statsData, tendenciaData } from '../data/mockData';
import { BarChart, Bar, XAxis, YAxis, Tooltip, ResponsiveContainer } from 'recharts';

export default function Panel() {
  return (
    <div>
      <TopBar title="Panel de reportes" />
      <div style={{ padding: 28 }}>
        {/* Stats */}
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(4, 1fr)', gap: 16, marginBottom: 28 }}>
          <StatCard num={statsData.nuevosHoy}       label="Nuevos hoy" />
          <StatCard num={statsData.sinAtender}       label="Sin atender" color="#E24B4A" />
          <StatCard num={statsData.esteMes}          label="Este mes" />
          <StatCard num={`${statsData.tasaRespuesta}%`} label="Tasa de respuesta" color="#1D9E75" />
        </div>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 340px', gap: 20 }}>
          {/* Lista */}
          <div>
            <div style={{ fontWeight: 600, marginBottom: 12 }}>Reportes ciudadanos — Anónimos</div>
            {reportes.map(r => <ReportCard key={r.id} reporte={r} />)}
          </div>

          {/* Gráfica */}
          <div style={{ background: '#fff', borderRadius: 12, padding: 20, border: '1px solid var(--border)', height: 'fit-content' }}>
            <div style={{ fontWeight: 600, marginBottom: 16 }}>Tendencia semanal</div>
            <ResponsiveContainer width="100%" height={200}>
              <BarChart data={tendenciaData}>
                <XAxis dataKey="dia" tick={{ fontSize: 12 }} />
                <YAxis tick={{ fontSize: 12 }} />
                <Tooltip />
                <Bar dataKey="reportes" fill="#0C447C" radius={[4, 4, 0, 0]} />
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>
      </div>
    </div>
  );
}