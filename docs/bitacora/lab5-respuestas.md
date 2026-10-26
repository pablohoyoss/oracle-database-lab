# Respuestas y Retrospectiva — Lab 5: DBA Workflow II

## 1. Preguntas de Comprobación y Simulacro

- **Pregunta 1:** [Opción elegida] — *Justificación en una frase.*
- **Pregunta 2:** [Opción elegida] — *Justificación en una frase.*
- **Pregunta 3:** [Opción elegida] — *Justificación en una frase.*

---

## 2. Matriz RTO / RPO de Simulacros (Game Day)

| Simulacro | Escenario | RTO (Tiempo de Recuperación) | RPO (Pérdida de Datos) | Estado |
| :--- | :--- | :--- | :--- | :--- |
| **14a** | Crash de Instancia (`SHUTDOWN ABORT`) | < 30 s (Crash Recovery automático) | 0 (Commit garantizado por Redo Log) | **Exitoso** |
| **14b** | Pérdida de Control File (`control03.ctl`) | < 2 min (Restauración de copia múltiple) | 0 (Sin pérdida de metadatos) | **Exitoso** |
| **14c** | Borrado de Tabla (Flashback / RMAN) | < 3 min (Restauración de tabla) | 0 (Recuperación hasta SCN exacto) | **Exitoso** |
| **14d** | Pérdida de Datafile (`tiendasur01.dbf`) | < 2 min (Recuperación Online via RMAN) | 0 (Apply de Archived Logs) | **Exitoso** |

---

## 3. Retrospectiva y Lecciones Aprendidas

- **Lección clave:** La arquitectura multiplexada (Control Files + Redo Log) junto al modo `ARCHIVELOG` permite garantizar RPO = 0 ante fallos físicos de almacenamiento.
- **Mejora identificada:** El RTO del simulacro C (tabla borrada) puede optimizarse manteniendo la papelera de reciclaje (`RECYCLEBIN`) activa antes de recurrir a restauración por RMAN.
# Cierre de Lab 5
