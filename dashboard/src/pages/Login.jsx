import { useState } from 'react';
import { useAuth } from '../context/AuthContext';

export default function Login() {
  const { login } = useAuth();
  const [email, setEmail]       = useState('');
  const [password, setPassword] = useState('');
  const [error, setError]       = useState('');
  const [loading, setLoading]   = useState(false);
  const [showPass, setShowPass] = useState(false);

  const handleSubmit = async (e) => {
    e.preventDefault();
    setError('');
    setLoading(true);
    try {
      await login(email, password);
    } catch (err) {
      setError(err.message);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div style={styles.root}>
      {/* Left panel — brand */}
      <div style={styles.left}>
        <div style={styles.leftContent}>
          <div style={styles.badge}>SISTEMA INTEGRADO DE SEGURIDAD</div>
          <div style={styles.logoRow}>
            <div style={styles.logoIcon}>
              <svg width="28" height="28" viewBox="0 0 28 28" fill="none">
                <path d="M14 2L3 7v8c0 6.08 4.72 11.76 11 13 6.28-1.24 11-6.92 11-13V7L14 2z" fill="white" fillOpacity="0.18"/>
                <path d="M14 2L3 7v8c0 6.08 4.72 11.76 11 13 6.28-1.24 11-6.92 11-13V7L14 2z" stroke="white" strokeWidth="1.5" strokeLinejoin="round"/>
                <circle cx="14" cy="13" r="3.5" fill="white"/>
              </svg>
            </div>
            <div>
              <div style={styles.logoName}>Traza</div>
              <div style={styles.logoSub}>Est. Policía Nacional · Chía, Cund.</div>
            </div>
          </div>
          <p style={styles.leftDesc}>
            Plataforma de gestión de reportes ciudadanos, análisis de riesgo predictivo y coordinación de patrullaje.
          </p>
          <div style={styles.featureList}>
            {[
              ['🗺', 'Mapa de riesgo en tiempo real'],
              ['📊', 'Inteligencia de negocio y tendencias'],
              ['💬', 'Respuesta directa al ciudadano'],
              ['🔔', 'Alertas automáticas por zona'],
            ].map(([icon, label]) => (
              <div key={label} style={styles.feature}>
                <span style={{ fontSize: 16 }}>{icon}</span>
                <span style={{ fontSize: 13, color: 'rgba(255,255,255,.75)' }}>{label}</span>
              </div>
            ))}
          </div>
        </div>
        <div style={styles.leftFoot}>
          Exclusivo para personal autorizado de la Estación de Policía Chía
        </div>
      </div>

      {/* Right panel — form */}
      <div style={styles.right}>
        <div style={styles.formCard}>
          <div style={styles.formHeader}>
            <div style={styles.formTitle}>Acceso institucional</div>
            <div style={styles.formSub}>Ingrese con sus credenciales asignadas</div>
          </div>

          <form onSubmit={handleSubmit} style={styles.form}>
            <div style={styles.field}>
              <label style={styles.label}>Correo institucional</label>
              <input
                type="email"
                value={email}
                onChange={e => setEmail(e.target.value)}
                placeholder="agente@policia.gov.co"
                required
                style={styles.input}
              />
            </div>

            <div style={styles.field}>
              <label style={styles.label}>Contraseña</label>
              <div style={{ position: 'relative' }}>
                <input
                  type={showPass ? 'text' : 'password'}
                  value={password}
                  onChange={e => setPassword(e.target.value)}
                  placeholder="••••••••"
                  required
                  style={{ ...styles.input, paddingRight: 44 }}
                />
                <button
                  type="button"
                  onClick={() => setShowPass(v => !v)}
                  style={styles.eyeBtn}
                  tabIndex={-1}
                >
                  {showPass ? '🙈' : '👁'}
                </button>
              </div>
            </div>

            {error && (
              <div style={styles.errorBox}>
                <span style={{ fontSize: 15 }}>⚠</span> {error}
              </div>
            )}

            <button
              type="submit"
              disabled={loading}
              style={{ ...styles.submitBtn, opacity: loading ? 0.7 : 1 }}
            >
              {loading ? 'Verificando…' : 'Ingresar al sistema'}
            </button>
          </form>

          <div style={styles.formFoot}>
            ¿Problemas de acceso? Contacte al administrador del sistema.
          </div>
        </div>
      </div>
    </div>
  );
}

const styles = {
  root: {
    display: 'flex', minHeight: '100vh', fontFamily: "'DM Sans', system-ui, sans-serif",
  },
  left: {
    width: 420, background: 'linear-gradient(160deg, #0C447C 0%, #071E3D 100%)',
    display: 'flex', flexDirection: 'column', padding: '48px 44px',
    position: 'relative', flexShrink: 0,
  },
  leftContent: { flex: 1 },
  badge: {
    display: 'inline-block', fontSize: 10, fontWeight: 700, letterSpacing: 1.5,
    color: 'rgba(255,255,255,.55)', border: '1px solid rgba(255,255,255,.2)',
    borderRadius: 4, padding: '4px 10px', marginBottom: 40,
  },
  logoRow: { display: 'flex', alignItems: 'center', gap: 14, marginBottom: 28 },
  logoIcon: {
    width: 52, height: 52, borderRadius: 14,
    background: 'rgba(255,255,255,.12)', display: 'flex', alignItems: 'center', justifyContent: 'center',
  },
  logoName: { color: 'white', fontSize: 26, fontWeight: 700, letterSpacing: -0.5 },
  logoSub: { color: 'rgba(255,255,255,.5)', fontSize: 12, marginTop: 2 },
  leftDesc: { color: 'rgba(255,255,255,.65)', fontSize: 14, lineHeight: 1.7, marginBottom: 36 },
  featureList: { display: 'flex', flexDirection: 'column', gap: 14 },
  feature: {
    display: 'flex', alignItems: 'center', gap: 12,
    background: 'rgba(255,255,255,.07)', borderRadius: 10,
    padding: '10px 14px', border: '1px solid rgba(255,255,255,.1)',
  },
  leftFoot: { fontSize: 11, color: 'rgba(255,255,255,.3)', marginTop: 48, lineHeight: 1.5 },
  right: {
    flex: 1, background: '#F5F7FC', display: 'flex',
    alignItems: 'center', justifyContent: 'center', padding: 32,
  },
  formCard: {
    width: '100%', maxWidth: 420, background: 'white',
    borderRadius: 20, padding: '44px 40px',
    border: '1px solid #E5E7EB',
    boxShadow: '0 4px 32px rgba(12,68,124,.08)',
  },
  formHeader: { marginBottom: 36 },
  formTitle: { fontSize: 24, fontWeight: 700, color: '#111827', letterSpacing: -0.5 },
  formSub: { fontSize: 14, color: '#6B7280', marginTop: 6 },
  form: { display: 'flex', flexDirection: 'column', gap: 20 },
  field: { display: 'flex', flexDirection: 'column', gap: 8 },
  label: { fontSize: 13, fontWeight: 600, color: '#374151' },
  input: {
    width: '100%', padding: '12px 14px', border: '1.5px solid #E5E7EB',
    borderRadius: 10, fontSize: 14, color: '#111827',
    outline: 'none', boxSizing: 'border-box', transition: 'border-color .15s',
    background: '#FAFAFA',
  },
  eyeBtn: {
    position: 'absolute', right: 12, top: '50%', transform: 'translateY(-50%)',
    background: 'none', border: 'none', cursor: 'pointer', fontSize: 16, padding: 4,
  },
  errorBox: {
    display: 'flex', alignItems: 'center', gap: 8, padding: '10px 14px',
    background: '#FEF2F2', border: '1px solid #FECACA', borderRadius: 8,
    fontSize: 13, color: '#B91C1C', fontWeight: 500,
  },
  submitBtn: {
    width: '100%', padding: '14px', background: '#0C447C', color: 'white',
    border: 'none', borderRadius: 12, fontSize: 15, fontWeight: 600,
    cursor: 'pointer', letterSpacing: 0.2, transition: 'all .15s',
    marginTop: 4,
  },
  formFoot: { fontSize: 12, color: '#9CA3AF', textAlign: 'center', marginTop: 28, lineHeight: 1.5 },
};
