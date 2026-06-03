# Clean Riverpod Starter

Flutter starter con Clean Architecture + Riverpod 3 + go_router + Dio + freezed. Viene pre-configurado con flavors (STG/PROD), Design System base, manejo de errores tipado, y hooks de calidad local vía `lefthook`.

Convenciones cross-IDE (commits, etc.) viven en `AGENTS.md` — leelas también:

@AGENTS.md

## Leé antes de arrancar

Si es la primera vez que usás este template: [`docs/GETTING_STARTED.md`](docs/GETTING_STARTED.md).

## Reglas vivas del proyecto

Convenciones detalladas en `.claude/rules/`. Leer **antes** de escribir código que toque el área:

- [`.claude/rules/architecture.md`](.claude/rules/architecture.md) — **fuente de verdad**: capas Clean (domain / infrastructure / presentation), Riverpod 3 DI con `keepAlive`, jerarquía sellada `Failure`, `ApiExceptionHandler`, sin `Either`, sin prefijo `I`.
- [`.claude/rules/layers.md`](.claude/rules/layers.md) — tarjeta rápida por capa: qué retorna cada una y dónde se manejan errores (`try/catch` solo en repo, `AsyncValue.guard` en controller).
- [`.claude/rules/models.md`](.claude/rules/models.md) — Entity (`@freezed` sin json) / Params (`toJson`) / DTO (`@freezed` + `fromJson`) / Mapper (`DTO → Entity`, único lugar de traducción).
- [`.claude/rules/actions.md`](.claude/rules/actions.md) — extraer comportamiento repetido (modal + use case + toast) a módulos `*Actions` sin UI; regla de tres.
- [`.claude/rules/widget-composition.md`](.claude/rules/widget-composition.md) — jerarquía `View → Section → UIWidget` y dónde van los formatters.
- [`.claude/rules/dart-style.md`](.claude/rules/dart-style.md) — nombrado, interfaces sin `I`, imports, `const`, comentarios.
- [`.claude/rules/naming.md`](.claude/rules/naming.md) — identificadores de código en inglés; textos de UI en español.
- [`.claude/rules/validations.md`](.claude/rules/validations.md) — validaciones fuera de entities; `CoreValidationService` vs validations por módulo.

## Stack fijado

- Flutter + Dart SDK `^3.10.0`.
- Estado + DI: `flutter_riverpod` `^3.3.1` con code-gen obligatorio (`@riverpod`). Piezas de DI (datasource, repo, use case, services) con `@Riverpod(keepAlive: true)`; controllers en auto-dispose.
- Routing: `go_router` con `refreshListenable` alimentado por `ref.listen`.
- HTTP: `dio` detrás de un `ApiService` wrapper (los datasources nunca tocan Dio directo).
- Persistencia: `flutter_secure_storage` (solo JWT del backend).
- Modelado: `freezed` + `json_serializable`. Entities con `@freezed` **sin** `fromJson`; DTOs con `fromJson`; traducción DTO→Entity en un `Mapper`.
- Lints: `very_good_analysis`. `riverpod_lint` + `custom_lint` pausados hasta que `custom_lint` soporte `analyzer ^9.0.0` (bloquea a `riverpod_generator 4.x`). Las reglas se enforzan vía `.claude/rules/`.
- Tests: `mocktail`.
- Flavors: STG / PROD vía `--dart-define-from-file`.
- Calidad local: `lefthook` (hooks de git locales). Tras clonar: `lefthook install` (una vez).

## Convención del backend: camelCase vs snake_case

El `build.yaml` trae `field_rename: snake` **comentado** por default (asume camelCase en el wire). Si tu backend responde snake_case, descomentá esa línea. Detalle completo en [`docs/BACKEND_CONVENTIONS.md`](docs/BACKEND_CONVENTIONS.md).

## Fuera del stack — no introducir sin evaluar

`get_it`, `injectable`, `fpdart`, `dartz`, `equatable`, `drift`, `isar`, y el API `Mutation` de Riverpod 3 (aún experimental). El template es minimalista a propósito — agregá deps solo cuando una feature lo requiera.

## Reglas transversales no negociables

- **Comentarios**: solo el "por qué". Nunca describir el "qué". No narrar código autoexplicativo.
- **`try/catch`**: solo en `repositories/impl`. Prohibido en `UseCase`, `Notifier` y `View`.
- **Errores**: el repositorio lanza excepciones de dominio tipadas que extienden `Failure` (`AuthFailure`, `NetworkFailure`, …). El `AsyncNotifier` las captura con `AsyncValue.guard`. No se usa `Either` ni wrappers.
- **Interfaces**: sin prefijo `I` (`AuthRepository`); la implementación lleva sufijo `Impl`.
- **Providers**: solo `Notifier` / `AsyncNotifier` con `@riverpod`. Legacy (`StateProvider`, `StateNotifier`) prohibido.
- **`ref.mounted`**: verificar después de cada `await` dentro de un notifier antes de tocar `state`.
- **UI**: `ref.watch(p).when(...)` para dibujar; `ref.listen(p, ...)` para efectos efímeros (toasts, navegación).

## Estructura

Feature-first. Las tres capas de cada feature son `domain/`, `infrastructure/`, `presentation/` (el término "infrastructure" respeta el vocabulario de `architecture.md`).

```
lib/
  main_stg.dart     # entrypoint flavor STG (por convención Flutter, mains en lib/ root)
  main_prod.dart    # entrypoint flavor PROD
  app/              # bootstrap, App widget, router
  core/             # env, network, storage, errors, validations, utils (formatters)
  design_system/    # tokens, theme, atoms, molecules, organisms
  features/
    auth/           # feature de ejemplo (login contra REST, Clean Architecture completa)
    home/           # placeholder post-login
  l10n/
```

## Feature `auth` como ejemplo canónico

Este template trae la feature `auth` completa como **plantilla de referencia**. Cubre:
- Domain: entities (`User`, `AuthSession`), ports (`AuthRepository`, `AuthDatasource`), use case.
- Infrastructure: DTOs con freezed/json_serializable, `AuthMapper` (DTO→Entity), datasource con Dio, repository con `try/catch` único.
- Presentation: `AuthController` (auth state), `LoginAction` (acción de submit), `LoginView` con atoms del DS.
- Router: guard con `refreshListenable`.

Copiá esta feature como referencia cuando crees features nuevas.
