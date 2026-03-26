# Endpoints de Cuentas

Base URL: `http://localhost:3000/api/cuentas`

Todos los endpoints requieren autenticación JWT:
```
Authorization: Bearer <token>
```

---

## GET `/cuentas`

Lista todas las cuentas del usuario autenticado.

**Ejemplo de petición:**
```
GET /api/cuentas
```

**Respuesta 200:**
```json
[
  {
    "id": 2,
    "numero_cuenta": "4010000000000002",
    "tipo": "corriente",
    "saldo": 32500.50,
    "limite_credito": null,
    "moneda": "MXN",
    "estado": "activa",
    "credito_disponible": null
  }
]
```

> `credito_disponible` solo aplica para cuentas de tipo `orbe`, `silverstone` e `imperium` con `limite_credito` definido. En cuentas de ahorro/corriente retorna `null`.

---

## GET `/cuentas/:id`

Devuelve el detalle de una cuenta específica del usuario.

**Ejemplo de petición:**
```
GET /api/cuentas/2
```

**Respuesta 200:**
```json
{
  "id": 2,
  "numero_cuenta": "4010000000000002",
  "tipo": "corriente",
  "saldo": 32500.50,
  "limite_credito": null,
  "moneda": "MXN",
  "estado": "activa",
  "created_at": "2025-01-01T00:00:00.000Z",
  "credito_disponible": null
}
```

**Errores:**

| Código | Motivo |
|--------|--------|
| 404 | Cuenta no encontrada o no pertenece al usuario |

---

## POST `/cuentas`

Abre una nueva cuenta para el usuario autenticado.

**Body:**
```json
{
  "tipo": "ahorro"
}
```

**Tipos válidos:**

| Tipo | Categoría | Límite de crédito |
|------|-----------|-------------------|
| `ahorro` | Cuenta bancaria | — |
| `corriente` | Cuenta bancaria | — |
| `orbe` | Crédito | $50,000 MXN |
| `silverstone` | Crédito | $150,000 MXN |
| `imperium` | Crédito | Sin límite |

**Respuesta 201:**
```json
{
  "mensaje": "Cuenta creada exitosamente",
  "id": 5,
  "numero_cuenta": "4010000000000099"
}
```

**Errores:**

| Código | Motivo |
|--------|--------|
| 400 | Tipo inválido o no enviado |
