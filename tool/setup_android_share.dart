// Turns on "Share → TruthArmor" in the Android app.
//
// Run from the project folder:   dart run tool/setup_android_share.dart
//
// It copies docs/android/AndroidManifest.xml into the Android project and
// updates MainActivity.kt (keeping your package line). Your old files are
// saved in android/backup_before_share/ first. Safe to run more than once.
import 'dart:io';

void main() {
  const manifestPath = 'android/app/src/main/AndroidManifest.xml';
  const kotlinRoot = 'android/app/src/main/kotlin';
  const manifestSource = 'docs/android/AndroidManifest.xml';
  const activitySource = 'docs/android/MainActivity.kt';

  if (!File(manifestPath).existsSync() || !File(manifestSource).existsSync()) {
    _fail('Run this from the trutharmorapp folder (the one with pubspec.yaml), after "git pull".');
  }

  final activities = Directory(kotlinRoot).existsSync()
      ? Directory(kotlinRoot)
          .listSync(recursive: true)
          .whereType<File>()
          .where((f) => f.path.replaceAll('\\', '/').endsWith('/MainActivity.kt'))
          .toList()
      : <File>[];
  if (activities.length != 1) {
    _fail('Could not find exactly one MainActivity.kt under $kotlinRoot (found ${activities.length}).');
  }
  final activity = activities.single;

  final oldActivity = activity.readAsStringSync();
  final packageLine = oldActivity.split('\n').map((l) => l.trim()).firstWhere(
        (l) => l.startsWith('package '),
        orElse: () => '',
      );
  if (packageLine.isEmpty) _fail('MainActivity.kt has no "package" line.');

  // Back up the originals (only the first time, so the real originals are kept).
  final backup = Directory('android/backup_before_share')..createSync(recursive: true);
  final manifestBackup = File('${backup.path}/AndroidManifest.xml');
  final activityBackup = File('${backup.path}/MainActivity.kt');
  if (!manifestBackup.existsSync()) File(manifestPath).copySync(manifestBackup.path);
  if (!activityBackup.existsSync()) activity.copySync(activityBackup.path);

  // New MainActivity: your package line + the code from docs (minus its comment header).
  final code = File(activitySource).readAsStringSync();
  final start = code.indexOf('import android.content.Intent');
  if (start < 0) _fail('docs/android/MainActivity.kt looks wrong. Run "git pull" again.');
  activity.writeAsStringSync('$packageLine\n\n${code.substring(start)}');

  File(manifestSource).copySync(manifestPath);

  stdout.writeln('Done! "Share to TruthArmor" is set up.');
  stdout.writeln('  Updated: $manifestPath');
  stdout.writeln('  Updated: ${activity.path}');
  stdout.writeln('  Backups: ${backup.path}');
  stdout.writeln('Now build the APK.');
}

Never _fail(String message) {
  stderr.writeln('Setup stopped: $message');
  exit(1);
}
