import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'secure_storage_service.g.dart';

class SecureStorageService {
  const SecureStorageService(this._storage);

  final FlutterSecureStorage _storage;

  static const _kAccessToken = 'access_token';

  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _kAccessToken, value: token);

  Future<String?> readAccessToken() => _storage.read(key: _kAccessToken);

  Future<void> clearAccessToken() => _storage.delete(key: _kAccessToken);
}

@Riverpod(keepAlive: true)
SecureStorageService secureStorage(Ref ref) =>
    const SecureStorageService(FlutterSecureStorage());
