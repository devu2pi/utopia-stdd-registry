Implementá las tareas de un cambio con tests definidos.

El argumento es el nombre del cambio. Ejemplo: `/stdd-implement m1-auth`

## Validaciones previas (BLOQUEANTES)

1. Verificá que el argumento fue provisto.
2. Leé `openspec/changes/<nombre>/status.json`. El estado DEBE ser `TDD_PLANNED`.
   - Si es anterior: "ERROR: ejecutá /stdd-plan <nombre> primero — los tests deben estar definidos antes de implementar."
   - Si es `IN_PROGRESS`: "Este cambio ya está en implementación. Revisá `tasks.md` para ver qué tareas quedan pendientes."
   - Si es posterior: "Este cambio ya fue implementado (estado: <estado>). Usá /stdd-verify <nombre> si aún no verificaste."
3. Verificá que existe `openspec/changes/<nombre>/tasks.md` con la sección `## Tests Requeridos` completada (no debe decir `[pendiente]`).

## Qué hacer si las validaciones pasan

### 1. Cambiar estado a IN_PROGRESS

Actualizá `status.json` a `"state": "IN_PROGRESS"` con entrada en historial.

Mostrá al usuario:

```
Implementando: <nombre>
Estado → IN_PROGRESS

Tareas pendientes: [N]
Tests requeridos:  [N]

Arrancando con Bloque 1...
```

### 2. Ejecutar las tareas en orden

Leé la sección `## Implementación` de `tasks.md`. Para cada bloque de tareas:

- Anunciá el bloque antes de empezar: `### Bloque X — <nombre del bloque>`
- Ejecutá cada tarea `[ ]` en orden
- Al completar cada tarea, marcala `[x]` en `tasks.md` inmediatamente — no esperes al final del bloque
- Si una tarea falla o genera un error bloqueante, detené, reportá el problema y esperá instrucción del usuario antes de continuar

**Regla de implementación:** cada tarea debe producir código que permita que su TEST asociado pase. Si al escribir el código notás que el test definido en `/stdd-plan` no puede verificar lo que la tarea implementa, reportalo como deuda — no modifiques los tests, registralo al final.

### 3. Ejecutar los tests al final de cada bloque

Después de completar todas las tareas de un bloque:

- Ejecutá los tests asociados a ese bloque (según la columna "Tests que lo cubren" en `tasks.md`)
- Si algún test falla: marcá la tarea correspondiente como `[x] ⚠️ TEST FALLIDO` y continuá con el siguiente bloque — no te detengas salvo que el fallo sea bloqueante para el bloque siguiente
- Reportá el resultado del bloque: `Bloque X: N/M tests pasaron`

### 4. Reporte final

Al completar todos los bloques, mostrá:

```
## Implementación completada: <nombre>

### Tareas
✓ Completadas: [N]
⚠ Con advertencias: [N]
✗ Fallidas: [N]

### Tests
✓ Pasando: [N]
✗ Fallando: [N]

### Deuda registrada
[lista de items si los hay, o "ninguna"]

### Próximo paso
/stdd-verify <nombre>
```

Si hay tests fallando, aclará: "Podés ejecutar /stdd-verify igual — el comando determinará si los fallos bloquean la verificación o son deuda aceptable."

## Estados de tareas en tasks.md

| Marcado | Significado |
|---------|-------------|
| `[ ]` | Pendiente |
| `[x]` | Completada y tests asociados pasan |
| `[x] ⚠️ TEST FALLIDO` | Completada pero el test asociado falla |
| `[~]` | Omitida con justificación (registrar motivo inline) |

## Reglas importantes

- **No modificar los tests** definidos en `/stdd-plan` durante la implementación. Si un test está mal especificado, registrarlo como deuda y avanzar.
- **No saltear tareas** sin justificación explícita. Si una tarea no aplica, usar `[~]` con motivo.
- **Una tarea a la vez** — no implementar en lote sin marcar el avance en `tasks.md`.
- **El código debe estar en el repo del proyecto**, no en archivos temporales ni en la respuesta del chat.
