
const admin = require("firebase-admin");
const axios = require("axios");

const serviceAccount =
  require("./serviceAccountKey.json");

admin.initializeApp({
  credential:
    admin.credential.cert(
      serviceAccount
    ),
});

const db = admin.firestore();

const API_KEY = "TU_API_KEY_AQUI";

const ORIGEN = {
  lat: 19.454738,
  lng: -99.174483,
};

/// =========================
/// DISTANCIA REAL
/// =========================
async function distanciaReal(a, b) {

  try {

    const res = await axios.get(
      "https://maps.googleapis.com/maps/api/directions/json",
      {
        params: {
          origin:
            `${a.lat},${a.lng}`,

          destination:
            `${b.latitude},${b.longitude}`,

          key: API_KEY,
        },
      }
    );

    const route =
      res.data.routes?.[0];

    if (!route) {
      return 999999;
    }

    return route.legs[0]
      .distance.value;

  } catch (e) {

    console.log(
      "❌ ERROR DISTANCIA:",
      e.message
    );

    return 999999;
  }
}

/// =========================
/// ORDENAR POR RUTA
/// =========================
async function ordenarPedidos(
  pedidos
) {

  const restantes =
    [...pedidos];

  const ordenados = [];

  let actual = ORIGEN;

  while (
    restantes.length > 0
  ) {

    let mejorIndex = 0;
    let mejorDistancia =
      Infinity;

    for (
      let i = 0;
      i < restantes.length;
      i++
    ) {

      const dist =
        await distanciaReal(
          actual,
          restantes[i].ubicacion
        );

      if (
        dist <
        mejorDistancia
      ) {
        mejorDistancia =
          dist;

        mejorIndex = i;
      }
    }

    const elegido =
      restantes.splice(
        mejorIndex,
        1
      )[0];

    ordenados.push(
      elegido
    );

    actual = {
      lat:
        elegido.ubicacion
          .latitude,

      lng:
        elegido.ubicacion
          .longitude,
    };
  }

  return ordenados;
}

/// =========================
/// AGRUPAR ≤ 10
/// =========================
function agruparPedidos(
  pedidos
) {

  const grupos = [];

  let grupo = [];
  let carga = 0;

  for (const p of pedidos) {

    if (
      carga + p.cantidad <=
      10
    ) {

      grupo.push(p);

      carga += p.cantidad;

    } else {

      grupos.push(grupo);

      grupo = [p];

      carga = p.cantidad;
    }
  }

  if (grupo.length) {
    grupos.push(grupo);
  }

  return grupos;
}

/// =========================
/// FUSIONAR CLIENTES
/// =========================
function fusionarPedidosClientes(
  pedidos
) {

  const mapa = {};

  for (const p of pedidos) {

    const key =
      p.id_cliente;

    /// PRIMER PEDIDO
    if (!mapa[key]) {

      mapa[key] = {

        ...p,

        pedidosOriginales: [
          p.id
        ],
      };

    } else {

      /// SUMAR CANTIDAD
      mapa[key].cantidad +=
        p.cantidad;

      /// GUARDAR IDS
      mapa[key]
        .pedidosOriginales
        .push(p.id);
    }
  }

  return Object.values(
    mapa
  );
}

/// =========================
/// REPARTIDORES
/// =========================
async function obtenerRepartidores() {

  const snap =
    await db
      .collection("users")
      .where(
        "rol",
        "==",
        "repartidor"
      )
      .where(
        "activo",
        "==",
        true
      )
      .where(
        "disponible",
        "==",
        true
      )
      .get();

  return snap.docs.map(
  (doc) => ({

    id: doc.id,

    nombre:
      doc.data().nombre,
  })
);
}

/// =========================
/// PROCESAR
/// =========================
async function procesarPedidos({
  forzar = false,
}) {

  const snap =
    await db
      .collection("orders")
      .where(
        "estado",
        "==",
        "pendiente"
      )
      .where(
        "id_repartidor",
        "==",
        null
      )
      .get();

  const pedidos =
    snap.docs.map(
      (doc) => ({
        id: doc.id,
        ...doc.data(),
      })
    );

  if (
    pedidos.length === 0
  ) return;

  if (
    !forzar &&
    pedidos.length < 5
  ) return;

  console.log(
    "🔥 PROCESANDO:",
    pedidos.length
  );

  const repartidores =
    await obtenerRepartidores();

  if (
    repartidores.length === 0
  ) {

    console.log(
      "❌ SIN REPARTIDORES"
    );

    return;
  }

  ///  FUSIONAR CLIENTES
const fusionados =
  fusionarPedidosClientes(
    pedidos
  );

/// ORDENAR
const ordenados =
  await ordenarPedidos(
    fusionados
  );

  /// AGRUPAR
  const grupos =
    agruparPedidos(
      ordenados
    );

  for (
    const grupo of grupos
  ) {

    if (
      repartidores.length === 0
    ) {
      break;
    }

    const repartidor =
      repartidores.shift();

    const batch =
      db.batch();

    let previousPoint =
      ORIGEN;

    for (
      let i = 0;
      i < grupo.length;
      i++
    ) {

      const pedido =
        grupo[i];

      const ids =
  pedido.pedidosOriginales ??
  [pedido.id];

for (const pedidoId of ids) {

  batch.update(
    db
      .collection(
        "orders"
      )
      .doc(
        pedidoId
      ),
    {

      estado:
        "proceso",

      id_repartidor:
        repartidor.id,

      nombre_repartidor:
        repartidor.nombre,

      orden_ruta: i,

      punto_anterior_lat:
        previousPoint.lat,

      punto_anterior_lng:
        previousPoint.lng,
    }
  );
}

      previousPoint = {
        lat:
          pedido.ubicacion
            .latitude,

        lng:
          pedido.ubicacion
            .longitude,
      };
    }

    ///  REPARTIDOR OCUPADO
    batch.update(
      db
        .collection("users")
        .doc(repartidor.id),
      {
        disponible:
          false,
      }
    );

    await batch.commit();

    console.log(
      `✅ ruta creada → ${repartidor.id}`
    );
  }
}

/// =========================
/// TRIGGERS
/// =========================

setInterval(() => {

  procesarPedidos({
    forzar: false,
  });

}, 10000);

setInterval(() => {

  console.log(
    "⏱ trigger"
  );

  procesarPedidos({
    forzar: true,
  });

}, 3000);