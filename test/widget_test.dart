import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/providers/settings_provider.dart';
import 'package:weather_app/screens/settings_screen.dart';
import 'package:weather_app/services/storage_service.dart';

void main() {
  testWidgets('Settings screen renders sections', (WidgetTester tester) async {
    final provider = SettingsProvider(StorageService());

    await tester.pumpWidget(
      ChangeNotifierProvider<SettingsProvider>.value(
        value: provider,
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    expect(find.text('Temperature Unit'), findsOneWidget);
    expect(find.text('Wind Speed Unit'), findsOneWidget);
    expect(find.text('Clock Format'), findsOneWidget);
  });
}
