Validá la compatibilidad del proyecto con la versión del registry declarada en `.agent/config.yaml`.

## Cuándo usarlo

- Después de cambiar `version` en `.agent/config.yaml` (upgrade o downgrade de registry)
- Como health-check para detectar drift entre el proyecto y el registry

## Qué hacer

### 1. Leer versiones

Leé `.agent/config.yaml` y extraé `registry.version` (versión declarada por el proyecto).

Luego buscá la versión actual del registry. Estrategia en orden:
1. Si existe `registry.json` en el directorio del registry local → leé `version`
2. Si no, intentá: `curl -fsSL https://raw.githubusercontent.com/devu2pi/utopia-stdd-registry/main/registry.json | grep '"version"' | head -1`
3. Si falla, informá: "No se pudo obtener la versión actual del registry. Verificá conectividad."

### 2. Comparar versiones

Si la versión del proyecto es igual a la del registry:
```
✓ El proyecto está en la versión actual del registry (X.Y.Z). No hay acciones pendientes.
```
Y detener.

Si son distintas, continuá.

### 3. Leer el CHANGELOG

Buscá `CHANGELOG.md` del registry. Estrategia en orden:
1. Si el registry fue clonado localmente (`.agent/config.yaml` tiene `source: local` o existe un path local) → leé el archivo directamente
2. Si no: `curl -fsSL https://raw.githubusercontent.com/devu2pi/utopia-stdd-registry/main/CHANGELOG.md`

Extraé todas las secciones entre la versión del proyecto (exclusiva) y la versión del registry (inclusiva), en orden ascendente.

### 4. Analizar acciones de migración

Para cada sección del CHANGELOG en el rango:

- Mostrá el título de la versión y descripción general
- Para cada acción marcada con `[context]`: mostrá como información, no requiere verificación
- Para cada acción marcada con `[action]`: intentá verificar si ya fue aplicada leyendo el estado del proyecto (package.json, archivos relevantes, etc.). Marcá como `[✓]` si detectás que ya está hecha, `[?]` si no podés determinarlo, `[✗]` si claramente no fue aplicada
- Para cada acción marcada con `[breaking]`: igual que `[action]` pero marcá como bloqueante si está pendiente

### 5. Mostrar reporte

```
## Validación de versión del registry

Versión del proyecto:   X.Y.Z
Versión del registry:   A.B.C
OpenSpec:               vN

### Cambios a aplicar (X.Y.Z → A.B.C)

#### [versión] A.B.C
<descripción>

[✓] <acción ya aplicada>
[✗] <acción pendiente>  ← BREAKING
[?] <acción no verificable — revisar manualmente>
[i] <contexto informativo>

### Resultado: APROBADO | BLOQUEADO

APROBADO  → no hay acciones breaking pendientes, podés continuar el workflow
BLOQUEADO → hay N acción(es) breaking pendiente(s). Resolvelas y ejecutá /stdd-validate nuevamente.
```

### 6. Si el resultado es APROBADO y el usuario quiere actualizar la versión declarada

Preguntá: "¿Querés actualizar `registry.version` en `.agent/config.yaml` a A.B.C?"
Si confirma, editá `.agent/config.yaml` con la nueva versión.
