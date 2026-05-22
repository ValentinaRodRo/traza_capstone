import { useNavigate } from 'react-router-dom';
import Badge from './Badge';

const borderColor = {
  'Sin atender': '#E24B4A',
  'En proceso': '#EF9F27',
  'Resuelto': '#1D9E75'
};

const confianzaLabel = {
  alta: '★ Ciudadano confiable',
  'sin-registro': 'Sin registro',
  nueva: 'Primera vez'
};

const confianzaStyle = {
  alta: { bg: '#EAF3DE', color: '#166534' },

  'sin-registro': {
    bg: '#F1EFE8',
    color: '#5F5E5A'
  },

  nueva: {
    bg: '#EEEDFE',
    color: '#3C3489'
  },
};

export default function ReportCard({
  reporte,
  aiSeverity,
  aiConfidence
}) {

  const navigate = useNavigate();

  const cs =
    confianzaStyle[reporte.confianza]
    || confianzaStyle.nueva;

  return (

    <div
      onClick={() =>
        navigate(
          `/detalle/${
            reporte.id.replace('#', '')
          }`
        )
      }

      style={{
        background: '#fff',

        borderRadius: 12,

        padding: '14px 16px',

        borderLeft:
          `4px solid ${
            borderColor[reporte.estado]
            || '#ccc'
          }`,

        border: '1px solid var(--border)',

        cursor: 'pointer',

        marginBottom: 10,

        transition: 'box-shadow .15s',
      }}

      onMouseEnter={e =>
        e.currentTarget.style.boxShadow =
        '0 4px 16px rgba(0,0,0,.08)'
      }

      onMouseLeave={e =>
        e.currentTarget.style.boxShadow =
        'none'
      }
    >

      <div
        style={{
          display: 'flex',

          justifyContent:
            'space-between',

          alignItems: 'flex-start'
        }}
      >

        <div>

          <div
            style={{
              display: 'flex',

              gap: 6,

              alignItems: 'center',

              marginBottom: 4
            }}
          >

            <Badge estado={reporte.estado} />

            <span
              style={{
                fontSize: 11,

                padding: '2px 8px',

                borderRadius: 10,

                background: cs.bg,

                color: cs.color
              }}
            >

              {
                confianzaLabel[
                  reporte.confianza
                ]
              }

            </span>

          </div>

          <div
            style={{
              fontWeight: 500,

              fontSize: 14
            }}
          >

            {reporte.tipo}
            {" — "}
            {reporte.ubicacion}

          </div>

          <div
            style={{
              fontSize: 12,

              color:
                'var(--text-secondary)',

              marginTop: 2
            }}
          >

            {reporte.hora}
            {" · "}
            {reporte.id}

          </div>

        </div>

        <span
          style={{
            fontSize: 13,

            color: '#185FA5',

            marginTop: 4
          }}
        >

          Ver →

        </span>

      </div>

      <div
        style={{
          fontSize: 13,

          color:
            'var(--text-secondary)',

          marginTop: 6
        }}
      >

        {reporte.desc}

      </div>

      {/* AI SECTION */}

      <div
        style={{
          marginTop: 10,

          padding: 10,

          borderRadius: 10,

          background: '#F4F8FF',

          fontSize: 12,
        }}
      >

        <div>

          <strong>
            Severidad IA:
          </strong>

          {" "}

          {
            aiSeverity
            || "Analizando..."
          }

        </div>

        <div style={{ marginTop: 4 }}>

          <strong>
            Confianza IA:
          </strong>

          {" "}

          {
            aiConfidence
            || "--"
          }

        </div>

      </div>

    </div>
  );
}