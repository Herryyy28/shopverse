import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shopverse/main.dart';

void main() {
  testWidgets('ShopVerse login screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ShopVerseApp());

    // Verify that the login screen title 'ShopVerse' is present.
    expect(find.text('ShopVerse'), findsAtLeast(1));
    
    // Verify that the welcome text is present.
    expect(find.text('Welcome back! Login to continue.'), findsOneWidget);
    
    // Verify that the login button is present.
    expect(find.widgetWithText(ElevatedButton, 'Login'), findsOneWidget);
  });
}
