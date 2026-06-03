# Reglas por Capa

Tarjeta de referencia rápida: *"estoy en la capa X, ¿qué puedo hacer y qué está prohibido?"*.
Para la narrativa completa ver [`architecture.md`](architecture.md).

Regla de oro: el error se **lanza** (no se envuelve en `Either`) y solo se atrapa en
**dos** puntos — el Repository (`try/catch` → `Failure`) y el Controller (`AsyncValue.guard`).
En el medio, las excepciones viajan hacia arriba.

## DataSource (Infraestructura)
- Retorna `Future<T>` con un **tipo de dominio** (Entity), porque su interfaz vive en `domain/`.
- Internamente: parsea JSON → DTO → `Mapper.fromDto` → Entity.
- **No** maneja errores: si algo falla, deja que la excepción suba.
- Solo interactúa con `ApiService` / fuentes externas.
- Prohibido: `try/catch`, `Either`, logging, lógica de negocio, exponer un DTO al dominio.

```dart
class AuthDatasourceImpl implements AuthDatasource {
  @override
  Future<AuthSession> login({required String email, required String password}) async {
    final data = await _api.post(AuthApi.login, body: {'email': email, 'password': password});
    final dto = AuthResponseDto.fromJson(data as Map<String, dynamic>);
    return AuthMapper.fromDto(dto);
  }
}
```

## Repository (Infraestructura)
- Retorna `Future<T>` (**no** `Either`).
- **Único lugar con `try/catch`** en toda la app.
- En el `catch`: `throw ApiExceptionHandler.handle(e)` → lanza un `Failure` tipado.
- Orquesta datasource + persistencia (storage).
- Implementa la interfaz definida en dominio.

```dart
class AuthRepositoryImpl implements AuthRepository {
  @override
  Future<AuthSession> login({required String email, required String password}) async {
    try {
      final session = await _datasource.login(email: email, password: password);
      await _storage.saveAccessToken(session.accessToken);
      return session;
    } catch (e) {
      throw ApiExceptionHandler.handle(e); // traduce a Failure y re-lanza
    }
  }
}
```

## UseCase (Dominio)
- Retorna `Future<T>`.
- Sin `try/catch`: las excepciones del repo pasan de largo hacia arriba.
- Solo delega al repository + aplica reglas de negocio puras.
- No conoce Dio, Flutter ni JSON.

```dart
class LoginUseCase {
  Future<AuthSession> call({required String email, required String password}) =>
      _repository.login(email: email, password: password);
}
```

## Presentation — Controller (`AsyncNotifier`)
- Expone `AsyncValue<T>` (loading / data / error).
- Envuelve la llamada al use case con `AsyncValue.guard` — **sin `try/catch`**.
- Verifica `ref.mounted` después de cada `await`.

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

## Presentation — View (`ConsumerWidget`)
- `ref.watch` para pintar estado; `ref.listen` para efectos efímeros (navegación, snackbars).
- Sin `try/catch`.
- Prohibido acceder a Repository o DataSource directamente.

## DI providers (Presentation)
- Piezas stateless (datasource, repo, use case, services) → `@Riverpod(keepAlive: true)`.
- Controllers con estado por pantalla → `@riverpod` (auto-dispose).

## Tabla resumen

| Capa | Retorna | ¿Maneja error? | Puede tocar | Prohibido |
|---|---|---|---|---|
| DataSource | `Future<Entity>` | ❌ deja subir | `ApiService` / API + Mapper | try/catch, Either, exponer DTO al dominio |
| Repository | `Future<T>` | ✅ único `try/catch` → `throw Failure` | datasource + storage | devolver Either |
| UseCase | `Future<T>` | ❌ deja subir | repository + lógica pura | Dio, Flutter, JSON |
| Controller | `AsyncValue<T>` | ✅ `AsyncValue.guard` | usecase (vía provider) | try/catch |
| View | widgets | reacciona al `AsyncValue` | controller (watch/listen) | repo/datasource directo |
