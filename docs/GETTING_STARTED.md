# Getting Started

## 1. Prerequisitos

- **Flutter** (con FVM recomendado): el proyecto pin-ea la versión en `.fvmrc`.
- **FVM**: `dart pub global activate fvm`. Tras clonar, `fvm install` descarga la versión pinned.
- **lefthook** (Git hooks locales): `winget install evilmartians.lefthook` en Windows, o `brew install lefthook` en macOS.

## 2. Renombrar el package

El template viene con `name: clean_riverpod_starter` en `pubspec.yaml`. Reemplazá por el nombre de tu proyecto en **todos** los archivos:

```bash
# Linux / macOS / Git Bash
grep -rl "clean_riverpod_starter" . | xargs sed -i 's/clean_riverpod_starter/mi_app/g'
```

Afecta:
- `pubspec.yaml` (name + description)
- Todos los `import 'package:...'` en `lib/` y `test/`
- Todos los `part 'X.g.dart'` y `part 'X.freezed.dart'`
- `.vscode/launch.json`
- `README.md`

## 3. Renombrar el bundle ID

El template usa `com.kubo.app` como `applicationId` (Android) y `PRODUCT_BUNDLE_IDENTIFIER` (iOS). Reemplazá por el tuyo:

```bash
grep -rl "com.kubo.app" . | xargs sed -i 's/com\.kubo\.app/com.tuempresa.app/g'
```

Afecta:
- `android/app/build.gradle.kts` (`namespace`, `applicationId`)
- `android/app/src/main/kotlin/com/kubo/app/MainActivity.kt` (línea `package`)
- `ios/Runner.xcodeproj/project.pbxproj`

Luego movés el archivo Kotlin a la ruta que corresponde:

```bash
mkdir -p android/app/src/main/kotlin/com/tuempresa/app
mv android/app/src/main/kotlin/com/kubo/app/MainActivity.kt \
   android/app/src/main/kotlin/com/tuempresa/app/MainActivity.kt
rm -rf android/app/src/main/kotlin/com/kubo
```

## 4. Configurar los flavors

Editá `env/stg.json` y `env/prod.json` con las URLs reales de tu backend.

```json
{
  "FLAVOR": "stg",
  "BASE_URL": "http://localhost:3000",
  "ENABLE_LOGS": true
}
```

Si probás en un **dispositivo Android físico**, podés exponer tu backend local:

```bash
adb reverse tcp:3000 tcp:3000
```

## 5. Decidir convención del backend

Si tu backend responde **snake_case**, descomentá la línea en `build.yaml`:

```yaml
field_rename: snake
```

Si responde camelCase, dejala comentada. Detalle completo en [`BACKEND_CONVENTIONS.md`](BACKEND_CONVENTIONS.md).

## 6. Instalar deps + code-gen

```bash
fvm flutter pub get
fvm dart run build_runner build --delete-conflicting-outputs
```

## 7. Activar hooks de calidad local

```bash
lefthook install
```

Registra los hooks de `pre-commit` (format + analyze) y `pre-push` (tests) definidos en `lefthook.yml`.

## 8. Correr la app

Desde VSCode: `F5` → elegir **App STG (debug)** o **App PROD (debug)**.

Desde terminal:

```bash
fvm flutter run --flavor stg --dart-define-from-file=env/stg.json -t lib/main_stg.dart
```

## 9. Feature de ejemplo: `auth`

La feature `auth` está completa y funciona contra un backend REST que exponga:

- `POST /auth/login` con body `{"email": "...", "password": "..."}`
- Response: `{"user": {...}, "session": {"accessToken": "..."}}` (o `access_token` si tu backend es snake_case).

Adaptala al contrato real de tu backend. Si el shape es distinto, editá:
- `lib/features/auth/infrastructure/models/*_dto.dart` (fields del DTO).
- `lib/features/auth/infrastructure/mappers/auth_mapper.dart` (traducción DTO → Entity).

Para features nuevas (`users`, `products`, etc.), copiá la estructura de `auth/` y adaptá.

## 10. Eliminar `features/home` si no te sirve

El placeholder post-login (`features/home`) existe para que el router tenga un destino tras login exitoso. Reemplazalo por la pantalla real de tu app.
