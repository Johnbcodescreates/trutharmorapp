import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/navigation.dart';
import '../../data/demo_examples.dart';
import '../../models/assessment_draft.dart';
import '../../models/scan_category.dart';
import '../../services/transcription/transcription_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../demo_example_detail_screen.dart';
import 'ocr_review_screen.dart';

/// VOICE MESSAGE check: audio file → transcript → user review → analysis.
///
/// TruthArmor does not claim to detect AI or cloned voices. It checks what the
/// message asks you to do — which is where every voice scam gives itself away.
class VoiceMessageScreen extends StatefulWidget {
  const VoiceMessageScreen({super.key, required this.category, this.quickScan = false});
  final ScanCategory category;
  final bool quickScan;

  @override
  State<VoiceMessageScreen> createState() => _VoiceMessageScreenState();
}

class _VoiceMessageScreenState extends State<VoiceMessageScreen> {
  bool _working = false;
  String? _error;

  Future<void> _pickAndTranscribe() async {
    setState(() => _error = null);
    final service = context.read<TranscriptionService>();

    FilePickerResult? picked;
    try {
      picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: TranscriptionService.mimeByExtension.keys.toList(),
        withData: true,
      );
    } catch (_) {
      setState(() => _error = "We couldn't open your files. Please try again.");
      return;
    }
    if (picked == null || picked.files.isEmpty || !mounted) return; // cancelled

    final file = picked.files.first;
    final ext = (file.extension ?? file.name.split('.').last).toLowerCase();
    final mime = TranscriptionService.mimeByExtension[ext];
    final bytes = file.bytes;
    if (mime == null) {
      setState(() => _error = 'Please choose an MP3, M4A, WAV, MP4, or WEBM recording.');
      return;
    }
    if (bytes == null || bytes.isEmpty) {
      setState(() => _error = "We couldn't read that file. Please try another recording.");
      return;
    }
    if (bytes.length > TranscriptionService.maxBytes) {
      setState(() => _error = 'This recording is too large. Please use a file under 20 MB.');
      return;
    }

    setState(() => _working = true);
    try {
      final text = await service.transcribe(bytes, mime);
      if (!mounted) return;
      setState(() => _working = false);
      Nav.push(
        context,
        OcrReviewScreen(
          draft: AssessmentDraft(categoryId: widget.category.id, text: text, source: InputSource.voice),
          quickScan: widget.quickScan,
        ),
      );
    } on TranscriptionException catch (e) {
      if (mounted) {
        setState(() {
          _working = false;
          _error = e.userMessage;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _working = false;
          _error = 'Something went wrong. Please try again.';
        });
      }
    }
  }

  void _openDemo() {
    final demo = kDemoExamples.firstWhere((e) => e.id == 'demo_voice', orElse: () => kDemoExamples.first);
    Nav.push(context, DemoExampleDetailScreen(example: demo));
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final available = context.read<TranscriptionService>().isAvailable;

    return Scaffold(
      appBar: AppBar(title: const Text('Voice message')),
      body: PageBody(
        children: [
          Text('Check a voice message or voicemail', style: t.headlineSmall),
          const SizedBox(height: Gap.sm),
          Text(
            'Scammers can now copy a loved one\'s voice from a few seconds of video. TruthArmor turns the recording '
            'into text and checks what the caller is asking you to do.',
            style: t.bodyLarge,
          ),
          const SizedBox(height: Gap.md),

          // Honest limitation — a core TruthArmor principle.
          SectionCard(
            color: AppColors.lightBlue,
            borderColor: AppColors.lightBlue,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.info_outline_rounded, color: AppColors.navy),
                const SizedBox(width: Gap.sm + 4),
                Expanded(
                  child: Text(
                    'TruthArmor cannot tell whether a voice is real or AI-generated — no tool can do that reliably. '
                    'Instead, it looks for the warning signs in what is said: emergencies, secrecy, and requests '
                    'for money or information.',
                    style: t.bodyMedium,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: Gap.lg),

          if (!available) ...[
            const FriendlyError(
              'DEMO MODE: Voice messages need the TruthArmor secure server, which is not connected yet. '
              'You can still try the demo voicemail below.',
            ),
            const SizedBox(height: Gap.md),
            WideButton(
              label: 'Try the demo voicemail',
              icon: Icons.play_circle_outline_rounded,
              onPressed: _openDemo,
            ),
          ] else ...[
            WideButton(
              label: _working ? 'Turning speech into text…' : 'Choose a voice recording',
              icon: Icons.graphic_eq_rounded,
              onPressed: _working ? null : _pickAndTranscribe,
            ),
            if (_working) ...[
              const SizedBox(height: Gap.md),
              const LinearProgressIndicator(),
              const SizedBox(height: Gap.sm),
              Text('This usually takes 10–30 seconds.', style: t.bodySmall, textAlign: TextAlign.center),
            ],
            const SizedBox(height: Gap.sm),
            Text('MP3, M4A, WAV, MP4, or WEBM · up to 20 MB', style: t.bodySmall, textAlign: TextAlign.center),
            const SizedBox(height: Gap.md),
            TextButton.icon(
              onPressed: _openDemo,
              icon: const Icon(Icons.play_circle_outline_rounded),
              label: const Text('Or try the demo voicemail'),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: Gap.md),
            FriendlyError(_error!),
          ],
          const SizedBox(height: Gap.lg),

          const SectionTitle('Getting the recording', icon: Icons.help_outline_rounded),
          const SectionCard(
            child: BulletList([
              'iPhone voicemail: open it in the Phone app, tap Share, and save it to Files.',
              'Android voicemail: in your voicemail app, use Save or Share to export the audio file.',
              'Voice notes from messaging apps can usually be shared or saved as an audio file.',
              'On a computer, download the recording first, then choose it here.',
            ]),
          ),
          const SizedBox(height: Gap.lg),

          const SectionTitle('Privacy', icon: Icons.lock_outline_rounded),
          SectionCard(
            child: Text(
              'Unlike screenshots, a voice message has to be sent — securely — to the TruthArmor server to be turned '
              'into text by OpenAI\'s speech-to-text service. TruthArmor does not save the recording. You will see '
              'and can edit the text before anything is analyzed.',
              style: t.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
