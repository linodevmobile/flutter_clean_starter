# clean_riverpod_starter

Flutter starter con Clean Architecture + Riverpod 3 + go_router + Dio + freezed. Viene configurado con flavors (STG/PROD), Design System base, manejo de errores tipado, y hooks de calidad local.

## Uso rápido

```bash
fvm install
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
lefthook install
fvm flutter run --flavor stg --dart-define-from-file=env/stg.json -t lib/main_stg.dart
```

## Documentación

- [`docs/GETTING_STARTED.md`](docs/GETTING_STARTED.md) — cómo adaptar el template para un proyecto nuevo.
- [`docs/BACKEND_CONVENTIONS.md`](docs/BACKEND_CONVENTIONS.md) — camelCase vs snake_case.
- [`CLAUDE.md`](CLAUDE.md) — stack fijado + reglas transversales.
- [`AGENTS.md`](AGENTS.md) — convenciones cross-IDE (commits) + índice de reglas.
- [`.claude/rules/architecture.md`](.claude/rules/architecture.md) — **fuente de verdad** de la arquitectura (Clean + Riverpod 3). El resto de las reglas viven junto a este archivo en `.claude/rules/`.
- [`CHANGELOG.md`](CHANGELOG.md) — historial de cambios del template.

## Usar como template

Este repo está marcado como **Template repository** en GitHub. Dos formas de crear un proyecto nuevo a partir de él:

**A) Desde la UI de GitHub** (recomendado):
1. Entrá al repo → botón verde **Use this template** → **Create a new repository**.
2. Elegís nombre, visibilidad y se crea un repo con historial limpio.

**B) Con `gh` CLI**:
```bash
gh repo create mi-proyecto --template Kubo-SAS/clean_riverpod_starter --private --clone
cd mi-proyecto
```

Tras crear el proyecto nuevo, seguí [`docs/GETTING_STARTED.md`](docs/GETTING_STARTED.md) para el rename del paquete y configuración inicial.

## Cómo subir mejoras al template

Las mejoras acá **no se propagan automáticamente** a los proyectos ya creados desde el template — solo benefician a los proyectos futuros. Si querés llevar una mejora a un proyecto hijo existente, mirá la sección *Propagar mejoras* más abajo.

### Flujo recomendado (branch + PR)

```bash
git checkout main && git pull
git checkout -b feat/nombre-mejora

# hacés los cambios...

git add <archivos-especificos>          # evitá `git add .`
git commit -m "feat: descripcion corta"
git push -u origin feat/nombre-mejora
```

Después abrís PR desde la web (o `gh pr create`). Mergeás a `main` y borrás la branch.

### Convención de commits

Seguimos [Conventional Commits](https://www.conventionalcommits.org):

| Prefijo | Cuándo |
|---|---|
| `feat:` | Nueva funcionalidad |
| `fix:` | Bug fix |
| `chore:` | Deps, build config, limpieza sin impacto en runtime |
| `docs:` | Solo documentación |
| `refactor:` | Cambio sin alterar comportamiento |
| `test:` | Agregar o modificar tests |

### Versionado y releases

Marcamos snapshots estables con tags [SemVer](https://semver.org):

```bash
git tag -a v1.1.0 -m "Agrega X, actualiza Y"
git push origin v1.1.0
```

- **MAJOR** (`2.0.0`): cambio incompatible — un proyecto hijo no puede traer los cambios sin refactor manual.
- **MINOR** (`1.1.0`): nueva funcionalidad o mejora retrocompatible.
- **PATCH** (`1.0.1`): fix o ajuste menor.

Cada release debe actualizar [`CHANGELOG.md`](CHANGELOG.md) bajo una nueva sección con el número de versión y fecha.

### Sincronizar un mirror (misma historia)

Si además del canónico mantenés un **mirror** del template (otro remote que recibió un `push` de esta misma historia — por ejemplo una copia personal), propagar es un **fast-forward**, no un cherry-pick:

```bash
git push origin main      # 1. subís la mejora al canónico
git push <mirror> main    # 2. espejás (fast-forward, misma historia)
```

> Para que siga siendo fast-forward, **no commitees directo sobre el mirror**: tratalo como espejo de solo-recepción. Si commiteás aparte en ambos lados, las historias divergen y el push falla.
>
> Esto es distinto de un **proyecto hijo** (creado con *Use this template*): ese arranca con historia independiente y se actualiza con cherry-pick, como se ve abajo.

### Propagar mejoras a proyectos hijos

Desde un proyecto ya creado con el template:

```bash
git remote add template git@github.com:Kubo-SAS/clean_riverpod_starter.git
git fetch template
git log template/main --oneline         # ves qué cambió
git cherry-pick <sha>                    # traés commits puntuales
```

> Evitá `git merge template/main` salvo al inicio — los historiales divergen rápido y los conflictos se vuelven inmanejables.
