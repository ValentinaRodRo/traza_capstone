import { useEffect, useRef } from 'react';
import L from 'leaflet';
import 'leaflet.heat';
import TopBar from '../components/layout/TopBar';

// Puntos de calor: [lat, lng, intensidad]
// Coordenadas reales de zonas de Chía, Cundinamarca
const heatPoints = [
  // Parque central Chía — CRÍTICO
  [4.8614, -73.9856, 1.0],
  [4.8618, -73.9852, 0.9],
  [4.8610, -73.9860, 0.8],
  [4.8620, -73.9848, 0.7],
  [4.8606, -73.9864, 0.6],
  [4.8622, -73.9858, 0.5],

  // Zona comercial (Calle 11) — ALTO
  [4.8580, -73.9820, 0.7],
  [4.8575, -73.9815, 0.6],
  [4.8585, -73.9825, 0.5],
  [4.8570, -73.9810, 0.4],

  // La Capilla — BAJO
  [4.8650, -73.9900, 0.3],
  [4.8645, -73.9895, 0.2],
  [4.8655, -73.9905, 0.2],
];

const zonas = [
  { nombre: 'Parque central', nivel: 'CRÍTICO', reportes: 23, color: '#E24B4A', lat: 4.8614, lng: -73.9856 },
  { nombre: 'Zona comercial', nivel: 'ALTO',    reportes: 11, color: '#EF9F27', lat: 4.8580, lng: -73.9820 },
  { nombre: 'La Capilla',     nivel: 'BAJO',    reportes: 4,  color: '#1D9E75', lat: 4.8650, lng: -73.9900 },
];

export default function Mapa() {
  const mapRef = useRef(null);
  const mapInstanceRef = useRef(null);

  useEffect(() => {
    if (mapInstanceRef.current) return; // ya inicializado

    const map = L.map(mapRef.current, {
      center: [4.8614, -73.9856],
      zoom: 15,
    });

    L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
      attribution: '© OpenStreetMap contributors',
    }).addTo(map);

    // Capa de calor
    L.heatLayer(heatPoints, {
      radius: 35,
      blur: 25,
      maxZoom: 17,
      gradient: {
        0.2: '#1D9E75',
        0.5: '#EF9F27',
        0.8: '#E24B4A',
        1.0: '#7B0000',
      },
    }).addTo(map);

    // Marcadores por zona
    zonas.forEach(z => {
      const marker = L.circleMarker([z.lat, z.lng], {
        radius: 8,
        fillColor: z.color,
        color: '#fff',
        weight: 2,
        fillOpacity: 0.9,
      }).addTo(map);

      marker.bindPopup(`
        <div style="font-family: sans-serif; min-width: 140px;">
          <div style="font-weight: 600; font-size: 13px; margin-bottom: 4px;">${z.nombre}</div>
          <div style="font-size: 12px; color: ${z.color}; font-weight: 500;">${z.nivel}</div>
          <div style="font-size: 12px; color: #666; margin-top: 2px;">${z.reportes} reportes</div>
        </div>
      `);
    });

    mapInstanceRef.current = map;
  }, []);

  return (
    <div>
      <TopBar title="Mapa analítico" />
      <div style={{ padding: 28 }}>
        <p style={{ fontSize: 13, color: 'var(--text-secondary)', marginBottom: 16 }}>
          Datos agregados — toma de decisiones · Chía, Cundinamarca
        </p>

        {/* Mapa */}
        <div ref={mapRef} style={{ height: 480, borderRadius: 12, overflow: 'hidden', border: '1px solid var(--border)', marginBottom: 16 }} />

        {/* Leyenda */}
        <div style={{ display: 'flex', alignItems: 'center', gap: 8, fontSize: 12, color: 'var(--text-secondary)', marginBottom: 20, maxWidth: 700 }}>
          <span>Bajo</span>
          <div style={{ height: 8, flex: 1, borderRadius: 4, background: 'linear-gradient(to right, #1D9E75, #EF9F27, #E24B4A, #7B0000)' }} />
          <span>Crítico</span>
        </div>

        {/* Recomendación */}
        <div style={{ background: '#fff', borderRadius: 12, padding: 18, border: '1px solid var(--border)', borderLeft: '4px solid #0C447C', maxWidth: 700 }}>
          <div style={{ fontWeight: 600, marginBottom: 6 }}>Recomendación del sistema</div>
          <div style={{ fontSize: 13, color: 'var(--text-secondary)' }}>
            Concentrar patrullaje en Parque central (23 reportes). Reforzar Zona comercial en horario nocturno.
          </div>
        </div>
      </div>
    </div>
  );
}