import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Drops emits after close() — async work, timers and work inside close()
/// can finish after the page is disposed.
abstract class SafeCubit<S> extends Cubit<S> {
  SafeCubit(super.initialState);

  @override
  void emit(S state) {
    if (isClosed) {
      debugPrint('[$runtimeType] emit after close ignored');
      return;
    }
    super.emit(state);
  }
}