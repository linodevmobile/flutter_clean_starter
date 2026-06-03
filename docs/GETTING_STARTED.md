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

## 3. Renombrar el package / bundle ID

El template usa `com.kubo.app`. Antes de reemplazarlo conviene entender que en Android moderno (AGP 8+) hay **tres cosas distintas** que se suelen llamar "package":

| Concepto | Dónde vive | Qué es |
|---|---|---|
| **`namespace`** | `android/app/build.gradle.kts` | Package del **código**: genera la clase `R` y `BuildConfig`. Debe coincidir con el `package` de los `.kt`. El `AndroidManifest.xml` ya **no** lleva atributo `package=`; lo deriva del `namespace`. |
| **`applicationId`** | `android/app/build.gradle.kts` | **ID de instalación** único en el device / Play Store. Puede diferir del `namespace`. |
| **Carpeta + `package` de Kotlin** | `android/app/src/main/kotlin/com/kubo/app/MainActivity.kt` | La ruta física de las fuentes Kotlin **debe** reflejar el `namespace`. |

> En iOS el equivalente es `PRODUCT_BUNDLE_IDENTIFIER` (en `ios/Runner.xcodeproj/project.pbxproj`).

### Los 4 lugares que hay que cambiar (sincronizados)

Renombrar el package = tocar estos 4 puntos a la vez. Los primeros 3 son texto; el 4º es mover una carpeta.

1. `namespace` en `android/app/build.gradle.kts`
2. `applicationId` en `android/app/build.gradle.kts`
3. La línea `package …` dentro de `MainActivity.kt`
4. La ruta física `kotlin/com/kubo/app/` → `kotlin/com/tuempresa/app/`
5. (iOS) `PRODUCT_BUNDLE_IDENTIFIER` en `project.pbxproj`

### Comandos

Reemplazo de texto (cubre puntos 1, 2, 3 y 5):

```bash
# Linux / macOS / Git Bash
grep -rl "com.kubo.app" . | xargs sed -i 's/com\.kubo\.app/com.tuempresa.app/g'
```

Mover la carpeta Kotlin (punto 4 — el `sed` no mueve archivos):

```bash
mkdir -p android/app/src/main/kotlin/com/tuempresa/app
mv android/app/src/main/kotlin/com/kubo/app/MainActivity.kt \
   android/app/src/main/kotlin/com/tuempresa/app/MainActivity.kt
rm -rf android/app/src/main/kotlin/com/kubo
```

### Importante: el flavor NO cambia el package del código

El flavor `stg` agrega `applicationIdSuffix = ".stg"`, que toca **solo el `applicationId`** →
la app se instala como `com.tuempresa.app.stg` y convive con prod (`com.tuempresa.app`) en el
mismo device. **No** cambia el `namespace` ni el package de Kotlin: `MainActivity.kt` sigue
siendo `com.tuempresa.app` para ambos flavors. Los flavors no duplican el código fuente.

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

## 11. Flavors nativos: Android listo, iOS con `flutter_flavorizr`

El template trae los flavors `stg` / `prod` cableados en **Dart** (`main_stg.dart` / `main_prod.dart`, `Env`), **tooling** (`launch.json`) y **Android** (`android/app/build.gradle.kts` ya define `productFlavors { stg, prod }`). Lo único que **no** viene resuelto es la parte nativa de **iOS**: `flutter run --flavor stg` falla en iOS porque Xcode necesita *schemes* y *build configurations* por flavor que aún no existen.

Como esa config depende del bundle ID y del entorno de cada proyecto, no se versiona en el template: la genera cada proyecto con [`flutter_flavorizr`](https://pub.dev/packages/flutter_flavorizr).

### Qué hace (y qué NO hace) flavorizr aquí

- **Hace**: genera el andamiaje **nativo** del flavor — en iOS: `xcconfig` por flavor, build configurations (`Debug-stg`, `Release-stg`, …), schemes `stg`/`prod` y ajustes del `Info.plist`.
- **NO hace**: no toca el sistema de configuración del template. Las variables de entorno (`BASE_URL`, `ENABLE_LOGS`, …) siguen llegando por `--dart-define-from-file=env/<flavor>.json` y leyéndose desde `Env`. **No** usamos el `lib/flavors.dart` que flavorizr puede generar.
- Por eso las `instructions` apuntan **solo a iOS** y se excluyen los processors `flutter:*` e `ide:config`: así no pisa `lib/main_*.dart`, `Env` ni `launch.json`. Android ya está configurado a mano y se deja como está.

> ⚠️ **Requiere macOS.** `flutter_flavorizr` no corre en Windows. Ejecutá este paso en una Mac (o en CI macOS). En Windows seguís desarrollando y corriendo Android con normalidad.

### Configuración

Agregá este bloque a `pubspec.yaml` (reemplazá `com.kubo.app` por el bundle ID real que definiste en el paso 3):

```yaml
flavorizr:
  ide: vscode
  instructions:
    # Solo iOS — Android ya está configurado en android/app/build.gradle.kts.
    # Se omiten flutter:* e ide:config para no pisar main_*.dart, Env ni launch.json.
    - ios:podfile
    - ios:xcconfig
    - ios:buildTargets
    - ios:schema
    - ios:plist
    - ios:launchScreen
  flavors:
    stg:
      app:
        name: "App STG"
      android:
        applicationId: "com.kubo.app.stg"
      ios:
        bundleId: "com.kubo.app.stg"
    prod:
      app:
        name: "App"
      android:
        applicationId: "com.kubo.app"
      ios:
        bundleId: "com.kubo.app"
```

> Los `applicationId` de Android se incluyen para documentar la paridad de nombres, pero con
> estas `instructions` (solo iOS) no se aplican: el Android sigue siendo el de `build.gradle.kts`.

### Comandos (en macOS)

```bash
flutter pub add dev:flutter_flavorizr
flutter pub get
dart run flutter_flavorizr            # corre las instructions del pubspec
```

Revisá el diff que generó en `ios/` y commiteá esos cambios. A partir de ahí, las
configuraciones de `launch.json` (que ya pasan `--flavor` + `--dart-define-from-file`) y los
comandos de terminal funcionan también en iOS:

```bash
flutter run --flavor stg --dart-define-from-file=env/stg.json -t lib/main_stg.dart
```

### Si querés que flavorizr maneje también Android

Posible, pero **ojo**: el template usa `build.gradle.kts` (Kotlin DSL) y flavorizr genera
sintaxis Groovy. Si agregás los processors `android:*`, revisá que el resultado sea válido
para Kotlin DSL o convertí el `build.gradle` a Groovy. Por defecto **se recomienda dejar
Android como está** (ya funciona) y usar flavorizr solo para iOS.
