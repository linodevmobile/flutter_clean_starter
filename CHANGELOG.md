# Changelog

Todas las mejoras relevantes de este template se documentan acá.

El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y el versionado sigue [SemVer](https://semver.org/lang/es/).

## [Unreleased]

### Added
- Sección "Usar como template" y "Cómo subir mejoras" en el README.
- Este `CHANGELOG.md`.
- Reglas modulares en `.claude/rules/`: `architecture.md` (fuente de verdad), `layers.md`, `models.md`, `actions.md`, `naming.md`.
- `AGENTS.md` con convenciones cross-IDE (commits) e índice de reglas.
- `AuthMapper` dedicado (`features/auth/infrastructure/mappers/`) para la traducción DTO → Entity.
- `docs/GETTING_STARTED.md`: paso 11 (flavors nativos de iOS con `flutter_flavorizr`).
- "Comandos comunes" en `CLAUDE.md` (FVM + flavors, build_runner, analyze/test, lefthook).

### Changed
- Interfaces sin prefijo `I`: `AuthRepository` / `AuthDatasource` (Effective Dart).
- Providers de DI ahora con `@Riverpod(keepAlive: true)`; controllers quedan auto-dispose.
- `arquitectura-explicada.md` reemplazado por `architecture.md` alineado al código real (jerarquía `Failure`, mapper, keepAlive).
- `GETTING_STARTED.md` paso 3: aclaración de `namespace` vs `applicationId` vs package de Kotlin y los 4 lugares a renombrar.
- README y docs apuntan al repo de la organización (`Kubo-SAS`).

### Removed
- `.claude/rules/arquitectura-explicada.md` (reemplazado por `architecture.md` + reglas modulares).

## [1.0.0] - 2026-04-18

### Added
- Stack base: Flutter `^3.10.0`, `flutter_riverpod` `^3.3.1` con code-gen, `go_router`, `dio`, `freezed`, `flutter_secure_storage`.
- Flavors STG / PROD vía `--dart-define-from-file` (`env/stg.json`, `env/prod.json`).
- Arquitectura Clean documentada en `.claude/rules/arquitectura-explicada.md` (domain / infrastructure / presentation).
- Feature `auth` como plantilla canónica: entities, ports, use case, DTOs, datasource Dio, repository con `try/catch` único y `AuthController` con `AsyncValue.guard`.
- `core/errors` con `ApiExceptionHandler` y failures tipados (`AuthFailure`, `NetworkFailure`, `UnknownFailure`).
- Design System base: tokens, theme, atoms / molecules / organisms.
- Guard de router con `refreshListenable` alimentado por `ref.listen`.
- Reglas vivas del proyecto en `.claude/rules/` (dart-style, widget-composition, validations).
- Hooks de calidad local vía `lefthook`.
- Documentación inicial: `README.md`, `docs/GETTING_STARTED.md`, `docs/BACKEND_CONVENTIONS.md`, `CLAUDE.md`.

### Removed
- Feature placeholders específicos de VetApp (patients, consultation, recording) removidos del template base.

[Unreleased]: https://github.com/Kubo-SAS/clean_riverpod_starter/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/Kubo-SAS/clean_riverpod_starter/releases/tag/v1.0.0
