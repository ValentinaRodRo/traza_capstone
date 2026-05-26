import { useEffect, useState } from 'react';
import { useParams, useNavigate } from 'react-router-dom';
import TopBar from '../components/layout/Topbar';
import Badge from '../components/ui/Badge';
import { fetchReportByCode, fetchReportHistory, updateReportStatus, processReportML } from '../services/api';

const STATUS_OPTIONS = [
  { label: 'Sin atender', value: 'RECIBIDO' },
  { label: 'En proceso',  value: 'EN_REVISION' },
  { label: 'Atendido',    value: 'ATENDIDO' },
  { label: 'Cerrado',     value: 'CERRADO' },
];

export default function Detalle() {
  const { id } = useParams();
  const navigate = useNavigate();

  const [history, setHistory] = useState([]);
  const [report, setReport]   = useState(null);
  const [ml, setMl]           = useState(null);
  const [loading, setLoading] = useState(true);

  const [newStatus, setNewStatus] = useState('');
  const [comment, setComment]     = useState('');
  const [saving, setSaving]       = useState(false);
  const [saveOk, setSaveOk]       = useState(false);
  const [saveErr, setSaveErr]     = useState('');

  useEffect(() => {
    async function load() {
      setLoading(true);

      try {
        // 1. Ver qué ID está llegando
        console.log('ID recibido:', id);

        // 2. Cargar reporte principal
        const r = await fetchReportByCode(id);

        console.log('Reporte recibido:', r);

        if (!r) {
          console.error('El reporte vino vacío/null');
          return;
        }

        setReport(r);
        setNewStatus(r.status || 'RECIBIDO');

        // 3. Intentar cargar historial
        try {
          const hist = await fetchReportHistory(id);

          console.log(
            'Historial completo:',
            JSON.stringify(hist, null, 2)
          );

          setHistory(
            Array.isArray(hist)
              ? hist
              : Array.isArray(hist.history)
              ? hist.history
              : Array.isArray(hist.data)
              ? hist.data
              : []
          );
        } catch (err) {
          console.error('Error cargando historial:', err);
          setHistory([]);
        }

        // 4. Intentar cargar ML
        try {
          const mlRes = await processReportML(r);

          console.log('ML:', mlRes);

          setMl(mlRes);
        } catch (err) {
          console.error('Error ML:', err);
          setMl(null);
        }

      } catch (e) {
        console.error('ERROR DETALLE:', e);
      } finally {
        console.log('Quitando loading...');
        setLoading(false);
      }
    }

    load();
  }, [id]);

  const handleSave = async () => {
    if (!newStatus) return;
    setSaving(true);
    setSaveErr('');
    try {
      await updateReportStatus(id, newStatus, comment);
      setSaveOk(true);
      setComment('');
      setTimeout(() => setSaveOk(false), 3000);

      const [r, hist] = await Promise.all([
        fetchReportByCode(id),
        fetchReportHistory(id),
      ]);
      setReport(r);
      setNewStatus(r.status);
      setHistory(Array.isArray(hist) ? hist : []);
    } catch (e) {
      setSaveErr(e.message);
    } finally {
      setSaving(false);
    }
  };

  if (loading) {
    return (
      <div style={{ background: '#F5F7FC', minHeight: '100vh' }}>
        <TopBar title="Detalle de reporte" />
        <div style={{ padding: 32, textAlign: 'center', color: '#9CA3AF', fontSize: 14 }}>
          Cargando…
        </div>
      </div>
    );
  }

  const sevColor = { critico: '#E24B4A', alto: '#EF9F27', medio: '#F59E0B', bajo: '#1D9E75' };

  return (
    <div style={{ background: '#F5F7FC', minHeight: '100vh' }}>
      <TopBar
        title={`Reporte ${id}`}
        subtitle="Detalle completo · Respuesta al ciudadano"
      />

      <div style={{ padding: 28 }}>
        <button onClick={() => navigate(-1)} style={s.backBtn}>← Volver al panel</button>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 340px', gap: 20, marginTop: 20 }}>
          {/* Main */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>

            {/* Header card */}
            {report && (
              <div style={s.card}>
                <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'flex-start', marginBottom: 16 }}>
                  <div>
                    <div style={s.code}>{id}</div>
                    <div style={s.tipo}>{report.incident_type || '—'}</div>
                  </div>
                  <Badge text={report.status || 'RECIBIDO'} />
                  {/*<Badge text={report.status || 'RECIBIDO'} />*/}
                  {/*<div>{report.status}</div>*/}
                </div>

                <div style={s.descBox}>
                  <div style={s.fieldLabel}>Descripción del ciudadano</div>
                  <div style={s.descText}>{report.description || '—'}</div>
                </div>

                <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 12, marginTop: 16 }}>
                  <div style={s.metaBlock}>
                    <div style={s.fieldLabel}>Identidad</div>
                    <div style={s.metaVal}>{report.anonymous ? '🎭 Anónimo' : '✅ Registrado'}</div>
                  </div>
                  <div style={s.metaBlock}>
                    <div style={s.fieldLabel}>Coordenadas</div>
                    <div style={s.metaVal}>
                      {report.latitude?.toFixed(4)}, {report.longitude?.toFixed(4)}
                    </div>
                  </div>
                  <div style={s.metaBlock}>
                    <div style={s.fieldLabel}>Fecha</div>
                    <div style={s.metaVal}>
                      {report.created_at ? new Date(report.created_at).toLocaleString('es-CO') : '—'}
                    </div>
                  </div>
                </div>
              </div>
            )}

            {/* Response form */}
            <div style={s.card}>
              <div style={s.cardTitle}><span>💬</span> Responder al ciudadano</div>
              <p style={s.helpText}>
                La respuesta se enviará como notificación a la app del ciudadano y quedará registrada en el historial del reporte.
              </p>

              <div style={s.field}>
                <label style={s.fieldLabel}>Nuevo estado</label>
                <div style={{ display: 'flex', gap: 8, flexWrap: 'wrap' }}>
                  {STATUS_OPTIONS.map(opt => (
                    <button
                      key={opt.value}
                      onClick={() => setNewStatus(opt.value)}
                      style={{
                        ...s.statusPill,
                        background:  newStatus === opt.value ? '#0C447C' : 'white',
                        color:       newStatus === opt.value ? 'white'   : '#4B5563',
                        border:      `1px solid ${newStatus === opt.value ? '#0C447C' : '#E5E7EB'}`,
                        fontWeight:  newStatus === opt.value ? 600       : 400,
                      }}
                    >
                      {opt.label}
                    </button>
                  ))}
                </div>
              </div>

              <div style={s.field}>
                <label style={s.fieldLabel}>
                  Mensaje al ciudadano
                  <span style={{ color: '#9CA3AF', fontWeight: 400, marginLeft: 6 }}>(visible en la app)</span>
                </label>
                <textarea
                  rows={4}
                  value={comment}
                  onChange={e => setComment(e.target.value)}
                  placeholder="Ej: Su reporte fue recibido. La Patrulla 03 fue asignada al sector. Manténgase alerta y no confronte a los sospechosos."
                  style={s.textarea}
                />
                <div style={{ fontSize: 11, color: '#9CA3AF', textAlign: 'right' }}>{comment.length}/500</div>
              </div>

              {saveErr && <div style={s.errorBox}>⚠ {saveErr}</div>}
              {saveOk  && <div style={s.successBox}>✓ Respuesta enviada correctamente</div>}

              <button
                onClick={handleSave}
                disabled={saving || !comment.trim()}
                style={{ ...s.sendBtn, opacity: (saving || !comment.trim()) ? 0.6 : 1 }}
              >
                {saving ? 'Enviando…' : '📤 Enviar respuesta'}
              </button>
            </div>

            {/* History */}
            <div style={s.card}>
              <div style={s.cardTitle}><span>📜</span> Historial del reporte</div>
              {history.length === 0 ? (
                <div style={{ fontSize: 13, color: '#9CA3AF', padding: '8px 0' }}>Sin historial registrado.</div>
              ) : (
                <div style={{ display: 'flex', flexDirection: 'column', gap: 0 }}>
                  {history.map((h, i) => (
                    <div key={i} style={s.histItem}>
                      <div style={s.histDot} />
                      <div style={{ flex: 1 }}>
                        <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 2 }}>
                          <Badge text={h.status || h.new_status || '—'} />
                          <span style={{ fontSize: 11, color: '#9CA3AF' }}>
                            {h.changed_at ? new Date(h.changed_at).toLocaleString('es-CO') : '—'}
                          </span>
                        </div>
                        {h.comment && <div style={{ fontSize: 13, color: '#4B5563', marginTop: 4 }}>{h.comment}</div>}
                      </div>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>

          {/* Right: ML + mapa */}
          <div style={{ display: 'flex', flexDirection: 'column', gap: 16 }}>
            {ml && (
              <div style={s.card}>
                <div style={s.cardTitle}><span>🤖</span> Análisis IA</div>
                <div style={{ display: 'flex', flexDirection: 'column', gap: 14, marginTop: 4 }}>
                  <div>
                    <div style={s.fieldLabel}>Severidad predicha</div>
                    <div style={{
                      display: 'inline-flex', alignItems: 'center', gap: 8,
                      padding: '6px 14px', borderRadius: 8, marginTop: 6,
                      background: (sevColor[ml.severity] || '#9CA3AF') + '20',
                      border: `1px solid ${(sevColor[ml.severity] || '#9CA3AF')}40`,
                    }}>
                      <div style={{ width: 10, height: 10, borderRadius: '50%', background: sevColor[ml.severity] || '#9CA3AF' }} />
                      <span style={{ fontSize: 15, fontWeight: 700, color: sevColor[ml.severity] || '#111827', textTransform: 'capitalize' }}>
                        {ml.severity}
                      </span>
                    </div>
                  </div>

                  <div>
                    <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
                      <span style={s.fieldLabel}>Confianza del modelo</span>
                      <span style={{ fontSize: 13, fontWeight: 700, color: '#0C447C' }}>
                        {Math.round(ml.confidence * 100)}%
                      </span>
                    </div>
                    <div style={{ background: '#F3F4F6', borderRadius: 6, height: 8 }}>
                      <div style={{ width: `${Math.round(ml.confidence * 100)}%`, background: '#0C447C', borderRadius: 6, height: 8, transition: 'width .6s' }} />
                    </div>
                  </div>

                  <div>
                    <div style={{ display: 'flex', justifyContent: 'space-between', marginBottom: 6 }}>
                      <span style={s.fieldLabel}>Puntaje de riesgo</span>
                      <span style={{ fontSize: 13, fontWeight: 700, color: sevColor[ml.severity] || '#111827' }}>
                        {Math.round(ml.risk_score * 100)}%
                      </span>
                    </div>
                    <div style={{ background: '#F3F4F6', borderRadius: 6, height: 8 }}>
                      <div style={{ width: `${Math.round(ml.risk_score * 100)}%`, background: sevColor[ml.severity] || '#EF9F27', borderRadius: 6, height: 8, transition: 'width .6s' }} />
                    </div>
                  </div>

                  {ml.zone && (
                    <div>
                      <div style={s.fieldLabel}>Zona clasificada</div>
                      <div style={{ fontSize: 13, color: '#374151', marginTop: 4, fontWeight: 500 }}>{ml.zone}</div>
                    </div>
                  )}
                </div>
              </div>
            )}

            {report?.latitude && (
              <div style={s.card}>
                <div style={s.cardTitle}><span>📍</span> Ubicación del reporte</div>
                <div style={{ borderRadius: 10, overflow: 'hidden', marginTop: 10, height: 220 }}>
                  <iframe
                    title="Mapa"
                    width="100%"
                    height="220"
                    style={{ border: 0 }}
                    loading="lazy"
                    allowFullScreen
                    src={`https://maps.google.com/maps?q=${report.latitude},${report.longitude}&z=16&output=embed`}
                  />
                </div>
                <div style={{ fontSize: 11, color: '#9CA3AF', marginTop: 8 }}>
                  {report.latitude?.toFixed(6)}, {report.longitude?.toFixed(6)}
                </div>
              </div>
            )}
          </div>
        </div>
      </div>
    </div>
  );
}

const s = {
  backBtn:   { fontSize: 13, color: '#0C447C', background: 'none', border: 'none', cursor: 'pointer', padding: 0, fontWeight: 500 },
  card:      { background: 'white', borderRadius: 14, padding: '20px 22px', border: '1px solid #E5E7EB' },
  cardTitle: { fontSize: 15, fontWeight: 700, color: '#111827', marginBottom: 14, display: 'flex', alignItems: 'center', gap: 8 },
  code:      { fontSize: 12, fontWeight: 700, color: '#9CA3AF', fontFamily: 'monospace', marginBottom: 4 },
  tipo:      { fontSize: 20, fontWeight: 700, color: '#111827' },
  descBox:   { background: '#F9FAFB', borderRadius: 10, padding: '12px 14px', border: '1px solid #F3F4F6' },
  fieldLabel:{ fontSize: 11, fontWeight: 700, color: '#9CA3AF', textTransform: 'uppercase', letterSpacing: 0.5, marginBottom: 6 },
  descText:  { fontSize: 14, color: '#374151', lineHeight: 1.6 },
  metaBlock: { background: '#F9FAFB', borderRadius: 8, padding: '10px 12px' },
  metaVal:   { fontSize: 13, color: '#111827', fontWeight: 500 },
  helpText:  { fontSize: 13, color: '#6B7280', lineHeight: 1.6, marginBottom: 20 },
  field:     { marginBottom: 18 },
  statusPill:{ padding: '7px 14px', borderRadius: 8, fontSize: 13, cursor: 'pointer', transition: 'all .15s' },
  textarea:  { width: '100%', padding: '12px 14px', border: '1.5px solid #E5E7EB', borderRadius: 10, fontSize: 13, color: '#374151', resize: 'vertical', outline: 'none', boxSizing: 'border-box', fontFamily: 'inherit', background: '#FAFAFA', lineHeight: 1.6 },
  sendBtn:   { width: '100%', padding: '13px', background: '#0C447C', color: 'white', border: 'none', borderRadius: 10, fontSize: 14, fontWeight: 600, cursor: 'pointer' },
  errorBox:  { padding: '10px 14px', background: '#FEF2F2', border: '1px solid #FECACA', borderRadius: 8, fontSize: 13, color: '#B91C1C', marginBottom: 12 },
  successBox:{ padding: '10px 14px', background: '#ECFDF5', border: '1px solid #A7F3D0', borderRadius: 8, fontSize: 13, color: '#065F46', marginBottom: 12 },
  histItem:  { display: 'flex', gap: 12, paddingTop: 12, paddingBottom: 12, borderBottom: '1px solid #F3F4F6' },
  histDot:   { width: 10, height: 10, borderRadius: '50%', background: '#0C447C', marginTop: 4, flexShrink: 0 },
};
