import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/app.dart';
import 'package:memo_care/features/settings/application/settings_providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('App renders', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const MemoCareApp(),
      ),
    );
    await tester.pumpAndSettle();
    // The app should render the welcome onboarding page.
    expect(find.textContaining('Get Started'), findsOneWidget);
  });
}
