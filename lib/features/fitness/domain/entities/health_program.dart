import 'package:equatable/equatable.dart';

import 'dynamic_form_field.dart';

class HealthProgram extends Equatable {
  final String id;
  final String title;
  final String intro;
  final List<DynamicFormField> fields;
  final String coachWhatsappUrl;
  final List<String> suggestedProgramIds;

  const HealthProgram({
    required this.id,
    required this.title,
    this.intro = '',
    this.fields = const [],
    this.coachWhatsappUrl = '',
    this.suggestedProgramIds = const [],
  });

  HealthProgram copyWith({
    String? title,
    String? intro,
    List<DynamicFormField>? fields,
    String? coachWhatsappUrl,
    List<String>? suggestedProgramIds,
  }) {
    return HealthProgram(
      id: id,
      title: title ?? this.title,
      intro: intro ?? this.intro,
      fields: fields ?? this.fields,
      coachWhatsappUrl: coachWhatsappUrl ?? this.coachWhatsappUrl,
      suggestedProgramIds: suggestedProgramIds ?? this.suggestedProgramIds,
    );
  }

  @override
  List<Object?> get props => [id, title, intro, fields, coachWhatsappUrl, suggestedProgramIds];
}