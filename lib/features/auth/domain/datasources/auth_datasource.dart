import 'package:clean_riverpod_starter/features/auth/domain/entities/auth_session.dart';

abstract interface class AuthDatasource {
  Future<AuthSession> login({
    required String email,
    required String password,
  });
}
