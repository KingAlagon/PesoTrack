import 'package:flutter_test/flutter_test.dart';
import 'package:peso_track/main.dart';

void main() {
  testWidgets('PesoTrack app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PesoTrackApp());
    expect(find.text('PesoTrack'), findsAny);
  });
}
