import 'package:flutter/material.dart';

import '../models/risk.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// DECEPTION BREAKDOWN — shows the checked message with the exact phrases,
/// links, and claims that triggered each warning sign highlighted and
/// numbered, followed by a plain explanation of how each trick works.
class DeceptionBreakdown extends StatelessWidget {
  const DeceptionBreakdown({super.key, required this.text, required this.signals});

  final String text;
  final List<DetectedSignal> signals;

  static const _highlight = Color(0xFFFFE7A3);

  /// Signals that can be pointed to in the text, numbered in reading order.
  List<_Marked> _markedSignals() {
    final lower = text.toLowerCase();
    final out = <_Marked>[];
    for (final s in signals) {
      var spans = s.spans.where((r) => r.start >= 0 && r.end <= text.length && r.end > r.start).toList();
      // AI findings carry a short quote; find it in the text if we can.
      if (spans.isEmpty && s.source == SignalSource.ai) {
        final quote = (s.evidence ?? '').trim().replaceAll(RegExp(r'^["“]|["”]$'), '');
        if (quote.length >= 4) {
          final at = lower.indexOf(quote.toLowerCase());
          if (at >= 0) spans = [MatchSpan(at, at + quote.length)];
        }
      }
      if (spans.isNotEmpty) {
        spans.sort((a, b) => a.start.compareTo(b.start));
        out.add(_Marked(s, spans));
      }
    }
    out.sort((a, b) => a.spans.first.start.compareTo(b.spans.first.start));
    for (var i = 0; i < out.length; i++) {
      out[i].number = i + 1;
    }
    return out;
  }

  bool get hasContent => text.trim().isNotEmpty && _markedSignals().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final simple = context.simple;
    final marked = _markedSignals();
    if (marked.isEmpty) return const SizedBox.shrink();

    // Flatten into non-overlapping highlight ranges (earliest/longest wins).
    final ranges = <_Range>[];
    for (final m in marked) {
      for (final s in m.spans) {
        ranges.add(_Range(s.start, s.end, m.number));
      }
    }
    ranges.sort((a, b) => a.start != b.start ? a.start.compareTo(b.start) : b.end.compareTo(a.end));
    final kept = <_Range>[];
    for (final r in ranges) {
      if (kept.isEmpty || r.start >= kept.last.end) kept.add(r);
    }

    final base = t.bodyLarge?.copyWith(height: 1.6);
    final children = <InlineSpan>[];
    var pos = 0;
    final shownNumbers = <int>{};
    for (final r in kept) {
      if (r.start > pos) children.add(TextSpan(text: text.substring(pos, r.start)));
      children.add(TextSpan(
        text: text.substring(r.start, r.end),
        style: const TextStyle(
          backgroundColor: _highlight,
          fontWeight: FontWeight.w700,
          color: AppColors.text,
        ),
      ));
      // Show each number once, after its first highlight.
      if (shownNumbers.add(r.number)) {
        children.add(WidgetSpan(alignment: PlaceholderAlignment.middle, child: _NumberBadge(r.number, small: true)));
      }
      pos = r.end;
    }
    if (pos < text.length) children.add(TextSpan(text: text.substring(pos)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          simple
              ? 'The highlighted words are the warning signs.'
              : 'The highlighted words, links, and claims are what triggered this assessment.',
          style: t.bodyMedium?.copyWith(color: AppColors.mutedText),
        ),
        const SizedBox(height: Gap.sm),
        Container(
          constraints: const BoxConstraints(maxHeight: 360),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(Gap.radiusSm),
            border: Border.all(color: AppColors.border),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(Gap.md),
            child: Text.rich(TextSpan(style: base, children: children)),
          ),
        ),
        const SizedBox(height: Gap.md),
        for (final m in marked)
          Padding(
            padding: const EdgeInsets.only(bottom: Gap.sm + 2),
            child: SectionCard(
              padding: const EdgeInsets.all(Gap.md),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _NumberBadge(m.number),
                  const SizedBox(width: Gap.sm + 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '“${_quote(m.spans.first)}”',
                          style: t.titleSmall?.copyWith(color: AppColors.navy),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          simple ? m.signal.definition.simpleReason : m.signal.definition.reason,
                          style: t.bodyMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          simple ? m.signal.definition.group.simpleWhy : m.signal.definition.group.whyItMatters,
                          style: t.bodySmall?.copyWith(fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  String _quote(MatchSpan s) {
    var q = text.substring(s.start, s.end).replaceAll(RegExp(r'\s+'), ' ').trim();
    if (q.length > 80) q = '${q.substring(0, 77)}…';
    return q;
  }
}

class _Marked {
  _Marked(this.signal, this.spans);
  final DetectedSignal signal;
  final List<MatchSpan> spans;
  int number = 0;
}

class _Range {
  _Range(this.start, this.end, this.number);
  final int start;
  final int end;
  final int number;
}

class _NumberBadge extends StatelessWidget {
  const _NumberBadge(this.number, {this.small = false});
  final int number;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final size = small ? 20.0 : 28.0;
    return Container(
      width: size,
      height: size,
      margin: small ? const EdgeInsets.only(left: 3, right: 2) : null,
      alignment: Alignment.center,
      decoration: const BoxDecoration(color: AppColors.navy, shape: BoxShape.circle),
      child: Text(
        '$number',
        style: TextStyle(
          color: AppColors.white,
          fontSize: small ? 11 : 14,
          fontWeight: FontWeight.w800,
          height: 1,
        ),
        textScaler: TextScaler.noScaling,
      ),
    );
  }
}
