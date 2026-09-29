import '../data/categories.dart';
import '../models/scan_category.dart';
import 'rules/url_analyzer.dart';

class CategoryGuess {
  const CategoryGuess(this.category, this.confident);
  final ScanCategory category;

  /// False when nothing clearly matched (we then suggest "Suspicious Message").
  final bool confident;
}

/// Quick Scan: guesses which category some text belongs to, so we can ask
/// "This appears to be related to a job opportunity — analyze it as one?".
/// The user always confirms or picks a different category.
class CategoryDetector {
  const CategoryDetector({this.urlAnalyzer = const UrlAnalyzer()});

  final UrlAnalyzer urlAnalyzer;

  CategoryGuess detect(String text) {
    final t = text.toLowerCase().trim();
    if (t.isEmpty) return const CategoryGuess(Categories.aiMessage, false);

    // A bare link on its own -> Website or Link.
    final words = t.split(RegExp(r'\s+'));
    if (words.length <= 2 && urlAnalyzer.extractUrls(t).isNotEmpty) {
      return const CategoryGuess(Categories.website, true);
    }

    ScanCategory? best;
    var bestScore = 0;
    for (final c in Categories.all) {
      var score = 0;
      for (final k in c.detectionKeywords) {
        if (_containsWord(t, k)) score += k.contains(' ') ? 2 : 1;
      }
      if (score > bestScore) {
        best = c;
        bestScore = score;
      }
    }

    if (best == null || bestScore < 2) {
      return const CategoryGuess(Categories.aiMessage, false);
    }
    return CategoryGuess(best, bestScore >= 3);
  }

  static bool _containsWord(String text, String keyword) {
    final escaped = RegExp.escape(keyword);
    return RegExp('(^|[^a-z])$escaped([^a-z]|\$)').hasMatch(text);
  }
}
