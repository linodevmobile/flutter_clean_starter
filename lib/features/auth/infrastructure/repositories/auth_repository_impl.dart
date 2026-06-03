import 'package:clean_riverpod_starter/core/errors/api_exception_handler.dart';
import 'package:clean_riverpod_starter/core/storage/secure_storage_service.dart';
import 'package:clean_riverpod_starter/features/auth/domain/datasources/auth_datasource.dart';
import 'package:clean_riverpod_starter/features/auth/domain/entities/auth_session.dart';
import 'package:clean_riverpod_starter/features/auth/domain/repositories/auth_repository.dart';
import 'package:clean_riverpod_starter/features/auth/infrastructure/datasources/auth_datasource_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_repository_impl.g.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl({
    required AuthDatasource datasource,
    required SecureStorageService storage,
  })  : _datasource = datasource,
        _storage = storage;

  final AuthDatasource _datasource;
  final SecureStorageService _storage;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    try {
      final session = await _datasource.login(email: email, password: password);
      await _storage.saveAccessToken(session.accessToken);
      return session;
    } catch (e) {
      throw ApiExceptionHandler.handle(e);
    }
  }

  @override
  Future<void> logout() async {
    try {
      await _storage.clearAccessToken();
    } catch (e) {
      throw ApiExceptionHandler.handle(e);
    }
  }

  @override
  Future<bool> hasValidSession() async {
    try {
      final token = await _storage.readAccessToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      throw ApiExceptionHandler.handle(e);
    }
  }
}

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) => AuthRepositoryImpl(
      datasource: ref.watch(authDatasourceProvider),
      storage: ref.watch(secureStorageProvider),
    );
