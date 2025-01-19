class Weather {
  final double temperature;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int pressure;
  final int humidity;
  final String description;
  final String icon;
  final DateTime dateTime;
  final double windSpeed;
  final int windDeg;
  final int visibility;
  final String cityName;

  Weather({
    required this.temperature,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
    required this.description,
    required this.icon,
    required this.dateTime,
    required this.windSpeed,
    required this.windDeg,
    required this.visibility,
    required this.cityName,
  });


  bool get isNight {
    final hour = dateTime.hour;
    return hour < 6 || hour > 18; 
  }

  String get condition {
    final lowercaseDesc = description.toLowerCase();
    
    // Check icon first (more reliable)
    if (icon.startsWith('01')) return 'clear';
    if (icon.startsWith('02')) return 'partly_cloudy';
    if (icon.startsWith('03') || icon.startsWith('04')) return 'cloudy';
    if (icon.startsWith('09') || icon.startsWith('10')) return 'rain';
    if (icon.startsWith('11')) return 'thunder';
    if (icon.startsWith('13')) return 'snow';
    if (icon.startsWith('50')) return 'hazy';

    if (lowercaseDesc.contains('rain') || 
        lowercaseDesc.contains('drizzle')) {
      return 'rain';
    }
    if (lowercaseDesc.contains('cloud')) {
      return 'cloudy';
    }
    if (lowercaseDesc.contains('clear')) {
      return 'clear';
    }
    if (lowercaseDesc.contains('snow') || 
        lowercaseDesc.contains('sleet')) {
      return 'snow';
    }
    if (lowercaseDesc.contains('thunder') || 
        lowercaseDesc.contains('storm')) {
      return 'thunder';
    }
    if (lowercaseDesc.contains('mist') || 
        lowercaseDesc.contains('haze') || 
        lowercaseDesc.contains('fog')) {
      return 'hazy';
    }
    
    return 'clear';
  }

  String get iconUrl => 'https://openweathermap.org/img/wn/$icon@2x.png';

  factory Weather.fromJson(Map<String, dynamic> json) {
    try {
      // Print raw JSON for debugging
      print('Raw JSON: $json');

      return Weather(
        temperature: (json['main']['temp'] ?? 0.0).toDouble(),
        feelsLike: (json['main']['feels_like'] ?? 0.0).toDouble(),
        tempMin: (json['main']['temp_min'] ?? 0.0).toDouble(),
        tempMax: (json['main']['temp_max'] ?? 0.0).toDouble(),
        pressure: json['main']['pressure'] ?? 0,
        humidity: json['main']['humidity'] ?? 0,
        description: json['weather'][0]['description'] ?? '',
        icon: json['weather'][0]['icon'] ?? '',
        dateTime: DateTime.fromMillisecondsSinceEpoch(
            (json['dt'] ?? 0) * 1000),
        windSpeed: (json['wind']['speed'] ?? 0.0).toDouble(),
        windDeg: json['wind']['deg'] ?? 0,
        visibility: json['visibility'] ?? 0,
        cityName: json['name'] ?? '',
      );
    } catch (e) {
      print('Error parsing weather: $e');
      rethrow;
    }
  }

  String get weatherDescription {
    return description.split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  String getFormattedTemp(bool isCelsius) {
    return '${temperature.round()}°${isCelsius ? 'C' : 'F'}';
  }

  String get formattedWindSpeed {
    return '${windSpeed.toStringAsFixed(1)} m/s';
  }

  String get formattedVisibility {
    final visibilityKm = visibility / 1000;
    return '${visibilityKm.toStringAsFixed(1)} km';
  }

  String get windDirection {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((windDeg + 22.5) % 360) ~/ 45;
    return directions[index];
  }
}