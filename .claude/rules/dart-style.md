# Convenciones Dart / Flutter

## Nombrado
- Clases y Widgets: PascalCase
- Variables y métodos: camelCase
- Archivos: snake_case.dart
- Miembros privados: _prefijo
- Identificadores en inglés; textos de UI en español (ver [`naming.md`](naming.md)).

## Interfaces e implementaciones
- Interface: nombre limpio, **sin** prefijo `I` (`AuthRepository`, no `IAuthRepository`).
  Effective Dart desaconseja el estilo Hungarian; la intención se declara con
  `abstract interface class`.
- Implementación pública: sufijo `Impl` (`AuthRepositoryImpl`) en `infrastructure/`.
- Archivos: `auth_repository.dart` (interface) / `auth_repository_impl.dart` (impl).

## Orden de imports
1. Dart core (dart:async, dart:io...)
2. Paquetes externos (flutter/, riverpod/, dio/...)
3. Proyecto (package:mi_app/...) en orden alfabético

## Comentarios
- Solo explicar el "por qué", nunca el "qué"
- No comentar código que ya es autoexplicativo
- Prohibido: // incrementa el contador en 1

## const
- Usar const siempre que sea posible en constructores de widgets
- Preferir const constructors para performance

## Archivos
- Un widget principal por archivo
- Nombre del archivo = nombre del widget en snake_case
  ProfileHeaderSection → profile_header_section.dart

## Prohibido
- Prefijo `I` en interfaces
- Lógica de formateo dentro de widgets (fechas, moneda, números)
- try-catch en UseCase o Presentation
- Acceso directo a DataSource desde UI
- `Either` / wrappers para errores (se lanzan `Failure`; ver [`architecture.md`](architecture.md))
