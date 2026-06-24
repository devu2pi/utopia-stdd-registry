Archivá un cambio verificado y mergea su spec al source of truth del proyecto.

El argumento es el nombre del cambio. Ejemplo: `/opsx-archive m1-auth`

## Validaciones previas (BLOQUEANTES — todas deben cumplirse)

1. Verificá que el argumento fue provisto.
2. Leé `status.json`. El estado DEBE ser `TDD_VERIFIED`. Si es cualquier otro: "ERROR: no podés archivar un cambio que no fue verificado. Estado actual: <estado>. Ejecutá /opsx-tdd-verify <nombre> primero."
3. Leé `tasks.md` y verificá que el resultado final de verificación diga `VERIFIED ✓`. Si dice `BLOCKED`: "ERROR: el cambio está BLOCKED. Resolvé los issues primero."
4. Verificá que NO existen tareas sin completar `- [ ]` en ninguna sección de `tasks.md`.
5. Verificá el nivel de aprobación requerido en `tasks.md`:
   - Nivel 1: auto-aprobación, podés continuar
   - Nivel 2: preguntá "¿Quién del equipo revisó este cambio?"
   - Nivel 3: "Este cambio requiere aprobación de arquitectura. ¿Fue aprobado? Confirmá con 'aprobado por [nombre]'"

## Qué hacer si las validaciones pasan

### 1. Mergear spec al source of truth

Copiá `openspec/changes/<nombre>/spec.md` a `openspec/specs/<nombre>.md`.

Si el spec actualiza un módulo ya documentado en `openspec/project.md`, actualizá la sección correspondiente.

### 2. Actualizar project.md

Si el cambio agrega o modifica un módulo, actualizá `openspec/project.md`:
- Decisiones tomadas en `design.md` → agregar a la tabla de decisiones
- Nuevas dependencias externas → agregar al stack

### 3. Mover el cambio a archivados

Creá `openspec/changes/<nombre>/status.json` con `"state": "ARCHIVED"` y fecha.

Opcionalmente, mové la carpeta a `openspec/changes/_archived/<nombre>/` para mantener `changes/` limpio de cambios cerrados.

### 4. Sugerí el commit

```
docs(openspec): archive <nombre>

- spec mergeada a openspec/specs/<nombre>.md
- project.md actualizado con decisiones del cambio
- [N] tests implementados y verificados
```

### 5. Mostrá resumen del ciclo cerrado

```
## Cambio archivado: <nombre>

Duración: <fecha inicio> → <fecha archivo>
Tests implementados: [N]
Tareas completadas: [N]/[N]
Nivel de aprobación: [1/2/3]

Spec disponible en: openspec/specs/<nombre>.md
Próximo cambio sugerido: /opsx-status
```
