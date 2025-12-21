import 'package:flutter_test/flutter_test.dart';
import 'package:tackle4loss_mobile/micro_apps/deep_dive/controllers/deep_dive_controller.dart';
import 'package:tackle4loss_mobile/micro_apps/deep_dive/models/deep_dive_article.dart';

class TestDeepDiveController extends DeepDiveController {
  @override
  Future<List<DeepDiveArticle>> fetchDeepDives(String languageCode) async {
    // Mock network delay to verify loading state logic
    await Future.delayed(const Duration(milliseconds: 10));
    return [
      DeepDiveArticle(
        id: '1',
        title: 'Test Article',
        summary: 'Summary',
        content: 'Content',
        imageUrl: 'url',
        publishedAt: DateTime.now(),
        author: 'Author',
        languageCode: 'en',
      )
    ];
  }
}

void main() {
  late TestDeepDiveController controller;

  setUp(() {
    controller = TestDeepDiveController();
  });

  group('DeepDiveController', () {
    test('initial state is correct', () {
      expect(controller.articles, isEmpty);
      expect(controller.isLoading, false);
    });

    test('loadAllArticles updates internal state', () async {
      final future = controller.loadAllArticles('en');
      
      // Loading should be true while future is pending
      expect(controller.isLoading, true);
      
      await future;
      
      // Loading should be false after completion
      expect(controller.isLoading, false);
      expect(controller.articles.length, 1);
      expect(controller.articles.first.id, '1');
    });
  });
}
