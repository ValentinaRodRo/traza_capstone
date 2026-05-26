const COLORS = {
  'RECIBIDO':    { bg: '#FEF2F2', color: '#B91C1C', border: '#FECACA' },
  'EN_REVISION': { bg: '#FFFBEB', color: '#92400E', border: '#FCD34D' },
  'ATENDIDO':    { bg: '#ECFDF5', color: '#065F46', border: '#A7F3D0' },
  'CERRADO':     { bg: '#F3F4F6', color: '#374151', border: '#D1D5DB' },

  'Sin atender': { bg: '#FEF2F2', color: '#B91C1C', border: '#FECACA' },
  'En proceso':  { bg: '#FFFBEB', color: '#92400E', border: '#FCD34D' },
  'Atendido':    { bg: '#ECFDF5', color: '#065F46', border: '#A7F3D0' },
  'Cerrado':     { bg: '#F3F4F6', color: '#374151', border: '#D1D5DB' },

  critico:       { bg: '#FEF2F2', color: '#B91C1C', border: '#FECACA' },
  alto:          { bg: '#FFF7ED', color: '#C2410C', border: '#FED7AA' },
  medio:         { bg: '#FFFBEB', color: '#92400E', border: '#FCD34D' },
  bajo:          { bg: '#ECFDF5', color: '#065F46', border: '#A7F3D0' },
};

const LABELS = {
  'RECIBIDO': 'Sin atender',
  'EN_REVISION': 'En proceso',
  'ATENDIDO': 'Atendido',
  'CERRADO': 'Cerrado',
};

export default function Badge({ text }) {
  const safeText = String(text || '');

  const c = COLORS[safeText] || {
    bg: '#F3F4F6',
    color: '#374151',
    border: '#D1D5DB',
  };

  const label = LABELS[safeText] || safeText || 'Sin estado';

  return (
    <span
      style={{
        fontSize: 11,
        fontWeight: 700,
        padding: '3px 9px',
        borderRadius: 20,
        border: `1px solid ${c.border}`,
        background: c.bg,
        color: c.color,
        letterSpacing: 0.3,
        whiteSpace: 'nowrap',
      }}
    >
      {label}
    </span>
  );
}