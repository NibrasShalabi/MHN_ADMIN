import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repository/about_repository.dart';
import '../../domain/entities/about_content.dart';
import 'about_state.dart';

class AboutCubit extends Cubit<AboutState> {
  final AboutRepository _repository;

  AboutCubit(this._repository) : super(const AboutState());

  Future<void> load() async {
    emit(state.copyWith(status: AboutStatus.loading));
    try {
      final content = await _repository.getContent();
      emit(state.copyWith(status: AboutStatus.loaded, content: content));
    } catch (e) {
      emit(state.copyWith(status: AboutStatus.error, errorMessage: e.toString()));
    }
  }

  Future<void> save(AboutContent content) async {
    await _repository.updateContent(content);
    emit(state.copyWith(content: content));
  }
}