import '../../../../core/bloc/safe_cubit.dart';

import '../../data/repository/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends SafeCubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthState());

  Future<void> login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    if (email.trim().isEmpty || password.isEmpty) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: 'ط£ط¯ط®ظ„ ط§ظ„ط¨ط±ظٹط¯ ظˆظƒظ„ظ…ط© ط§ظ„ظ…ط±ظˆط±'));
      return;
    }

    final success = await _repository.login(email, password);
    emit(success
        ? state.copyWith(status: AuthStatus.success)
        : state.copyWith(status: AuthStatus.failure, errorMessage: 'ط¨ظٹط§ظ†ط§طھ ط§ظ„ط¯ط®ظˆظ„ ط؛ظٹط± طµط­ظٹط­ط©'));
  }
}