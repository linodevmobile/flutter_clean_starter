# Convención de Nombres — Identificadores en inglés

## Regla
Todos los **identificadores de código** van en **inglés**, siguiendo las convenciones
estándar de programación: nombres de clases, variables, métodos, parámetros, enums y
**valores** de enum.

## Excepción
Los **textos visibles para el usuario** permanecen en español: strings de UI, claves de
traducción (ARB), mensajes. La capa de presentación muestra español; el código se nombra
en inglés.

## Ejemplos
```dart
// ❌ Prohibido
enum Prioridad { alta, normal, baja }
class Familia { final String ambito; }
final casa = obtenerCasa();

// ✅ Correcto
enum Priority { high, normal, low }
class Family { final String scope; }
final house = getHouse();
```

Mapeos típicos: `Ambito → Scope`, `Prioridad → Priority`, `individuo → individual`,
`casa → house`, `familia → family`, `urgente → urgent`, `alta → high`, `baja → low`.

## Por qué
Mantiene el código alineado con las APIs de Dart/Flutter (todas en inglés), evita el
"spanglish" en identificadores y hace el código portable y legible para cualquier dev.

## Cuándo no aplica
- Strings mostrados al usuario (`Text('Cancelar')`) → español.
- Claves de localización en `lib/l10n/arb/` → su valor es español; la **clave** sí en inglés.
