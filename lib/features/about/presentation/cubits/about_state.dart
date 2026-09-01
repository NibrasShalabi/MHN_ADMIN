import 'package:equatable/equatable.dart';

import '../../domain/entities/about_content.dart';

enum AboutStatus { initial, loading, loaded, error }

class AboutState extends Equatable {
  final AboutStatus status;
  final AboutContent content;
  final String? errorMessage;

  const AboutState({
    this.status = AboutStatus.initial,
    this.content = const AboutContent(),
    this.errorMessage,
  });

  AboutState copyWith({
    AboutStatus? status,
    AboutContent? content,
    String? errorMessage,
  }) {
    return AboutState(
      status: status ?? this.status,
      content: content ?? this.content,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, content, errorMessage];
}