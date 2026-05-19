export default function Badge({ estado }) {
  const map = {
    'Sin atender': { bg: '#FCEBEB', color: '#A32D2D' },
    'En proceso':  { bg: '#FAEEDA', color: '#854F0B' },
    'Resuelto':    { bg: '#EAF3DE', color: '#3B6D11' },
  };
  const s = map[estado] || { bg: '#E6F1FB', color: '#185FA5' };
  return (
    <span style={{
      background: s.bg, color: s.color,
      padding: '2px 10px', borderRadius: 12,
      fontSize: 12, fontWeight: 500,
    }}>
      {estado}
    </span>
  );
}