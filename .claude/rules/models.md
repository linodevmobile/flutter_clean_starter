# Organización de Modelos

Cuatro piezas, cada una en su mundo. Dos direcciones:
- **Entra** dato del API → DTO → (Mapper) → Entity. *(lectura)*
- **Sale** dato tuyo → Params → JSON → API. *(escritura)*

## Tipos y ubicación
- Entity  → `lib/features/[x]/domain/entities/`
- Params  → `lib/features/[x]/domain/params/`
- DTO     → `lib/features/[x]/infrastructure/models/`
- Mapper  → `lib/features/[x]/infrastructure/mappers/`

## Herramientas (este template usa `freezed`)
- **Entity**: `@freezed` **sin** `fromJson`/`toJson`. Es dominio puro: el `freezed` solo le
  da `==`, `hashCode`, `copyWith` y `toString`. **Prohibido** agregarle serialización o
  imports de infra (Dio, json).
- **DTO**: `@freezed` **con** `fromJson` (`json_serializable`). Refleja la forma exacta de la
  respuesta del API. Vive en infraestructura — el dominio nunca lo conoce.
- **Params**: clase simple con `toJson` (nunca `fromJson`). Existe solo para enviar datos al API.
- **Mapper**: clase con constructor privado `._()` y métodos `static`. Convierte `DTO → Entity`.
  Es el **único lugar** con la traducción fea (snake_case → camelCase, String → int, código → enum).
  Puede importar DTOs (infra) y Entities (dominio): infra → dominio es la dirección correcta.

> ¿Por qué `freezed` en Entity pero `Equatable` no? La regla dura de Clean Architecture es que
> el dominio **no serialice ni dependa del formato del backend**. Una Entity `@freezed` sin
> `fromJson` ya cumple eso. Mantener una sola herramienta de modelado (freezed) en todo el repo
> evita boilerplate manual (`props`, `==`) y una dependencia extra.

## Ejemplo

API devuelve (crudo):
```json
{ "user": { "id": "abc", "email": "a@b.com", "full_name": "Juan Pérez", "phone": null },
  "session": { "access_token": "eyJhbG..." } }
```

### DTO — calcado al API (`@freezed` + `fromJson`)
```dart
// infrastructure/models/auth_response_dto.dart
@freezed
abstract class UserDto with _$UserDto {
  const factory UserDto({
    required String id,
    required String email,
    required String fullName,
    String? phone,
  }) = _UserDto;

  factory UserDto.fromJson(Map<String, dynamic> json) => _$UserDtoFromJson(json);
}
```

### Entity — dominio limpio (`@freezed` sin json)
```dart
// domain/entities/user.dart
@freezed
abstract class User with _$User {
  const factory User({
    required String id,
    required String email,
    required String fullName,
    String? phone,
  }) = _User;
}
```

### Mapper — la aduana (DTO → Entity, único lugar)
```dart
// infrastructure/mappers/auth_mapper.dart
class AuthMapper {
  AuthMapper._();

  static AuthSession fromDto(AuthResponseDto dto) => AuthSession(
        user: User(
          id: dto.user.id,
          email: dto.user.email,
          fullName: dto.user.fullName,
          phone: dto.user.phone,
        ),
        accessToken: dto.session.accessToken,
      );
}
```

### Params — formulario de envío (`toJson`, nunca `fromJson`)
```dart
// domain/params/create_trip_params.dart
class CreateTripParams {
  const CreateTripParams({required this.pickupLat, required this.pickupLng});
  final double pickupLat;
  final double pickupLng;

  Map<String, dynamic> toJson() => {'pickup_lat': pickupLat, 'pickup_lng': pickupLng};
}
```

## ¿Quién invoca el Mapper?
El **datasource impl**, porque su interfaz vive en `domain/` y debe devolver Entities (no DTOs).
Si devolviera el DTO, el dominio importaría infra (leak). Ver [`layers.md`](layers.md).

## Prohibido
- Entity con `fromJson`/`toJson` o imports de infra.
- DTO en la capa de dominio.
- Lógica de transformación (parseo, mapeo de enums) fuera del Mapper.
- Dominio importando DTOs de infraestructura.

## Por qué
Si la Entity tuviera `fromJson`, quedaría casada con la forma exacta del JSON: cualquier cambio
del backend (`full_name` → `fullName`) rompería el dominio en cascada. Aislando la forma del API
en el DTO y convirtiendo en un solo lugar (Mapper), un cambio del backend toca **un archivo**.
