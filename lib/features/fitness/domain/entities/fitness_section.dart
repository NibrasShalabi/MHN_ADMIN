import 'health_program.dart';

/// The four programs the app is built around. Their ids are fixed — the
/// app's fitness pyramid places each one by id — so the admin edits them
/// rather than creating new ones.
enum FitnessSection {
  bodyManagement('hp1', 'إدارة الجسم'),
  yoga('yoga', 'يوغا'),
  pilates('pilates', 'بيلاتس'),
  nutrition('nutrition', 'التغذية');

  final String id;
  final String defaultTitle;
  const FitnessSection(this.id, this.defaultTitle);

  static FitnessSection? byId(String id) => values.where((s) => s.id == id).firstOrNull;

  HealthProgram get empty => HealthProgram(id: id, title: defaultTitle);
}
