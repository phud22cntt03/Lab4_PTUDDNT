import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_app/providers/weather_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _controller;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _search(String cityName) async {
    final query = cityName.trim();
    if (query.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a city name.')),
      );
      return;
    }

    setState(() => _submitting = true);
    await context.read<WeatherProvider>().fetchWeatherByCity(query);
    if (!mounted) {
      return;
    }
    setState(() => _submitting = false);

    final provider = context.read<WeatherProvider>();
    if (provider.state == WeatherState.loaded && provider.errorMessage.isEmpty) {
      Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<WeatherProvider>();
    final favorites = provider.favoriteCities;
    final recentSearches = provider.recentSearches;

    return Scaffold(
      appBar: AppBar(title: const Text('Search City')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onSubmitted: _search,
            decoration: InputDecoration(
              hintText: 'Enter city name',
              prefixIcon: const Icon(Icons.search_rounded),
              suffixIcon: _submitting
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  : IconButton(
                      onPressed: () => _search(_controller.text),
                      icon: const Icon(Icons.arrow_forward_rounded),
                    ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (provider.currentWeather != null)
            Card(
              child: ListTile(
                leading: const Icon(Icons.my_location_rounded),
                title: Text(provider.currentWeather!.cityName),
                subtitle: const Text('Tap the star to keep it in favorites'),
                trailing: IconButton(
                  icon: Icon(
                    provider.isFavorite(provider.currentWeather!.cityName)
                        ? Icons.star_rounded
                        : Icons.star_border_rounded,
                  ),
                  onPressed: () => provider.toggleFavoriteCity(
                    provider.currentWeather!.cityName,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          const _SectionTitle(title: 'Favorite Cities'),
          const SizedBox(height: 12),
          if (favorites.isEmpty)
            const Text('No favorites yet.')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: favorites
                  .map(
                    (city) => InputChip(
                      label: Text(city),
                      selected: true,
                      onPressed: () => _search(city),
                      onDeleted: () => provider.toggleFavoriteCity(city),
                    ),
                  )
                  .toList(),
            ),
          const SizedBox(height: 24),
          const _SectionTitle(title: 'Recent Searches'),
          const SizedBox(height: 12),
          if (recentSearches.isEmpty)
            const Text('No recent searches yet.')
          else
            ...recentSearches.map(
              (city) => Card(
                child: ListTile(
                  leading: const Icon(Icons.history_rounded),
                  title: Text(city),
                  trailing: IconButton(
                    onPressed: () => provider.toggleFavoriteCity(city),
                    icon: Icon(
                      provider.isFavorite(city)
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                    ),
                  ),
                  onTap: () => _search(city),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    );
  }
}
