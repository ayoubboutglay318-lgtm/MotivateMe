import 'package:flutter_test/flutter_test.dart';
import 'package:motivate_me/main.dart';
import 'package:motivate_me/services/favorites_service.dart';
import 'package:motivate_me/services/streak_service.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(MotivateApp(
      favoritesService: FavoritesService(),
      streakService: StreakService(),
      showOnboarding: false,
    ));
    await tester.pump();
    expect(find.byType(MotivateApp), findsOneWidget);
  });
}
