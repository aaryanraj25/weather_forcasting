# Weather App

## Overview
Flutter-based weather application with real-time updates and location management.

## Tech Stack & Features
1. Features:

- Real-time weather data
- Location-based weather
- City search functionality
- Save favorite locations
- 5-day weather forecast
- Temperature unit toggle (°C/°F)
- Dynamic themes
- Search history
- Pull-to-refresh

2. Tech Stack:

- Flutter
- Dart
- Provider (State Management)
- OpenWeatherMap API
- SharedPreferences
- HTTP package

## Project Setup
1. Clone repository
   ```bash
   git clone https://github.com/yourusername/weather_app.git
   cd weather_app

2. Environment Setup
   2.1 Create lib/config/secrets.dart
   2.2 Add API key:
    const String WEATHER_API_KEY = 'your_api_key_here';

2. Install dependencies
   flutter pub get

2. Run app
   flutter run

## Build Commands
1. Android:
   ```bash
   flutter build apk 
   
2. iOS:
   ```bash
   cd ios
   pod install
   flutter build ios