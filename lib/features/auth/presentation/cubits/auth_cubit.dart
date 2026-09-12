import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repository/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _repository;

  AuthCubit(this._repository) : super(const AuthState());

  Future<void> login(String email, String password) async {
    emit(state.copyWith(status: AuthStatus.loading, errorMessage: null));

    if (email.trim().isEmpty || password.isEmpty) {
      emit(state.copyWith(status: AuthStatus.failure, errorMessage: 'أدخل البريد وكلمة المرور'));
      return;
    }

    final success = await _repository.login(email, password);
    emit(success
        ? state.copyWith(status: AuthStatus.success)
        : state.copyWith(status: AuthStatus.failure, errorMessage: 'بيانات الدخول غير صحيحة'));
  }
}