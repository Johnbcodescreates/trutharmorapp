import 'package:flutter_test/flutter_test.dart';
import 'package:truth_armor/services/share/share_receiver.dart';

void main() {
  test('Shared text is read from the Android message', () {
    final item = SharedItem.fromMap({'text': 'Your package is on hold: http://bit.ly/x'});
    expect(item, isNotNull);
    expect(item!.text, contains('package'));
    expect(item.imagePath, isNull);
  });

  test('Shared screenshot path is read', () {
    final item = SharedItem.fromMap({'imagePath': '/data/cache/shared/shared_1.jpg'});
    expect(item!.imagePath, endsWith('.jpg'));
  });

  test('Empty or unknown shares are ignored', () {
    expect(SharedItem.fromMap(null), isNull);
    expect(SharedItem.fromMap({'text': '   '}), isNull);
    expect(SharedItem.fromMap('nonsense'), isNull);
  });
}
