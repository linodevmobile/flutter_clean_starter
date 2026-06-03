import 'package:clean_riverpod_starter/features/auth/domain/usecases/login_usecase.dart';
import 'package:clean_riverpod_starter/features/auth/infrastructure/repositories/auth_repository_impl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'auth_controller.g.dart';

@Riverpod(keepAlive: true)
LoginUseCase loginUseCase(Ref ref) =>
    LoginUseCase(ref.watch(authRepositoryProvider));

@riverpod
class AuthController extends _$AuthController {
  @override
  Future<bool> build() =>
      ref.read(authRepositoryProvider).hasValidSession();

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    ref.invalidateSelf();
  }
}
