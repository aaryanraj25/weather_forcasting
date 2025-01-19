import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_forcasting/core/providers/weather_provider.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_screen.dart';
import 'search_screen.dart';
import 'saved_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const SavedScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, _) {
        final isNight = weatherProvider.currentWeather.hasData
            ? weatherProvider.currentWeather.data!.isNight
            : false;

        return Scaffold(
          backgroundColor: Colors.transparent,
          body: Stack(
            children: [
              // Animated Background
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isNight
                        ? [
                            const Color.fromARGB(255, 86, 88, 108),
                            const Color.fromARGB(255, 43, 41, 41)
                          ]
                        : [
                            const Color(0xFF1A237E),
                            const Color.fromARGB(255, 255, 189, 151),
                          ],
                  ),
                ),
              ),

              // Screen Content
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _screens[_currentIndex],
              ),
            ],
          ),
          bottomNavigationBar: BottomNavBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
          ),
        );
      },
    );
  }
}
