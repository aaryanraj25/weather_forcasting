import 'package:flutter/material.dart';
import 'package:weather_forcasting/presentation/widgets/forcast_card.dart';
import '../../core/models/weather.dart';

class ForecastList extends StatelessWidget {
  final List<Weather> forecast;
  final bool isCelsius;

  const ForecastList({
    super.key,
    required this.forecast,
    required this.isCelsius,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: forecast.length,
        itemBuilder: (context, index) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 500 + (index * 100)),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Opacity(
                  opacity: value,
                  child: ForecastCard(
                    weather: forecast[index],
                    isCelsius: isCelsius,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}