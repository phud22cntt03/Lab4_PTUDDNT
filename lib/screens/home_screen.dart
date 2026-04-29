import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/providers/location_provider.dart';
import 'package:weather_app/providers/settings_provider.dart';
import 'package:weather_app/providers/weather_provider.dart';
import 'package:weather_app/screens/forecast_screen.dart';
import 'package:weather_app/screens/search_screen.dart';
import 'package:weather_app/screens/settings_screen.dart';
import 'package:weather_app/utils/constants.dart';
import 'package:weather_app/utils/date_formatter.dart';
import 'package:weather_app/utils/weather_theme.dart';
import 'package:weather_app/widgets/current_weather_card.dart';
import 'package:weather_app/widgets/daily_forecast_card.dart';
import 'package:weather_app/widgets/error_widget.dart';
import 'package:weather_app/widgets/hourly_forecast_list.dart';
import 'package:weather_app/widgets/loading_shimmer.dart';
import 'package:weather_app/widgets/weather_detail_item.dart';
import 'package:weather_app/widgets/weather_backdrop.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LocationProvider>().refreshStatus();
      context.read<WeatherProvider>().initializeWeather();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        final weather = weatherProvider.currentWeather;
        final palette = WeatherPalette.fromWeather(weather);

        return WeatherBackdrop(
          palette: palette,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () =>
                    context.read<WeatherProvider>().refreshWeather(),
                child: _buildBody(context, weatherProvider, weather),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBody(
    BuildContext context,
    WeatherProvider weatherProvider,
    WeatherModel? weather,
  ) {
    if (weatherProvider.state == WeatherState.loading && weather == null) {
      return const LoadingShimmer();
    }

    if (weatherProvider.state == WeatherState.error && weather == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.screenPadding),
        children: [
          _Header(
            onSearchTap: _openSearch,
            onForecastTap: _openForecast,
            onSettingsTap: _openSettings,
          ),
          const SizedBox(height: AppConstants.sectionSpacing),
          Consumer<LocationProvider>(
            builder: (context, locationProvider, child) {
              return WeatherErrorState(
                message: weatherProvider.errorMessage,
                onRetry: () =>
                    context.read<WeatherProvider>().fetchWeatherByLocation(),
                secondaryActionLabel: _secondaryLabel(locationProvider),
                onSecondaryAction: () =>
                    _handleLocationAction(context, locationProvider),
              );
            },
          ),
        ],
      );
    }

    if (weather == null) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [
          SizedBox(height: 180),
          Center(
            child: Text(
              'No weather data available.',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
        ],
      );
    }

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(AppConstants.screenPadding),
      children: [
        _Header(
          onSearchTap: _openSearch,
          onForecastTap: _openForecast,
          onSettingsTap: _openSettings,
        ),
        const SizedBox(height: AppConstants.sectionSpacing),
        CurrentWeatherCard(weather: weather),
        const SizedBox(height: 16),
        if (weatherProvider.isShowingCachedData ||
            weatherProvider.errorMessage.isNotEmpty)
          _StatusBanner(
            message: weatherProvider.errorMessage.isNotEmpty
                ? weatherProvider.errorMessage
                : 'Showing cached data from ${DateFormatter.lastUpdated(weatherProvider.lastUpdated)}.',
          ),
        const SizedBox(height: AppConstants.sectionSpacing),
        HourlyForecastList(forecasts: weatherProvider.hourlyForecast),
        const SizedBox(height: AppConstants.sectionSpacing),
        _SectionCard(
          title: '5-Day Forecast',
          trailingLabel: 'Open full view',
          onTrailingTap: () => _openForecast(context),
          child: Column(
            children: weatherProvider.dailyForecast
                .map(
                  (forecast) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DailyForecastCard(forecast: forecast),
                  ),
                )
                .toList(),
          ),
        ),
        const SizedBox(height: AppConstants.sectionSpacing),
        _SectionCard(
          title: 'Details',
          child: _DetailsGrid(weather: weather),
        ),
      ],
    );
  }

  String? _secondaryLabel(LocationProvider provider) {
    switch (provider.status) {
      case LocationStatus.denied:
        return 'Grant Permission';
      case LocationStatus.deniedForever:
        return 'Open Settings';
      case LocationStatus.serviceDisabled:
        return 'Enable Location';
      default:
        return 'Search City';
    }
  }

  Future<void> _handleLocationAction(
    BuildContext context,
    LocationProvider provider,
  ) async {
    switch (provider.status) {
      case LocationStatus.denied:
        await provider.requestAccess();
        if (context.mounted) {
          await context.read<WeatherProvider>().fetchWeatherByLocation();
        }
        break;
      case LocationStatus.deniedForever:
        await provider.openAppSettings();
        break;
      case LocationStatus.serviceDisabled:
        await provider.openLocationSettings();
        break;
      default:
        if (context.mounted) {
          _openSearch(context);
        }
    }
  }

  void _openSearch(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SearchScreen()),
    );
  }

  void _openForecast(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ForecastScreen()),
    );
  }

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.onSearchTap,
    required this.onForecastTap,
    required this.onSettingsTap,
  });

  final void Function(BuildContext context) onSearchTap;
  final void Function(BuildContext context) onForecastTap;
  final void Function(BuildContext context) onSettingsTap;

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>().currentWeather;
    final colors = Theme.of(context).colorScheme;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Weather App',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                weather == null
                    ? 'Real-time updates, search, and offline cache'
                    : 'Updated ${DateFormatter.lastUpdated(context.watch<WeatherProvider>().lastUpdated)}',
                style: TextStyle(
                  color: colors.onSurface.withValues(alpha: 0.76),
                ),
              ),
            ],
          ),
        ),
        _HeaderButton(
          icon: Icons.search_rounded,
          onTap: () => onSearchTap(context),
        ),
        const SizedBox(width: 8),
        _HeaderButton(
          icon: Icons.calendar_view_week_rounded,
          onTap: () => onForecastTap(context),
        ),
        const SizedBox(width: 8),
        _HeaderButton(
          icon: Icons.tune_rounded,
          onTap: () => onSettingsTap(context),
        ),
      ],
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: colors.onSurface),
        ),
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colors.outline.withValues(alpha: 0.72)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: colors.onSurface),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: colors.onSurface),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.trailingLabel,
    this.onTrailingTap,
  });

  final String title;
  final Widget child;
  final String? trailingLabel;
  final VoidCallback? onTrailingTap;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(color: colors.outline.withValues(alpha: 0.72)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: colors.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (trailingLabel != null && onTrailingTap != null)
                TextButton(
                  onPressed: onTrailingTap,
                  child: Text(
                    trailingLabel!,
                    style: TextStyle(color: colors.onSurface),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

class _DetailsGrid extends StatelessWidget {
  const _DetailsGrid({required this.weather});

  final WeatherModel weather;

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final items = <WeatherDetailItem>[
      WeatherDetailItem(
        icon: Icons.water_drop_rounded,
        label: 'Humidity',
        value: '${weather.humidity}%',
      ),
      WeatherDetailItem(
        icon: Icons.air_rounded,
        label: 'Wind',
        value:
            '${settings.displayWindSpeed(weather.windSpeed).toStringAsFixed(1)} ${settings.windSpeedUnitLabel()}',
      ),
      WeatherDetailItem(
        icon: Icons.compress_rounded,
        label: 'Pressure',
        value: '${weather.pressure} hPa',
      ),
      WeatherDetailItem(
        icon: Icons.visibility_rounded,
        label: 'Visibility',
        value: weather.visibility == null
            ? '--'
            : '${(weather.visibility! / 1000).toStringAsFixed(1)} km',
      ),
      WeatherDetailItem(
        icon: Icons.cloud_rounded,
        label: 'Cloudiness',
        value: weather.cloudiness == null ? '--' : '${weather.cloudiness}%',
      ),
      WeatherDetailItem(
        icon: Icons.explore_rounded,
        label: 'Wind Dir.',
        value: weather.windDegree == null ? '--' : '${weather.windDegree} deg',
      ),
    ];

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: items
          .map(
            (item) => SizedBox(
              width: (MediaQuery.of(context).size.width -
                      (AppConstants.screenPadding * 2) -
                      48) /
                  2,
              child: item,
            ),
          )
          .toList(),
    );
  }
}
