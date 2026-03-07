import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:memo_care/app.dart';

void main() {
  testWidgets('App renders', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: MemoCareApp()),
    );
    // The app should render the first onboarding step.
    expect(find.textContaining('Step 1'), findsOneWidget);
  });
}
