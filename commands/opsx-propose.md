Iniciá una nueva propuesta de cambio OpenSpec.

El argumento es el nombre del cambio en kebab-case. Ejemplo: `/opsx-propose m1-auth`

## Validaciones previas (BLOQUEANTES — detené si alguna falla)

1. Verificá que el argumento fue provisto. Si no: "ERROR: especificá el nombre del cambio. Uso: /opsx-propose <nombre>"
2. Verificá que `openspec/project.md` existe y NO está vacío ni es solo un template sin completar (sin placeholders como "[nombre del proyecto]"). Si está incompleto: "ERROR: completá openspec/project.md antes de proponer un cambio."
3. Verificá que NO existe ya `openspec/changes/<nombre>/proposal.md`. Si existe: "ERROR: el cambio '<nombre>' ya existe. Usá /opsx-status para ver su estado actual."
4. Verificá que no hay más de 3 cambios en estado PROPOSED o APPLIED simultáneamente. Si hay: "ADVERTENCIA: hay N cambios activos sin completar. ¿Querés continuar de todos modos? Responde 'sí' para confirmar."

## Qué hacer si las validaciones pasan

1. Creá el directorio `openspec/changes/<nombre>/`
2. Creá `openspec/changes/<nombre>/proposal.md` con esta estructura:

```markdown
# Proposal: <nombre>

**Estado:** DRAFT
**Fecha:** <fecha actual>
**Autor:** [completar]
**Nivel de aprobación requerido:** [1 / 2 / 3]

---

## Qué se propone

[Describir claramente qué cambia y qué resultado produce]

---

## Por qué

[Motivación: problema que resuelve, oportunidad, deuda técnica]

---

## Qué incluye

- [ ] [item 1]
- [ ] [item 2]

---

## Qué NO incluye

[Límites explícitos del scope]

---

## Impacto

- **Módulos afectados:** [listar]
- **Dependencias externas nuevas:** [ninguna / listar]
- **Riesgos:** [listar con mitigación]

---

## Notas

[Contexto adicional, links, referencias]
```

3. Creá `openspec/changes/<nombre>/status.json`:
```json
{
  "name": "<nombre>",
  "state": "DRAFT",
  "created": "<fecha>",
  "history": [
    { "state": "DRAFT", "date": "<fecha>", "note": "Propuesta iniciada" }
  ]
}
```

4. Mostrá al usuario los archivos creados y decile:
   - Completar los placeholders en `proposal.md`
   - Una vez completo, pedirte que lo revises y lo marques como APPROVED
   - Que la aprobación desbloquea `/opsx-apply`

## Aprobación de la proposal

Cuando el usuario pida aprobar una proposal:
1. Leé `proposal.md` y verificá que no tenga placeholders sin completar (`[completar]`, `[listar]`, etc.)
2. Si está completa: actualizá `status.json` con `"state": "APPROVED"` y agregá al historial
3. Agregá al final de `proposal.md`: `\n---\n**Estado:** APROBADO ✓ — <fecha>`
4. Confirmá: "Proposal aprobada. Podés ejecutar /opsx-apply <nombre>"
