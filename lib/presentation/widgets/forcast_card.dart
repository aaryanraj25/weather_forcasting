import 'package:flutter/material.dart';
import 'package:weather_forcasting/core/models/weather.dart';

class ForecastCard extends StatelessWidget {
  final Weather weather;
  final bool isCelsius;

  const ForecastCard({
    super.key,
    required this.weather,
    required this.isCelsius,
  });

  double get temperature {
    return isCelsius ? weather.temperature : (weather.temperature * 9/5) + 32;
  }

  String _getFormattedTime() {
    return '${weather.dateTime.hour}:00';
  }

  String _getFormattedDate() {
    return '${weather.dateTime.day}/${weather.dateTime.month}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _getFormattedTime(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              _getFormattedDate(),
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            Image.network(
              weather.iconUrl,
              width: 50,
              height: 50,
              errorBuilder: (context, error, stackTrace) {
                return const Icon(
                  Icons.cloud,
                  size: 50,
                  color: Colors.grey,
                );
              },
            ),
            const SizedBox(height: 8),
            Text(
              '${temperature.round()}°${isCelsius ? 'C' : 'F'}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              weather.description,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}