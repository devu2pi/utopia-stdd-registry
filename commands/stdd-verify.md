Verificá que la implementación cumple con todos los tests y criterios del cambio.

El argumento es el nombre del cambio. Ejemplo: `/stdd-verify m1-auth`

## Validaciones previas (BLOQUEANTES)

1. Verificá que el argumento fue provisto.
2. Leé `status.json`. El estado DEBE ser `TDD_PLANNED`. Si es anterior: "ERROR: ejecutá /stdd-plan <nombre> primero." Si ya es `TDD_VERIFIED`: "Este cambio ya fue verificado. Podés ejecutar /stdd-archive <nombre>."
3. Verificá que NO hay tareas de implementación sin completar `- [ ]` en `tasks.md` (sección ## Implementación). Si las hay: "ERROR: hay [N] tareas sin completar en tasks.md. Completalas antes de verificar:\n[listar las incompletas]"

## Qué hacer si las validaciones pasan

### 1. Ejecutá los comandos de verificación según el stack del proyecto

Leé `openspec/project.md` para conocer el stack y ejecutá:

**Next.js / TypeScript:**
```bash
npm run typecheck
npm run lint
npm run test:unit
npm run test:e2e
npm run test:coverage
```

**FastAPI / Python:**
```bash
pytest tests/unit/ -v
pytest tests/integration/ -v
pytest --cov=app --cov-report=term-missing
```

### 2. Documentá el resultado en `tasks.md`

Reemplazá la sección `## Verificación` con:

```markdown
## Verificación

### Resultados de tests
- [ ] TEST-01: [PASS ✓ / FAIL ✗ — motivo]
- [ ] TEST-02: [PASS ✓ / FAIL ✗ — motivo]
...

### Checks de calidad
- [ ] typecheck: PASS ✓ / FAIL ✗
- [ ] lint: PASS ✓ / FAIL ✗
- [ ] coverage: [X]% (umbral: 80%)
- [ ] tests unitarios: PASS ✓ / FAIL ✗
- [ ] tests e2e: PASS ✓ / FAIL ✗

### Criterios de aceptación
- [ ] ACC-01: VERIFICADO ✓ / PENDIENTE
- [ ] ACC-02: VERIFICADO ✓ / PENDIENTE

### Alineación con registry
- [ ] Sigue patrones de architecture/v1.md
- [ ] Usa stack aprobado en stack/v1.md
- [ ] Pasa checklist de code-review/v1.md

### Regresión
- [ ] No se rompieron tests existentes
- [ ] Funcionalidad previa relacionada revisada

### Resultado final
**tdd:verify:** [VERIFIED ✓ / BLOCKED]
**Motivo (si BLOCKED):** [descripción]
**Nivel de aprobación:** [1 / 2 / 3]
**Aprobado por:** [nombre o "auto"]
**Fecha:** <fecha>
```

### 3. Actualizá status.json

- Si TODOS los checks pasan: `"state": "TDD_VERIFIED"`
- Si alguno falla: `"state": "BLOCKED"` con nota del motivo

### 4. Comunicá el resultado

**Si VERIFIED:** "Verificación completa ✓. Podés ejecutar /stdd-archive <nombre> para cerrar el cambio."

**Si BLOCKED:** "Verificación bloqueada ✗. Problemas encontrados:\n[lista de fallos]\nCorregí los issues y volvé a ejecutar /stdd-verify <nombre>."
