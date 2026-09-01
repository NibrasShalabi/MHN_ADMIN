import '../../../../core/constants/admin_strings.dart';
import '../../domain/entities/dynamic_form_field.dart';

extension FormFieldTypeX on FormFieldType {
  String get label => switch (this) {
    FormFieldType.text => AdminStrings.typeText,
    FormFieldType.multiline => AdminStrings.typeMultiline,
    FormFieldType.number => AdminStrings.typeNumber,
    FormFieldType.dropdown => AdminStrings.typeDropdown,
    FormFieldType.boolean => AdminStrings.typeBoolean,
    FormFieldType.multiChoice => AdminStrings.typeMultiChoice,
  };

  bool get needsOptions => this == FormFieldType.dropdown || this == FormFieldType.multiChoice;
}