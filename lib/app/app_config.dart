import '../services/ai/analysis_service.dart';
import '../services/ai/backend_analysis_service.dart';
import '../services/ai/demo_analysis_service.dart';

/// Build-time configuration. NO SECRETS LIVE HERE.
///
/// The only setting is the PUBLIC URL of the secure backend function:
///
///   flutter run --dart-define=TA_BACKEND_URL=https://<region>-<project>.cloudfunctions.net/analyze
///
/// Without it, TruthArmor runs in DEMO MODE (offline mock AI, clearly labeled).
class AppConfig {
  AppConfig._();

  static const String backendUrl = String.fromEnvironment('TA_BACKEND_URL');

  static bool get isDemoMode => backendUrl.isEmpty;

  static AnalysisService createAnalysisService() {
    if (isDemoMode) return const DemoAnalysisService();
    return BackendAnalysisService(endpoint: Uri.parse(backendUrl));
  }
}
