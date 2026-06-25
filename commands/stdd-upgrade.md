Actualizá la versión del registry declarada en el proyecto.

Sin argumentos detecta la versión actual y la última disponible. Con argumento opcional podés especificar la versión destino: `/stdd-upgrade 1.4.0`

## 1. Leer versión actual del proyecto

Leé `.agent/config.yaml` y extraé `registry.version`. Si no existe, error: "No se encontró `.agent/config.yaml`. Ejecutá `/stdd-init` primero."

## 2. Obtener versiones disponibles del registry

Obtené `registry.json`. Estrategia en orden:
1. Si existe localmente → leé `version`
2. Si no: `curl -fsSL https://raw.githubusercontent.com/devu2pi/utopia-stdd-registry/main/registry.json`

Extraé `version` (última disponible).

Si la versión del proyecto ya es igual a la última:
```
✓ El proyecto ya está en la versión más reciente del registry (X.Y.Z). No hay nada que actualizar.
```
Y detener.

## 3. Determinar versión destino

Obtené el CHANGELOG para conocer todas las versiones intermedias entre la actual y la última:
1. Si existe localmente → leé `CHANGELOG.md` directamente
2. Si no: `curl -fsSL https://raw.githubusercontent.com/devu2pi/utopia-stdd-registry/main/CHANGELOG.md`

Extraé todas las versiones disponibles entre la versión actual (exclusiva) y la última (inclusiva), en orden ascendente. Ejemplo: si el proyecto está en `1.1.0` y la última es `1.3.0`, las versiones intermedias son `[1.2.0, 1.3.0]`.

### Si hay exactamente una versión disponible

Mostrá directamente el plan de upgrade a esa versión (ir al paso 4).

### Si hay más de una versión disponible

Preguntá al usuario:

```
Versión actual:  X.Y.Z
Última versión:  A.B.C

Versiones disponibles para upgrade:
  1) X1.Y1.Z1 — <descripción de qué cambió>
  2) X2.Y2.Z2 — <descripción de qué cambió>
  ...
  N) A.B.C    — <descripción de qué cambió> (última)

¿A qué versión querés actualizar? [1-N] (Enter = última):
```

Usá la descripción corta del `### Qué cambió` de cada versión en el CHANGELOG.

Esperá respuesta del usuario antes de continuar. Si no responde nada (Enter), usá la última.

### Si el usuario especificó versión como argumento

Verificá que existe en el CHANGELOG. Si no existe, error: "La versión X.Y.Z no existe en el registry."

## 4. Mostrar plan de migración

Extraé del CHANGELOG todas las secciones entre la versión actual (exclusiva) y la versión destino (inclusiva), en orden ascendente.

Para cada versión en el rango:
- Mostrá el título y descripción general
- Para cada acción `[context]`: mostrá como información
- Para cada acción `[action]`: intentá verificar si ya fue aplicada leyendo el estado del proyecto. Marcá `[✓]` si ya está, `[✗]` si no, `[?]` si no podés determinarlo
- Para cada acción `[breaking]`: igual que `[action]` pero marcá como bloqueante si está pendiente

Mostrá el plan completo:

```
## Plan de upgrade: X.Y.Z → A.B.C

### [versión intermedia si aplica]
<descripción>
[i] <contexto>
[✓] <acción ya aplicada>
[✗] <acción pendiente>

### [versión destino]
<descripción>
[i] <contexto>
[✗] <acción pendiente>  ← BREAKING

Acciones pendientes: N
Breaking pendientes: N

¿Aplicar upgrade? [s/N]:
```

Esperá confirmación antes de continuar.

## 5. Sincronizar comandos

Antes de aplicar las acciones del CHANGELOG, sincronizá los comandos globales con la versión destino:

Obtené `registry.json` de la versión destino y extraé `commands.files[]`. Para cada archivo en la lista:
- Si no existe en `~/.claude/commands/`: descargalo (`curl -fsSL .../commands/<archivo> -o ~/.claude/commands/<archivo>`)
- Si existe: sobreescribilo con la versión destino
- Reportá cada archivo: `↓ <archivo>` al descargarlo, `↺ <archivo>` al actualizarlo

```
Sincronizando comandos (X.Y.Z → A.B.C)...
↓ stdd-implement.md   (nuevo)
↺ stdd-validate.md   (actualizado)
✓ stdd-propose.md    (sin cambios)
```

## 6. Aplicar acciones del CHANGELOG

Para cada acción `[✗]` del CHANGELOG en orden (de versión más antigua a más nueva):

- Anunciá qué acción estás ejecutando
- Para acciones que implican instalar archivos de comandos: ya fueron sincronizados en el paso anterior, marcalas `[✓]` automáticamente
- Para acciones que implican modificar archivos del proyecto: aplicá el cambio directamente
- Para acciones que requieren intervención manual: mostrá las instrucciones y pedí confirmación antes de continuar
- Al completar cada acción, marcala como `[✓]`

Si una acción `[breaking]` falla o el usuario la omite, detené el upgrade y reportá el estado.

## 7. Actualizar versión declarada

Al completar todas las acciones (o si no había acciones pendientes), actualizá `registry.version` en `.agent/config.yaml` a la versión destino.

Mostrá resultado final:

```
## Upgrade completado: X.Y.Z → A.B.C

✓ Acciones aplicadas: N
⚠ Acciones manuales pendientes: N (ver arriba)

registry.version actualizado a A.B.C en .agent/config.yaml

Ejecutá /stdd-validate para confirmar que el proyecto está en orden.
```
