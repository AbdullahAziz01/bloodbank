// This is a basic Flutter widget test for BloodBank app.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:bloodbank/main.dart';

void main() {
  testWidgets('BloodBank app loads splash screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const BloodBankApp());

    // Verify that the splash screen loads with app title
    expect(find.text('BloodBank'), findsOneWidget);
    expect(find.text('Donate Blood, Save Lives'), findsOneWidget);

    // Pump enough time to let the Future.delayed timer complete (3 seconds)
    // This prevents the "Timer is still pending" error
    await tester.pump(const Duration(seconds: 3));
    await tester.pump(); // Pump one more frame to process the navigation
  });
}
