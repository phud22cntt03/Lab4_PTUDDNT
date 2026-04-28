import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _SettingsTitle(title: 'Temperature Unit'),
          _SegmentedSection<TemperatureUnit>(
            value: settings.temperatureUnit,
            segments: const [
              ButtonSegment(
                value: TemperatureUnit.celsius,
                label: Text('Celsius (C)'),
              ),
              ButtonSegment(
                value: TemperatureUnit.fahrenheit,
                label: Text('Fahrenheit (F)'),
              ),
            ],
            onSelectionChanged: settings.setTemperatureUnit,
          ),
          const SizedBox(height: 20),
          const _SettingsTitle(title: 'Wind Speed Unit'),
          _SegmentedSection<WindSpeedUnit>(
            value: settings.windSpeedUnit,
            segments: const [
              ButtonSegment(
                value: WindSpeedUnit.ms,
                label: Text('m/s'),
              ),
              ButtonSegment(
                value: WindSpeedUnit.kmh,
                label: Text('km/h'),
              ),
              ButtonSegment(
                value: WindSpeedUnit.mph,
                label: Text('mph'),
              ),
            ],
            onSelectionChanged: settings.setWindSpeedUnit,
          ),
          const SizedBox(height: 20),
          const _SettingsTitle(title: 'Clock Format'),
          _SegmentedSection<ClockFormat>(
            value: settings.clockFormat,
            segments: const [
              ButtonSegment(
                value: ClockFormat.h24,
                label: Text('24-hour'),
              ),
              ButtonSegment(
                value: ClockFormat.h12,
                label: Text('12-hour'),
              ),
            ],
            onSelectionChanged: settings.setClockFormat,
          ),
        ],
      ),
    );
  }
}

class _SegmentedSection<T> extends StatelessWidget {
  const _SegmentedSection({
    required this.value,
    required this.segments,
    required this.onSelectionChanged,
  });

  final T value;
  final List<ButtonSegment<T>> segments;
  final ValueChanged<T> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<T>(
      segments: segments,
      selected: {value},
      showSelectedIcon: false,
      multiSelectionEnabled: false,
      onSelectionChanged: (values) => onSelectionChanged(values.first),
    );
  }
}

class _SettingsTitle extends StatelessWidget {
  const _SettingsTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }
}
