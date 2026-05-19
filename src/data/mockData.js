// src/data/mockData.js
export const reportes = [
  {
    id: '#CHI-2026-0847',
    tipo: 'Hurto',
    ubicacion: 'Parque central',
    desc: 'Persona con capucha arrebató celular cerca a la fuente. Huyó hacia la Carrera 8.',
    estado: 'Sin atender',
    hora: '9:29 AM',
    confianza: 'alta',
    coincidentes: 2,
    obs: '',
  },
  {
    id: '#CHI-2026-0838',
    tipo: 'Comportamiento sospechoso',
    ubicacion: 'Calle 11 con Cra 8',
    desc: 'Grupo rondando vehículos estacionados.',
    estado: 'En proceso',
    hora: '8:46 AM',
    confianza: 'sin-registro',
    coincidentes: 1,
    obs: 'Patrulla 03 asignada al sector.',
  },
  {
    id: '#CHI-2026-0821',
    tipo: 'Vandalismo',
    ubicacion: 'La Capilla',
    desc: 'Grafiti en muro del parque.',
    estado: 'Resuelto',
    hora: '7:30 AM',
    confianza: 'nueva',
    coincidentes: 0,
    obs: 'Atendido por patrulla 01.',
  },
];

export const statsData = {
  nuevosHoy: 12,
  sinAtender: 5,
  esteMes: 47,
  tasaRespuesta: 68,
};

export const alertas = [
  { id: 1, tipo: 'Hurto', zona: 'Parque central', tiempo: 'Hace 2 min', nivel: 'critico', detalle: '2 reportes coincidentes · Ciudadano confiable' },
  { id: 2, tipo: 'Actualización', zona: 'Calle 11 · #CHI-2026-0838', tiempo: 'Hace 43 min', nivel: 'medio', detalle: 'Patrulla 03 asignada · Sin registro' },
  { id: 3, tipo: 'Zona recuperada', zona: 'La Capilla', tiempo: 'Hace 2 h', nivel: 'resuelto', detalle: 'Sin nuevos reportes en últimas 6 h' },
];

export const tendenciaData = [
  { dia: 'Lun', reportes: 6 },
  { dia: 'Mar', reportes: 9 },
  { dia: 'Mié', reportes: 5 },
  { dia: 'Jue', reportes: 11 },
  { dia: 'Vie', reportes: 14 },
  { dia: 'Sáb', reportes: 8 },
  { dia: 'Dom', reportes: 12 },
];