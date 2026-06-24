Definí los tests requeridos para un cambio ANTES de implementar.

El argumento es el nombre del cambio. Ejemplo: `/stdd-plan m1-auth`

## Validaciones previas (BLOQUEANTES)

1. Verificá que el argumento fue provisto.
2. Leé `openspec/changes/<nombre>/status.json`. El estado DEBE ser `APPLIED`. Si es anterior: "ERROR: ejecutá /stdd-apply <nombre> primero." Si es posterior: "Los tests ya fueron planificados para este cambio."
3. Verificá que existe `openspec/changes/<nombre>/spec.md` y `design.md`.

## Qué hacer si las validaciones pasan

Leé `spec.md`, `design.md` y `tasks.md` del cambio. Luego reemplazá la sección `## Tests Requeridos` en `tasks.md` con tests concretos derivados de los escenarios de la spec:

```markdown
## Tests Requeridos
> Definidos el <fecha> — NO modificar durante la implementación

### Unitarios

- [ ] TEST-01: [descripción del comportamiento verificable]
      Archivo: tests/unit/<módulo>.test.ts
      Input: [qué entra]
      Expected: [qué debe retornar/hacer]

- [ ] TEST-02: [descripción]
      Archivo: tests/unit/<módulo>.test.ts
      Input: [qué entra]
      Expected: [qué debe retornar/hacer]

### Integración

- [ ] TEST-03: [flujo end-to-end]
      Archivo: tests/e2e/<feature>.spec.ts
      Precondición: [estado inicial requerido]
      Acción: [qué ejecuta el usuario/sistema]
      Expected: [resultado observable]

### Regla de cobertura

Cada tarea en ## Implementación debe tener al menos un TEST- asociado.
Tests definidos: [N]
Tareas de implementación: [N]
Ratio: [verificar que es ≥ 1:1]
```

Luego actualizá las tareas de `## Implementación` para que cada una tenga su `— Test asociado: TEST-XX` referenciado.

Actualizá `status.json` a `"state": "TDD_PLANNED"`.

Al terminar: "Tests definidos. Podés implementar. Cuando termines, ejecutá /stdd-verify <nombre>."

## Regla importante

Los tests deben definirse basados en los ESCENARIOS de `spec.md`, no en el código que se va a escribir. Si no hay escenarios claros en la spec, detené y pedí completarlos antes de continuar.
