// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:flutter_lms_rnd/main.dart';
import 'package:flutter_lms_rnd/repositories/auth_repository.dart';
import 'package:flutter_lms_rnd/repositories/user_repository.dart';
import 'package:flutter_lms_rnd/services/api_service.dart';
import 'package:flutter_lms_rnd/services/token_service.dart';
import 'package:flutter_lms_rnd/blocs/theme/theme_notifier.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Create mock repositories for testing
    final apiService = ApiService();
    final authRepo = AuthRepository(apiService);
    final userRepo = UserRepository(apiService, tokenService: TokenService());

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeNotifier(),
        child: MyApp(authRepository: authRepo, userRepository: userRepo),
      ),
    );

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    // Tap the '+' icon and trigger a frame.
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    // Verify that our counter has incremented.
    expect(find.text('0'), findsNothing);
    expect(find.text('1'), findsOneWidget);
  });
}
