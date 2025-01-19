import 'dart:math';
import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final String? weatherCondition;
  final bool? isNight;

  const AnimatedBackground({
    Key? key,
    this.weatherCondition,
    this.isNight,
  }) : super(key: key);

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: _getBackgroundColors(),
            ),
          ),
        ),
        _buildWeatherOverlay(),
      ],
    );
  }

  List<Color> _getBackgroundColors() {
    if (widget.isNight ?? false) {
      return [
        const Color.fromARGB(255, 86, 88, 108),
        const Color.fromARGB(255, 43, 41, 41),
      ];
    }
    return [
      const Color.fromARGB(255, 86, 88, 108),
      const Color.fromARGB(255, 43, 41, 41),
    ];
  }

  Widget _buildWeatherOverlay() {
    switch (widget.weatherCondition?.toLowerCase() ?? 'default') {
      case 'clear':
        return widget.isNight ?? false
            ? _NightSkyOverlay()
            : _SunnyDayOverlay();
      case 'rain':
        return _RainOverlay(controller: _controller);
      case 'cloudy':
        return _CloudyOverlay(controller: _controller);
      case 'thunder':
        return _ThunderStormOverlay(controller: _controller);
      case 'snow':
        return _SnowOverlay(controller: _controller);
      case 'hazy':
        return _HazyOverlay(controller: _controller);
      default:
        return const SizedBox.shrink();
    }
  }
}

class _SunnyDayOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 50,
          right: 50,
          child: Icon(
            Icons.wb_sunny,
            size: 100,
            color: Colors.yellow.withOpacity(0.8),
          ),
        ),
      ],
    );
  }
}

class _NightSkyOverlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: StarsPainter(),
      child: const Positioned(
        top: 50,
        right: 50,
        child: Icon(
          Icons.nightlight_round,
          size: 80,
          color: Colors.white70,
        ),
      ),
    );
  }
}

class _RainOverlay extends StatelessWidget {
  final AnimationController controller;

  const _RainOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: RainPainter(
            animation: controller,
          ),
        );
      },
    );
  }
}

class _CloudyOverlay extends StatelessWidget {
  final AnimationController controller;

  const _CloudyOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Stack(
          children: List.generate(3, (index) {
            return Positioned(
              left: 50.0 + (index * 100) + (controller.value * 30),
              top: 50.0 + (index * 40),
              child: Icon(
                Icons.cloud,
                size: 100 - (index * 20),
                color: Colors.white.withOpacity(0.8),
              ),
            );
          }),
        );
      },
    );
  }
}

class _ThunderStormOverlay extends StatelessWidget {
  final AnimationController controller;

  const _ThunderStormOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        _CloudyOverlay(controller: controller),
        AnimatedBuilder(
          animation: controller,
          builder: (context, child) {
            return CustomPaint(
              painter: LightningPainter(
                animation: controller,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _SnowOverlay extends StatelessWidget {
  final AnimationController controller;

  const _SnowOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: SnowPainter(
            animation: controller,
          ),
        );
      },
    );
  }
}

class _HazyOverlay extends StatelessWidget {
  final AnimationController controller;

  const _HazyOverlay({required this.controller});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return CustomPaint(
          painter: HazePainter(
            animation: controller,
          ),
        );
      },
    );
  }
}

// Custom Painters
class RainPainter extends CustomPainter {
  final Animation<double> animation;

  RainPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;

    final random = Random();
    for (var i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y =
          (random.nextDouble() * size.height + animation.value * size.height) %
              size.height;
      canvas.drawLine(
        Offset(x, y),
        Offset(x - 5, y + 15),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(RainPainter oldDelegate) => true;
}

class SnowPainter extends CustomPainter {
  final Animation<double> animation;

  SnowPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..style = PaintingStyle.fill;

    final random = Random();
    for (var i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y =
          (random.nextDouble() * size.height + animation.value * size.height) %
              size.height;
      canvas.drawCircle(Offset(x, y), 2, paint);
    }
  }

  @override
  bool shouldRepaint(SnowPainter oldDelegate) => true;
}

class StarsPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final random = Random();
    for (var i = 0; i < 100; i++) {
      final x = random.nextDouble() * size.width;
      final y = random.nextDouble() * size.height;
      canvas.drawCircle(Offset(x, y), random.nextDouble() * 2, paint);
    }
  }

  @override
  bool shouldRepaint(StarsPainter oldDelegate) => false;
}

class LightningPainter extends CustomPainter {
  final Animation<double> animation;

  LightningPainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    if (animation.value > 0.8) {
      final paint = Paint()
        ..color = Colors.yellow.withOpacity(0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2;

      final path = Path();
      path.moveTo(size.width * 0.5, size.height * 0.2);
      path.lineTo(size.width * 0.45, size.height * 0.5);
      path.lineTo(size.width * 0.55, size.height * 0.5);
      path.lineTo(size.width * 0.5, size.height * 0.8);

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(LightningPainter oldDelegate) => true;
}

class HazePainter extends CustomPainter {
  final Animation<double> animation;

  HazePainter({required this.animation});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    for (var i = 0; i < 20; i++) {
      final y = (i * 20 + animation.value * 50) % size.height;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(HazePainter oldDelegate) => true;
}
