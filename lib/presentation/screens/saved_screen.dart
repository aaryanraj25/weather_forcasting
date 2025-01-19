// lib/presentation/screens/saved_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/weather_provider.dart';
import '../widgets/animated_background.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> with TickerProviderStateMixin {
  late AnimationController _listController;
  late AnimationController _emptyStateController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _emptyStateController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _listController.forward();
    _emptyStateController.forward();
  }

  @override
  void dispose() {
    _listController.dispose();
    _emptyStateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        final isNight = weatherProvider.currentWeather.hasData
            ? weatherProvider.currentWeather.data!.isNight
            : null;
        return Scaffold(
          appBar: AppBar(
            backgroundColor: const Color.fromARGB(255, 86, 88, 108),
            title: const Text('Search History'),
            actions: [
              if (weatherProvider.searchHistory.isNotEmpty)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _showClearHistoryDialog(context, weatherProvider),
                ),
            ],
          ),
          body: Stack(
            children: [
              AnimatedBackground(
                isNight: isNight,
              ),
              weatherProvider.searchHistory.isEmpty
                  ? _buildEmptyState()
                  : _buildSearchHistoryList(weatherProvider),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return ScaleTransition(
      scale: CurvedAnimation(
        parent: _emptyStateController,
        curve: Curves.easeOut,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'No search history yet',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your recent searches will appear here',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchHistoryList(WeatherProvider weatherProvider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: weatherProvider.searchHistory.length,
      itemBuilder: (context, index) {
        final city = weatherProvider.searchHistory[index];
        final weather = weatherProvider.getWeatherForCity(city);

        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: _listController,
            curve: Interval(
              index * 0.1,
              0.1 + index * 0.1,
              curve: Curves.easeOut,
            ),
          )),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Card(
              elevation: 2,
              color: Colors.black87,
              child: Dismissible(
                key: Key(city),
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  color: Colors.red,
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  weatherProvider.removeFromSearchHistory(city);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('$city removed from history'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          weatherProvider.fetchWeather(city);
                        },
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            city,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (weather != null) ...[
                            Text(
                              '${weather.temperature.round()}°C',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (weather != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          weather.description.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildWeatherInfo(
                              Icons.water_drop_outlined,
                              'Humidity: ${weather.humidity}%',
                            ),
                            _buildWeatherInfo(
                              Icons.air,
                              'Wind: ${weather.windSpeed.toStringAsFixed(1)} m/s',
                            ),
                            _buildWeatherInfo(
                              Icons.visibility_outlined,
                              'Visibility: ${(weather.visibility / 1000).toStringAsFixed(1)} km',
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeatherInfo(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.white70,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Future<void> _showClearHistoryDialog(
    BuildContext context,
    WeatherProvider weatherProvider,
  ) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Clear Search History'),
          content: const Text(
            'Are you sure you want to clear all search history?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                weatherProvider.clearSearchHistory();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Search history cleared'),
                  ),
                );
              },
              child: const Text(
                'Clear',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}