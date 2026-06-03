# Arquitectura Clean

**Fuente de verdad** de la arquitectura. Para la tarjeta rápida por capa ver [`layers.md`](layers.md);
para modelos (Entity / DTO / Mapper / Params) ver [`models.md`](models.md).

---

## Capa de Dominio

Es el corazón de la app. Define **qué se necesita**, sin importar cómo ni de dónde viene.

### Convención de nombres
- Interface: nombre limpio (`AuthRepository`, `AuthDatasource`).
- Implementación: sufijo `Impl` (`AuthRepositoryImpl`, `AuthDatasourceImpl`).
- **No** se usa prefijo `I`. Effective Dart desaconseja el estilo Hungarian (`IAuthRepository`):
  en Dart cualquier clase es una interfaz implícita y la intención se expresa con
  `abstract interface class`, no con prefijos en el nombre.

### Interfaz del Datasource
Le dice a la infraestructura: *"quien quiera ser mi fuente de datos, debe saber hacer esto"*.
El dominio no sabe si el dato viene de una API, de un archivo local o de un mock — solo le importa que alguien se lo entregue.

```dart
// Contrato: "alguien me tiene que entregar una sesión, no me importa cómo"
abstract interface class AuthDatasource {
  Future<AuthSession> login({required String email, required String password});
}
```

> La interfaz vive en `domain/` y por eso devuelve **tipos de dominio** (`AuthSession`), nunca
> un DTO de infraestructura — si devolviera un DTO, el dominio importaría infra (leak). La
> traducción DTO→Entity ocurre **dentro del impl** vía el Mapper (ver [`models.md`](models.md)).

### Interfaz del Repository
Le dice a los casos de uso: *"quien quiera ser mi repositorio, debe saber ejecutar esta operación"*.
El dominio no sabe si el token se guarda en disco, en memoria o en la nube — solo le importa que la operación se complete o falle con una excepción de dominio tipada.

```dart
// Contrato: "alguien me ejecuta esto; si algo sale mal, me lanza una excepción de dominio"
abstract interface class AuthRepository {
  Future<AuthSession> login({required String email, required String password});
  Future<void> logout();
  Future<bool> hasValidSession();
}
```

Si algo falla, el repositorio **lanza** una excepción de dominio que extiende de `Failure`
(`AuthFailure`, `NetworkFailure`, …). La capa de presentación la captura con `AsyncValue.guard`.
No usamos `Either` ni wrappers — el mecanismo de errores es Dart puro.

### UseCase
Aplica la regla de negocio. En la mayoría de casos solo delega, pero es el punto donde
se podría agregar lógica pura (validaciones, transformaciones) sin tocar la UI ni la API.

```dart
class LoginUseCase {
  const LoginUseCase(this._repository);
  final AuthRepository _repository;

  Future<AuthSession> call({required String email, required String password}) =>
      _repository.login(email: email, password: password);
}
```

---

## Capa de Infraestructura

Aquí vive el **cómo**. Es la única capa que conoce Dio, JSON, SecureStorage, APIs externas.

### api/ — Directorio de endpoints
Solo constantes. No hace nada, solo nombra las rutas para que si el backend cambia una URL,
haya un único lugar donde corregirlo.

```dart
abstract final class AuthApi {
  static const String login = 'auth/login';
}
```

### datasources/impl — El que va a buscar el dato
Implementa la interfaz del dominio. Habla con la fuente externa, parsea el JSON en un **DTO**
y traduce a Entity con el **Mapper**. **No maneja errores**: si algo falla, deja subir la excepción.

```dart
class AuthDatasourceImpl implements AuthDatasource {
  const AuthDatasourceImpl(this._api);
  final ApiService _api;

  @override
  Future<AuthSession> login({required String email, required String password}) async {
    final data = await _api.post(AuthApi.login, body: {'email': email, 'password': password});
    final dto = AuthResponseDto.fromJson(data as Map<String, dynamic>);
    return AuthMapper.fromDto(dto); // DTO → Entity en un único lugar
  }
}
```

### repositories/impl — El coordinador
Implementa la interfaz del repository. Es el **único lugar con try/catch** en toda la app.
Orquesta datasource + persistencia y **traduce** cualquier error crudo (Dio, parseo, storage)
en una excepción de dominio tipada vía `ApiExceptionHandler.handle(e)`.

```dart
class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({required AuthDatasource datasource, required SecureStorageService storage})
      : _datasource = datasource, _storage = storage;

  final AuthDatasource _datasource;
  final SecureStorageService _storage;

  @override
  Future<AuthSession> login({required String email, required String password}) async {
    try {
      final session = await _datasource.login(email: email, password: password);
      await _storage.saveAccessToken(session.accessToken);
      return session;
    } catch (e) {
      throw ApiExceptionHandler.handle(e);
    }
  }
}
```

---

## Manejo de errores — jerarquía sellada `Failure`

Todas las excepciones de dominio extienden del base **sellado** `Failure`, con un `message`
(texto a mostrar) y un `cause` opcional (el error crudo original, útil para logging).

**Vive en**: `lib/core/errors/failures.dart`

```dart
sealed class Failure implements Exception {
  const Failure({required this.message, this.cause});
  final String message;
  final Object? cause;
  @override
  String toString() => message;
}

final class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Problema de conexión. Revisa tu red.', super.cause});
}
final class TimeoutFailure extends Failure {
  const TimeoutFailure({super.message = 'El servidor tardó demasiado en responder.', super.cause});
}
final class AuthFailure extends Failure {
  const AuthFailure({super.message = 'Credenciales inválidas o sesión expirada.', super.cause});
}
final class ServerFailure extends Failure {
  const ServerFailure({required super.message, required this.statusCode, super.cause});
  final int statusCode;
}
final class UnknownFailure extends Failure {
  const UnknownFailure({super.message = 'Ocurrió un error inesperado.', super.cause});
}
```

### `ApiExceptionHandler` — traduce error crudo → `Failure`

Vive en `lib/core/errors/api_exception_handler.dart`. Mapea el tipo de `DioException`
(timeout, conexión, status code) al subtipo de `Failure` correcto y extrae el mensaje del
backend (`message` / `error` / `detail`) cuando existe.

```dart
abstract final class ApiExceptionHandler {
  static Failure handle(Object error) {
    if (error is Failure) return error;            // ya tipado: pasa de largo
    if (error is DioException) return _fromDio(error);
    return UnknownFailure(cause: error);
  }
  // _fromDio: timeout → TimeoutFailure, connectionError → NetworkFailure,
  // 401/403 → AuthFailure, otros badResponse → ServerFailure(statusCode), ...
}
```

### Mostrar el mensaje al usuario

En la View, `AsyncError.error` es `Object`. Como todo lo que lanza el repo es `Failure`:

```dart
ref.listen(authControllerProvider, (prev, next) {
  next.whenOrNull(
    error: (e, _) {
      final msg = e is Failure ? e.message : 'Error desconocido';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    },
  );
});
```

Para reacciones distintas según tipo, `switch` exhaustivo (sellado → el compilador valida todos los casos):

```dart
final failure = e is Failure ? e : const UnknownFailure();
final msg = switch (failure) {
  NetworkFailure(:final message) => message,
  TimeoutFailure(:final message) => message,
  AuthFailure() => 'Tu sesión expiró, volvé a entrar.',
  ServerFailure(:final message) => message,
  UnknownFailure(:final message) => message,
};
```

---

## Capa de Presentación

Aquí vive la UI y el estado. **No conoce Dio, no conoce JSON, no hace try/catch.** Los únicos errores que llegan acá son excepciones de dominio tipadas, y los captura `AsyncValue.guard`.

### providers/di/ — El ensamblador
Construye y conecta las piezas con Riverpod 3 + code-generation. Cada `@riverpod` describe
cómo construir una pieza; `build_runner` genera el provider real en el `.g.dart`.

**Regla `keepAlive`**: por default `@riverpod` es **auto-dispose**. Las piezas de DI
(datasources, repositories, use cases, services como `ApiService`/`Dio`/storage) son
**stateless** y deben sobrevivir entre pantallas → usar `@Riverpod(keepAlive: true)`.
Solo los controllers con estado por pantalla quedan en auto-dispose default.

```dart
@Riverpod(keepAlive: true)
AuthDatasource authDatasource(Ref ref) =>
    AuthDatasourceImpl(ref.watch(apiServiceProvider));

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
      datasource: ref.watch(authDatasourceProvider),
      storage: ref.watch(secureStorageProvider),
    );

@Riverpod(keepAlive: true)
LoginUseCase loginUseCase(Ref ref) => LoginUseCase(ref.watch(authRepositoryProvider));
```

### Riverpod en una frase
Es el **contenedor de estado y dependencias**: registrás piezas con `@riverpod` y cualquiera
las pide con `ref.watch` / `ref.read` / `ref.listen`. **Regla estricta**: solo `Notifier` y
`AsyncNotifier`. Legacy `StateProvider` / `StateNotifier` están **prohibidos**.

### controllers/ — Coordina la acción y expone el estado

Las acciones no se disparan directo contra el use case desde la View. Viven en un `AsyncNotifier` que:

1. Expone un `AsyncValue<T>` con `loading` / `data` / `error`.
2. Envuelve la llamada al use case con `AsyncValue.guard` — captura cualquier `Failure` y la
   transforma en `AsyncError` **sin `try/catch`**.
3. Verifica `ref.mounted` después de cada `await` antes de tocar `state`.

```dart
@riverpod
class LoginAction extends _$LoginAction {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> submit({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(
      () => ref.read(loginUseCaseProvider)(email: email, password: password),
    );
    if (!ref.mounted) return;
    if (!state.hasError) ref.invalidate(authControllerProvider);
  }
}
```

Dos formas de disparar:
- **Auto-fire en `build()`** — la lógica va en `Future<T> build()`. Ideal para bootstrap (splash que valida sesión al iniciar).
- **Disparo manual desde la View** — `ref.read(p.notifier).submit(...)`. Ideal para input del usuario (tap en login).

### views/ — Observa y reacciona

```dart
class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(loginActionProvider, (prev, next) {
      next.whenOrNull(
        error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e is Failure ? e.message : 'Error desconocido')),
        ),
      );
    });
    // ... formulario que llama ref.read(loginActionProvider.notifier).submit(...)
  }
}
```

### Guía rápida: `ref.watch` vs `ref.read` vs `ref.listen`

| Método | Cuándo | Reconstruye UI | Ejemplo |
|---|---|---|---|
| `ref.watch` | Dentro de `build()` para estado reactivo | Sí | `ref.watch(authControllerProvider)` |
| `ref.read` | Disparar una acción puntual (callbacks, `onPressed`) | No | `ref.read(p.notifier).submit()` |
| `ref.listen` | Efectos efímeros: navegación, snackbars, toasts | No | `ref.listen(p, (prev, next) => ...)` |

---

## Flujo completo — ejemplo login

### Caso exitoso
```
LoginView → ref.read(loginActionProvider.notifier).submit(email, password)
  └─ AsyncValue.guard(() => loginUseCase(email, password))
       └─ LoginUseCase.call()
            └─ AuthRepositoryImpl.login()
                 ├─ AuthDatasourceImpl.login()
                 │    └─ POST auth/login → JSON → AuthResponseDto → AuthMapper.fromDto → AuthSession
                 ├─ SecureStorageService.saveAccessToken(session.accessToken)
                 └─ return AuthSession
                      └─ state = AsyncData(null) → invalidate(authControllerProvider) → router redirige a /home
```

### Caso error
```
AuthRepositoryImpl captura DioException
  └─ throw ApiExceptionHandler.handle(e)  // AuthFailure / NetworkFailure / ServerFailure / ...
       └─ AsyncValue.guard la atrapa
            └─ state = AsyncError(failure, stackTrace)
                 └─ LoginView reacciona (ref.listen) → SnackBar con failure.message
```

Cada capa hace **una sola cosa** y no sabe qué hay arriba ni abajo de ella.
