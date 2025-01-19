import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/weather_service.dart';
import '../models/weather.dart';
import '../models/api_response.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService;
  final SharedPreferences prefs;

  ApiResponse<Weather> _currentWeather = ApiResponse();
  ApiResponse<List<Weather>> _forecast = ApiResponse();
  bool _isCelsius = true;
  List<String> _searchHistory = [];
  String? _currentLocation;
  final Map<String, Weather> _cityWeatherCache = {};
  List<Weather> _savedLocations = [];

  // Getters
  ApiResponse<Weather> get currentWeather => _currentWeather;
  ApiResponse<List<Weather>> get forecast => _forecast;
  bool get isCelsius => _isCelsius;
  List<String> get searchHistory => _searchHistory;
  String? get currentLocation => _currentLocation;
  List<Weather> get savedLocations => _savedLocations;
  Map<String, Weather> get allCachedWeather => Map.unmodifiable(_cityWeatherCache);

  WeatherProvider(this.prefs) : _weatherService = WeatherService() {
    _initializePreferences();
  }

  void _initializePreferences() {
    _isCelsius = prefs.getBool('isCelsius') ?? true;
    _searchHistory = prefs.getStringList('searchHistory') ?? [];
    _currentLocation = prefs.getString('currentLocation');
    _loadSavedLocations();
    _loadLastCity();
  }

  Future<void> _loadLastCity() async {
    final lastCity = prefs.getString('lastCity');
    if (lastCity != null) {
      await fetchWeather(lastCity);
    }
  }

  Future<void> _loadSavedLocations() async {
    final savedLocationsList = prefs.getStringList('savedLocations') ?? [];
    _savedLocations = [];
    for (var city in savedLocationsList) {
      try {
        final weather = await _weatherService.getCurrentWeather(city);
        _savedLocations.add(weather);
      } catch (e) {
        print('Error loading saved location $city: $e');
      }
    }
    notifyListeners();
  }

  Future<void> setCurrentLocation(String location) async {
    _currentLocation = location;
    await prefs.setString('currentLocation', location);
    await fetchWeather(location);
    notifyListeners();
  }

  Future<void> fetchWeather(String city) async {
    if (city.isEmpty) return;

    try {
      _currentWeather = ApiResponse.loading();
      _forecast = ApiResponse.loading();
      notifyListeners();

      final weather = await _weatherService.getCurrentWeather(city);
      _currentWeather = ApiResponse.success(weather);
      _cityWeatherCache[city] = weather;

      final forecastData = await _weatherService.getForecast(city);
      _forecast = ApiResponse.success(forecastData);

      await _updateSearchHistory(city);
      await prefs.setString('lastCity', city);
    } catch (e) {
      _handleError(e);
    } finally {
      notifyListeners();
    }
  }

  Weather? getWeatherForCity(String city) {
    if (_cityWeatherCache.containsKey(city)) {
      return _cityWeatherCache[city];
    }

    if (_currentWeather.hasData && _currentWeather.data!.cityName == city) {
      _cityWeatherCache[city] = _currentWeather.data!;
      return _currentWeather.data;
    }

    _fetchAndCacheWeatherForCity(city);
    return null;
  }

  Future<void> _fetchAndCacheWeatherForCity(String city) async {
    try {
      final weather = await _weatherService.getCurrentWeather(city);
      _cityWeatherCache[city] = weather;
      notifyListeners();
    } catch (e) {
      print('Error fetching weather for $city: $e');
    }
  }

  Future<void> _updateSearchHistory(String city) async {
    if (!_searchHistory.contains(city)) {
      _searchHistory.insert(0, city);
      if (_searchHistory.length > 6) {
        _searchHistory.removeLast();
      }
      await prefs.setStringList('searchHistory', _searchHistory);
      notifyListeners();
    }
  }

  void _handleError(dynamic error) {
    String errorMessage = 'An unexpected error occurred. Please try again.';
    if (error is WeatherServiceException) {
      switch (error.code) {
        case 'CITY_NOT_FOUND':
          errorMessage = 'City not found. Please check the spelling and try again.';
          break;
        case 'NETWORK_ERROR':
          errorMessage = 'Network error. Please check your connection and try again.';
          break;
        case 'API_ERROR':
          errorMessage = 'Weather service error. Please try again later.';
          break;
        case 'PARSE_ERROR':
          errorMessage = 'Unable to parse weather data. Please try again later.';
          break;
        default:
          errorMessage = 'An unexpected error occurred. Please try again.';
      }
    }
    _currentWeather = ApiResponse.error(errorMessage);
    _forecast = ApiResponse.error(errorMessage);
  }

  Future<void> addSavedLocation(Weather weather) async {
    if (!_savedLocations.any((element) => element.cityName == weather.cityName)) {
      _savedLocations.add(weather);
      await _saveSavedLocations();
      notifyListeners();
    }
  }

  Future<void> removeSavedLocation(String city) async {
    _savedLocations.removeWhere((element) => element.cityName == city);
    await _saveSavedLocations();
    notifyListeners();
  }

  Future<void> clearSavedLocations() async {
    _savedLocations.clear();
    await prefs.remove('savedLocations');
    notifyListeners();
  }

  Future<void> _saveSavedLocations() async {
    final locationsList = _savedLocations.map((w) => w.cityName).toList();
    await prefs.setStringList('savedLocations', locationsList);
  }

  Future<void> refreshSavedLocation(String city) async {
    final index = _savedLocations.indexWhere((element) => element.cityName == city);
    if (index != -1) {
      try {
        final weather = await _weatherService.getCurrentWeather(city);
        _savedLocations[index] = weather;
        await _saveSavedLocations();
        notifyListeners();
      } catch (e) {
        print('Error refreshing saved location $city: $e');
      }
    }
  }

  void clearWeatherCache() {
    _cityWeatherCache.clear();
    notifyListeners();
  }

  void removeFromWeatherCache(String city) {
    _cityWeatherCache.remove(city);
    notifyListeners();
  }

  Future<void> toggleUnit() async {
    _isCelsius = !_isCelsius;
    await prefs.setBool('isCelsius', _isCelsius);
    notifyListeners();
  }

  double convertTemperature(double temperature) {
    if (_isCelsius) {
      return temperature;
    } else {
      return (temperature * 9 / 5) + 32;
    }
  }

  String getTemperatureUnit() {
    return _isCelsius ? '°C' : '°F';
  }

  String getFormattedTemperature(double temperature) {
    final convertedTemp = convertTemperature(temperature);
    return '${convertedTemp.round()}${getTemperatureUnit()}';
  }

  Future<void> clearSearchHistory() async {
    _searchHistory.clear();
    await prefs.setStringList('searchHistory', _searchHistory);
    notifyListeners();
  }

  Future<void> removeFromSearchHistory(String city) async {
    _searchHistory.remove(city);
    await prefs.setStringList('searchHistory', _searchHistory);
    notifyListeners();
  }

  bool isInSearchHistory(String city) {
    return _searchHistory.contains(city);
  }

  String? getLastSearchedCity() {
    return _searchHistory.isNotEmpty ? _searchHistory.first : null;
  }

  Future<void> refreshWeather() async {
    if (_currentLocation != null) {
      await fetchWeather(_currentLocation!);
    } else {
      final lastCity = prefs.getString('lastCity');
      if (lastCity != null) {
        await fetchWeather(lastCity);
      }
    }
  }
}

extension TemperatureConversion on double {
  double toCelsius() {
    return (this - 32) * 5 / 9;
  }

  double toFahrenheit() {
    return (this * 9 / 5) + 32;
  }
}