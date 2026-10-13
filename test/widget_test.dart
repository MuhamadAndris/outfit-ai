import 'package:flutter_test/flutter_test.dart';
import 'package:outfit_ai/main.dart';

void main() {
  testWidgets('Beranda tampil', (tester) async {
    await tester.pumpWidget(const OutfitApp());
    expect(find.text('Mau tampil untuk apa?'), findsOneWidget);
  });
}
