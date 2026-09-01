import 'package:equatable/equatable.dart';

enum FormFieldType { text, multiline, number, dropdown, boolean, multiChoice }

class DynamicFormField extends Equatable {
  final String id;
  final String label;
  final FormFieldType type;
  final bool isRequired;
  final List<String> options;
  final String? hint;

  const DynamicFormField({
    required this.id,
    required this.label,
    required this.type,
    this.isRequired = false,
    this.options = const [],
    this.hint,
  });

  DynamicFormField copyWith({
    String? label,
    FormFieldType? type,
    bool? isRequired,
    List<String>? options,
    String? hint,
  }) {
    return DynamicFormField(
      id: id,
      label: label ?? this.label,
      type: type ?? this.type,
      isRequired: isRequired ?? this.isRequired,
      options: options ?? this.options,
      hint: hint ?? this.hint,
    );
  }

  @override
  List<Object?> get props => [id, label, type, isRequired, options, hint];
} 