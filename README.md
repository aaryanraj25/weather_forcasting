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
   git clone https://github.com/aaryanraj25/weather_forcasting.git
   cd weather_forcasting

2. Environment Setup
   ```bash
   Add API key: lib/config/secrets.dart

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