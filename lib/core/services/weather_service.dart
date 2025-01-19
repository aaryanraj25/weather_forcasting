import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:weather_forcasting/config/secrets.dart';
import '../models/weather.dart';

class WeatherServiceException implements Exception {
  final String code;
  final String message;

  WeatherServiceException(this.code, this.message);
}

class WeatherService {
  static const String apiKey = '${WEATHER_API_KEY}';
  static const String baseUrl = 'https://api.openweathermap.org/data/2.5';

  Future<Weather> getCurrentWeather(String city) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/weather?q=$city&appid=$apiKey&units=metric'),
      ).timeout(
        const Duration(seconds: 20),  // Increased timeout to 20 seconds
        onTimeout: () => throw WeatherServiceException(
          'NETWORK_ERROR',
          'Connection timed out',
        ),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');  // Log the response for debugging

      if (response.statusCode == 200) {
        try {
          final decodedData = json.decode(response.body);
          return Weather.fromJson(decodedData);
        } catch (e) {
          throw WeatherServiceException('PARSE_ERROR', 'Failed to parse weather data');
        }
      } else if (response.statusCode == 404) {
        throw WeatherServiceException('CITY_NOT_FOUND', 'City not found');
      } else {
        throw WeatherServiceException('API_ERROR', 'Failed to load weather data');
      }
    } catch (e) {
      if (e is WeatherServiceException) {
        rethrow;
      }
      throw WeatherServiceException('NETWORK_ERROR', 'Network error occurred');
    }
  }

  Future<List<Weather>> getForecast(String city) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/forecast?q=$city&appid=$apiKey&units=metric'),
      ).timeout(
        const Duration(seconds: 20),  // Increased timeout to 20 seconds
        onTimeout: () => throw WeatherServiceException(
          'NETWORK_ERROR',
          'Connection timed out',
        ),
      );

      print('Response Status: ${response.statusCode}');
      print('Response Body: ${response.body}');  // Log the response for debugging

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return (data['list'] as List)
            .map((item) => Weather.fromJson(item))
            .toList();
      } else if (response.statusCode == 404) {
        throw WeatherServiceException('CITY_NOT_FOUND', 'City not found');
      } else {
        throw WeatherServiceException('API_ERROR', 'Failed to load forecast data');
      }
    } catch (e) {
      if (e is WeatherServiceException) {
        rethrow;
      }
      throw WeatherServiceException('NETWORK_ERROR', 'Network error occurred');
    }
  }
}
