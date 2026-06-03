import 'package:clean_riverpod_starter/core/network/api_service.dart';
import 'package:clean_riverpod_starter/features/auth/domain/datasources/auth_datasource.dart';
import 'package:clean_riverpod_starter/features/auth/domain/entities/auth_session.dart';
import 'package:clean_riverpod_starter/features/auth/infrastructure/api/auth_api.dart';
import 'package:clean_riverpod_starter/features/auth/infrastructure/mappers/auth_mapper.dart';
import 'package:clean_riverpod_starter/features/auth/infrastructure/models/auth_response_dto.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_datasource_impl.g.dart';

class AuthDatasourceImpl implements AuthDatasource {
  const AuthDatasourceImpl(this._api);

  final ApiService _api;

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final data = await _api.post(
      AuthApi.login,
      body: {'email': email, 'password': password},
    );
    final dto = AuthResponseDto.fromJson(data as Map<String, dynamic>);
    return AuthMapper.fromDto(dto);
  }
}

@Riverpod(keepAlive: true)
AuthDatasource authDatasource(Ref ref) =>
    AuthDatasourceImpl(ref.watch(apiServiceProvider));
