import 'package:clean_riverpod_starter/features/auth/domain/entities/auth_session.dart';
import 'package:clean_riverpod_starter/features/auth/domain/entities/user.dart';
import 'package:clean_riverpod_starter/features/auth/infrastructure/models/auth_response_dto.dart';

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
