Mostrá el estado actual de todos los cambios OpenSpec en este proyecto.

## Qué hacer

1. Listá todos los directorios en `openspec/changes/`
2. Para cada cambio, leé su `status.json` si existe. Si no existe, inferí el estado por los archivos presentes:
   - Solo `proposal.md` → PROPOSED
   - `proposal.md` con `## Estado: APROBADO` → APPROVED
   - `spec.md` y `design.md` presentes → APPLIED
   - `tasks.md` con sección `## Tests Requeridos` → TDD_PLANNED
   - `tasks.md` con sección `## Reporte de Verificación` → TDD_VERIFIED o BLOCKED
   - Carpeta en `openspec/specs/` con el mismo nombre → ARCHIVED

3. Mostrá una tabla con:
   - Nombre del cambio
   - Estado actual
   - Próxima acción disponible
   - Bloqueadores si los hay

4. Indicá claramente cuál es el cambio activo (si hay uno) y qué comando ejecutar a continuación.

## Formato de salida

```
## Estado OpenSpec — <nombre-proyecto>

| Cambio              | Estado        | Próxima acción         |
|---------------------|---------------|------------------------|
| migracion-inicial   | APPROVED      | /stdd-apply            |
| m1-auth             | TDD_PLANNED   | implementar → /stdd-verify |

Cambio activo: migracion-inicial
Ejecutá: /stdd-apply migracion-inicial
```

Si no hay cambios activos, indicalo y sugerí `/stdd-propose`.
