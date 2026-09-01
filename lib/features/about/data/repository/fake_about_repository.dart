import '../../domain/entities/about_content.dart';
import 'about_repository.dart';

class FakeAboutRepository implements AboutRepository {
  AboutContent _content = const AboutContent(
    heroTitle: 'MHN Shopping',
    heroSubtitle: 'جودة تثق بها، توصلك أينما كنت.',
    mission: 'نسعى لتقديم منتجات عناية أصلية بأسعار عادلة وخدمة تليق بثقة عملائنا.',
    goals: [
      AboutGoal(id: 'G-1', title: 'الجودة', description: 'منتجات أصلية مضمونة المصدر.', icon: GoalIcon.quality),
      AboutGoal(id: 'G-2', title: 'الثقة', description: 'شفافية كاملة بكل تفاصيل المنتج.', icon: GoalIcon.trust),
    ],
    source: 'نستورد مباشرة من الموزعين المعتمدين ونتحقق من كل شحنة قبل عرضها.',
    contactText: 'يسعدنا تواصلكم معنا بأي وقت عبر صفحة الدعم.',
  );

  @override
  Future<AboutContent> getContent() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _content;
  }

  @override
  Future<void> updateContent(AboutContent content) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _content = content;
  }
}