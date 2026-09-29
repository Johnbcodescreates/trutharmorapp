import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/scan_category.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import 'common.dart';

/// An official help/reporting resource with call + website buttons.
class ResourceCard extends StatelessWidget {
  const ResourceCard({super.key, required this.resource});
  final HelpResource resource;

  Future<void> _open(BuildContext context, Uri uri) async {
    try {
      final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!ok && context.mounted) _fail(context);
    } catch (_) {
      if (context.mounted) _fail(context);
    }
  }

  void _fail(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Couldn't open that on this device.")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final r = resource;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm + 2),
      child: SectionCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(r.name, style: t.titleMedium),
            const SizedBox(height: 2),
            Text(r.detail, style: t.bodyMedium?.copyWith(color: AppColors.mutedText)),
            if (r.phone != null || r.url != null) const SizedBox(height: Gap.sm),
            Wrap(
              spacing: Gap.sm,
              runSpacing: Gap.xs,
              children: [
                if (r.phone != null)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
                    onPressed: () => _open(context, Uri(scheme: 'tel', path: r.phone!.replaceAll(RegExp(r'[^0-9+]'), ''))),
                    icon: const Icon(Icons.call_outlined, size: 20),
                    label: Text(r.phone!),
                  ),
                if (r.url != null)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(minimumSize: const Size(48, 48)),
                    onPressed: () => _open(context, Uri.parse(r.url!)),
                    icon: const Icon(Icons.open_in_new_rounded, size: 20),
                    label: const Text('Website'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
