import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:weather_app/providers/location_provider.dart';
import 'package:weather_app/providers/settings_provider.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'package:weather_app/screens/home_screen.dart';
import 'package:weather_app/services/connectivity_service.dart';
import 'package:weather_app/services/location_service.dart';
import 'package:weather_app/services/storage_service.dart';
import 'package:weather_app/services/weather_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  final storageService = StorageService();
  final settingsProvider = SettingsProvider(storageService);
  await settingsProvider.loadSettings();

  runApp(
    WeatherApp(
      storageService: storageService,
      settingsProvider: settingsProvider,
    ),
  );
}

class WeatherApp extends StatelessWidget {
  const WeatherApp({
    super.key,
    required this.storageService,
    required this.settingsProvider,
  });

  final StorageService storageService;
  final SettingsProvider settingsProvider;

  @override
  Widget build(BuildContext context) {
    final weatherService = WeatherService(httpClient: http.Client());
    final locationService = LocationService();
    final connectivityService = ConnectivityService();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsProvider>.value(value: settingsProvider),
        ChangeNotifierProvider<LocationProvider>(
          create: (_) => LocationProvider(locationService),
        ),
        ChangeNotifierProvider<WeatherProvider>(
          create: (_) => WeatherProvider(
            weatherService,
            locationService,
            storageService,
            connectivityService,
          ),
        ),
      ],
      child: Consumer<SettingsProvider>(
        builder: (context, settings, child) {
          return MaterialApp(
            title: 'Weather App',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorSchemeSeed: Colors.orange,
              useMaterial3: true,
              scaffoldBackgroundColor: Colors.transparent,
              cardTheme: CardThemeData(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
            home: const HomeScreen(),
          );
        },
      ),
    );
  }
}
