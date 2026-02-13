import 'package:flutter_test/flutter_test.dart';
import 'package:northwestbank/main.dart';

void main() {
  testWidgets('App should render login screen', (WidgetTester tester) async {
    await tester.pumpWidget(const NorthwestBankApp());
    expect(find.text('NorthwestBank'), findsOneWidget);
    expect(find.text('Iniciar Sesion'), findsOneWidget);
  });
}
