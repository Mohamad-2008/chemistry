import 'package:flutter_test/flutter_test.dart';
import 'package:periodic_table_app/main.dart';

void main() {
  testWidgets('Chemistry app boots successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.byType(MyApp), findsOneWidget);
  });
}
