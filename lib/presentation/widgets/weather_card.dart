
import 'package:flutter/material.dart';
import 'package:weather_forcasting/core/models/weather.dart';

class WeatherCard extends StatelessWidget {
  final Weather weather;
  final bool isCelsius;

  const WeatherCard({
    super.key,
    required this.weather,
    required this.isCelsius,
  });

  double get temperature {
    return isCelsius ? weather.temperature : (weather.temperature * 9/5) + 32;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              weather.cityName,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${temperature.round()}°${isCelsius ? 'C' : 'F'}',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    Text(
                      'Feels like: ${isCelsius ? weather.feelsLike.round() : (weather.feelsLike * 9/5 + 32).round()}°${isCelsius ? 'C' : 'F'}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                Image.network(
                  weather.iconUrl,
                  width: 64,
                  height: 64,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.cloud, size: 64);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              weather.description.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildWeatherDetails(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherDetails() {
    return Column(
      children: [
        _buildDetailRow(
          'Humidity',
          '${weather.humidity}%',
          Icons.water_drop_outlined,
        ),
        _buildDetailRow(
          'Wind',
          '${weather.windSpeed.toStringAsFixed(1)} m/s',
          Icons.air,
        ),
        _buildDetailRow(
          'Visibility',
          '${(weather.visibility / 1000).toStringAsFixed(1)} km',
          Icons.visibility,
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: const TextStyle(color: Colors.grey),
          ),
          Text(value),
        ],
      ),
    );
  }
}