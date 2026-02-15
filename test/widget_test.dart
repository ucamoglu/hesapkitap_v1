import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:hesapkitap_v1/screens/onboarding_welcome_screen.dart';

void main() {
  testWidgets('Onboarding welcome screen renders base content', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: OnboardingWelcomeScreen(
          onCompleted: () async {},
        ),
      ),
    );

    expect(find.text('Aramıza Hoş Geldiniz'), findsOneWidget);
    expect(find.text('Devam Et'), findsOneWidget);
  });
}
