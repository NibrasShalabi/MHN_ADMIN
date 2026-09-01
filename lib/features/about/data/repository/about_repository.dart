import '../../domain/entities/about_content.dart';

abstract class AboutRepository {
  Future<AboutContent> getContent();
  Future<void> updateContent(AboutContent content);
}