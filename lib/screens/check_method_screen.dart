import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../app/navigation.dart';
import '../data/safety_articles.dart';
import '../models/assessment_draft.dart';
import '../models/scan_category.dart';
import '../services/ocr/ocr_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/common.dart';
import 'article_screen.dart';
import 'input/paste_text_screen.dart';
import 'input/questions_screen.dart';
import 'input/screenshot_flow.dart';

/// "How would you like to check it?"
class CheckMethodScreen extends StatelessWidget {
  const CheckMethodScreen({super.key, required this.category});
  final ScanCategory category;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final ocrSupported = const OcrService().isSupported;
    final isLink = category.id == 'website';
    final article = articleById(category.articleId);

    return Scaffold(
      appBar: AppBar(title: Text(category.shortTitle)),
      body: PageBody(
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(color: AppColors.lightBlue, borderRadius: BorderRadius.circular(16)),
                child: Icon(category.icon, color: AppColors.blue, size: 30),
              ),
              const SizedBox(width: Gap.md),
              Expanded(child: Text(category.title, style: t.headlineSmall)),
            ],
          ),
          const SizedBox(height: Gap.md),
          Text(context.pick(category.description, category.simpleDescription), style: t.bodyLarge),
          if (category.specialNotice != null) ...[
            const SizedBox(height: Gap.md),
            SectionCard(
              color: AppColors.lightBlue,
              borderColor: AppColors.lightBlue,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline_rounded, color: AppColors.navy),
                  const SizedBox(width: Gap.sm + 4),
                  Expanded(child: Text(category.specialNotice!, style: t.bodyMedium)),
                ],
              ),
            ),
          ],
          const SizedBox(height: Gap.xl - 4),
          Text('How would you like to check it?', style: t.titleLarge),
          const SizedBox(height: Gap.md - 4),
          if (!isLink) ...[
            _MethodCard(
              icon: Icons.image_outlined,
              title: 'Upload a screenshot',
              subtitle: ocrSupported
                  ? 'We read the text on your device. You review it before anything is analyzed.'
                  : 'Not available on this device. Please paste the text instead.',
              onTap: () => ScreenshotFlow.start(context, categoryId: category.id),
            ),
            if (ocrSupported)
              _MethodCard(
                icon: Icons.photo_camera_outlined,
                title: 'Take a photo',
                subtitle: 'Photograph a letter, notice, or another screen.',
                onTap: () => ScreenshotFlow.start(context, categoryId: category.id, source: ImageSource.camera),
              ),
          ],
          _MethodCard(
            icon: isLink ? Icons.link_rounded : Icons.content_paste_rounded,
            title: isLink ? 'Paste the link' : 'Paste information',
            subtitle: isLink ? 'Check a web address before you open it.' : 'Paste a message, email, job post, or conversation.',
            onTap: () => Nav.push(context, PasteTextScreen(category: category)),
          ),
          _MethodCard(
            icon: Icons.checklist_rounded,
            title: 'Answer questions',
            subtitle: 'No message to share? Answer a few simple questions.',
            onTap: () => Nav.push(
              context,
              QuestionsScreen(draft: AssessmentDraft(categoryId: category.id, source: InputSource.questions)),
            ),
          ),
          if (article != null) ...[
            const SizedBox(height: Gap.md),
            TextButton.icon(
              onPressed: () => Nav.push(context, ArticleScreen(article: article, showCheckButton: false)),
              icon: const Icon(Icons.menu_book_outlined),
              label: Text('Learn about ${article.title.toLowerCase()}'),
            ),
          ],
        ],
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({required this.icon, required this.title, required this.subtitle, required this.onTap});
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: Gap.sm + 4),
      child: Semantics(
        button: true,
        child: SectionCard(
          onTap: onTap,
          padding: const EdgeInsets.symmetric(horizontal: Gap.md + 2, vertical: Gap.md + 4),
          child: Row(
            children: [
              Icon(icon, color: AppColors.blue, size: 30),
              const SizedBox(width: Gap.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: t.titleMedium),
                    const SizedBox(height: 2),
                    Text(subtitle, style: t.bodySmall),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right_rounded, color: AppColors.mutedText, size: 28),
            ],
          ),
        ),
      ),
    );
  }
}
