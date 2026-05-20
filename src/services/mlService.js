export async function processReport(report) {

  // Convert frontend categories
  const categoryMap = {

    "Hurto": "robo",

    "Comportamiento sospechoso":
      "actividad_sospechosa",

    "Vandalismo":
      "vandalismo",

    "Violencia":
      "violencia",
  };

  // Prepare payload
  const payload = {

    category:
      categoryMap[report.tipo]
      || "actividad_sospechosa",

    description: report.desc,

    latitude: 4.86,

    longitude: -74.03,

    timestamp:
      new Date().toISOString(),
  };

  // Send to ML API
  const response = await fetch(
    "http://127.0.0.1:8001/process-report",
    {
      method: "POST",

      headers: {
        "Content-Type":
          "application/json",
      },

      body: JSON.stringify(
        payload
      ),
    }
  );

  return await response.json();
}