Generá los artefactos de diseño e implementación para un cambio aprobado.

El argumento es el nombre del cambio. Ejemplo: `/stdd-apply m1-auth`

## Validaciones previas (BLOQUEANTES)

1. Verificá que el argumento fue provisto.
2. Verificá que existe `openspec/changes/<nombre>/proposal.md`.
3. Leé `openspec/changes/<nombre>/status.json`. El estado DEBE ser `APPROVED`. Si es `DRAFT`: "ERROR: la proposal de '<nombre>' no fue aprobada todavía. Revisala y pedí aprobación antes de continuar." Si es cualquier estado posterior a APPROVED: "Este cambio ya fue aplicado (estado: <estado>). Usá /stdd-status para ver qué sigue."
4. Leé `openspec/project.md` — lo necesitás como contexto para generar los artefactos.

## Qué hacer si las validaciones pasan

Generá los tres artefactos en `openspec/changes/<nombre>/`:

### 1. `spec.md`

```markdown
# Spec: <nombre>

**Basado en:** proposal.md aprobada
**Fecha:** <fecha>

---

## Módulo / Feature

[Nombre y descripción del módulo]

---

## Escenarios de comportamiento

### Escenario 1: [nombre]
**Dado:** [estado inicial]
**Cuando:** [acción]
**Entonces:** [resultado esperado]

### Escenario 2: [nombre]
...

---

## Requisitos no funcionales

- Performance: [si aplica]
- Seguridad: [permisos requeridos, roles]
- Accesibilidad: [si aplica]

---

## Fuera de scope

[Lo que explícitamente NO cubre esta spec]
```

### 2. `design.md`

```markdown
# Design: <nombre>

**Fecha:** <fecha>

---

## Approach técnico

[Descripción del approach elegido y por qué]

---

## Estructura de archivos

[Archivos a crear o modificar con descripción de responsabilidad]

---

## Modelo de datos

[Tablas, campos, relaciones — si aplica]

---

## Decisiones técnicas

| Decisión | Alternativa descartada | Motivo |
|----------|----------------------|--------|
| [usar X] | [usar Y] | [razón] |

---

## Alineación con el registry

- Stack: [confirmar que usa tecnologías de stack/v1.md]
- Arquitectura: [confirmar patrones de architecture/v1.md]
- Desviaciones: [ninguna / listar con justificación]
```

### 3. `tasks.md`

```markdown
# Tasks: <nombre>

**Estado:** EN PROGRESO
**Fecha inicio:** <fecha>

---

## Tests Requeridos
> Completar con /stdd-plan antes de implementar

[pendiente]

---

## Implementación

- [ ] 1.1 [tarea] — Test asociado: [TEST-XX]
- [ ] 1.2 [tarea] — Test asociado: [TEST-XX]
- [ ] 1.3 [tarea] — Test asociado: [TEST-XX]

---

## Criterios de aceptación

- [ ] ACC-01: [criterio en lenguaje de negocio]
- [ ] ACC-02: [criterio]

---

## Verificación
> Completar con /stdd-verify

- [ ] tdd:verify ejecutado: pendiente
- [ ] Nivel de aprobación: [1 / 2 / 3]
- [ ] Aprobado por: [pendiente]
```

Actualizá `status.json` a `"state": "APPLIED"` con entrada en historial.

Al terminar, decile al usuario: "Artefactos generados. Próximo paso: /stdd-plan <nombre> para definir los tests antes de implementar."
