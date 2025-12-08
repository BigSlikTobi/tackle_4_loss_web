import 'package:intl/intl.dart';

class ArticleSection {
  final String id;
  final String headline;
  final List<String> content;

  ArticleSection({
    required this.id,
    required this.headline,
    required this.content,
  });
}

class Article {
  final String id;
  final String title;
  final String subtitle;
  final String author;
  final String date;
  final String heroImage;
  final String? audioFile;
  final String? videoFile;
  final String languageCode;
  final List<ArticleSection> sections;

  Article({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.author,
    required this.date,
    required this.heroImage,
    this.audioFile,
    this.videoFile,
    required this.languageCode,
    required this.sections,
  });

  factory Article.fromSupabase(Map<String, dynamic> json) {
    final sectionsMap = Map<String, dynamic>.from(json['sections'] ?? {});
    
    final sortedKeys = sectionsMap.keys.toList()
      ..sort((a, b) {
        final numA = int.tryParse(a.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        final numB = int.tryParse(b.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
        return numA.compareTo(numB);
      });

    final sections = sortedKeys.map((key) {
      final rawText = sectionsMap[key] as String;
      final lines = rawText.split('\n');
      
      String headline = 'Section';
      final headlineLine = lines.firstWhere(
        (line) => line.startsWith('## '),
        orElse: () => '',
      );
      if (headlineLine.isNotEmpty) {
        headline = headlineLine.replaceFirst('## ', '').trim();
      }

      final content = lines
        .where((line) => !line.startsWith('## '))
        .map((line) => line.startsWith('### ') ? line.replaceFirst('### ', '').trim() : line)
        .where((line) => line.trim().isNotEmpty)
        .toList();

      return ArticleSection(
        id: key,
        headline: headline,
        content: content,
      );
    }).toList();

    return Article(
      id: json['id'],
      title: json['title'],
      subtitle: json['subtitle'],
      author: json['author'],
      date: DateFormat('MMMM d, yyyy', json['language_code'] ?? 'de').format(DateTime.parse(json['published_at'])),
      heroImage: json['hero_image_url'],
      audioFile: json['audio_file'],
      videoFile: json['video_file'],
      languageCode: json['language_code'] ?? 'de',
      sections: sections,
    );
  }
}
