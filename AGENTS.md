# AGENTS.md

Convenciones de este repositorio para cualquier agente de IA (Claude Code, OpenCode,
Cursor, Aider, etc.), independientes del IDE. Este archivo es la **fuente de verdad**
multi-herramienta. Claude Code lo hereda vía `@AGENTS.md` desde `CLAUDE.md`.

## Reglas del proyecto (OBLIGATORIO leer antes de escribir código)

Las convenciones de arquitectura y estilo son la **fuente única de verdad** y viven en
`.claude/rules/`. Cualquier agente, sin importar el IDE, **DEBE leer los archivos relevantes
de `.claude/rules/` antes de escribir o modificar código**. No asumas las convenciones: léelas.

- `.claude/rules/architecture.md` — **fuente de verdad** de la arquitectura: capas Clean
  (domain / infrastructure / presentation), Riverpod 3 DI con `keepAlive` en piezas de DI,
  jerarquía sellada `Failure`, `ApiExceptionHandler`, sin `Either`, sin prefijo `I`.
- `.claude/rules/layers.md` — tarjeta rápida por capa: qué retorna cada una y dónde se
  manejan los errores (`try/catch` solo en repo, `AsyncValue.guard` en controller).
- `.claude/rules/models.md` — Entity (`@freezed` sin json) / Params (`toJson`) /
  DTO (`@freezed` + `fromJson`, calcado al API) / Mapper (`DTO → Entity`, único lugar de traducción).
- `.claude/rules/actions.md` — extraer comportamiento repetido (modal + use case + toast)
  a módulos `*Actions` sin UI; regla de tres.
- `.claude/rules/widget-composition.md` — composición en 3 niveles: View → Section → UIWidget.
- `.claude/rules/dart-style.md` — nombrado, interfaces sin `I` (impl con `Impl`), orden de imports, `const` siempre.
- `.claude/rules/naming.md` — identificadores de código en inglés; textos de UI en español.
- `.claude/rules/validations.md` — las entities no validan; usar `*ValidationService` con métodos estáticos.

## Commits

- **Nunca** incluir el trailer `Co-Authored-By` (ni `Co-Authored-By: Claude`, ni el
  de ningún otro agente) en los mensajes de commit.
- No agregar firmas, créditos ni atribuciones de IA en el cuerpo del commit
  (por ejemplo `Generated with ...`, `🤖`, etc.).
- Mensajes en formato Conventional Commits: `tipo(scope): descripción en minúscula`.
  Tipos: `feat`, `fix`, `chore`, `refactor`, `docs`, `test`.
- Hacer commit o push **solo cuando el usuario lo pida**.
