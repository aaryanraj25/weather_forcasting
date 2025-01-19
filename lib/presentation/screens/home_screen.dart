import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weather_forcasting/presentation/widgets/forcast_list.dart';
import '../../core/providers/weather_provider.dart';
import '../widgets/weather_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_widget.dart';
import '../widgets/empty_state.dart';
import '../widgets/animated_background.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late TextEditingController _locationController;
  bool _isRefreshing = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _locationController = TextEditingController(
      text: context.read<WeatherProvider>().currentLocation,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _locationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _handleRefresh(WeatherProvider provider) async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);

    try {
      await provider.refreshWeather();
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        final weatherCondition = weatherProvider.currentWeather.hasData
            ? weatherProvider.currentWeather.data!.condition
            : null;
        final isNight = weatherProvider.currentWeather.hasData
            ? weatherProvider.currentWeather.data!.isNight
            : null;

        return Scaffold(
          body: Stack(
            children: [
              AnimatedBackground(
                weatherCondition: weatherCondition,
                isNight: isNight,
              ),
              SafeArea(
                bottom: false, 
                child: RefreshIndicator(
                  onRefresh: () => _handleRefresh(weatherProvider),
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      _buildAppBar(context, weatherProvider),
                      SliverPadding(
                        padding: EdgeInsets.only(
                          left: 16.0,
                          right: 16.0,
                          top: 16.0,
                          bottom: MediaQuery.of(context).padding.bottom +
                              32.0, 
                        ),
                        sliver: SliverList(
                          delegate: SliverChildListDelegate([
                            _buildLocationInput(weatherProvider),
                            const SizedBox(height: 16),
                            _buildWeatherContent(weatherProvider),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLocationInput(WeatherProvider weatherProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        child: TextField(
          controller: _locationController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: 'Enter your location',
            hintStyle: TextStyle(color: Colors.grey[600]),
            border: InputBorder.none,
            icon: const Icon(Icons.location_on, color: Colors.deepPurple),
            suffixIcon: IconButton(
              icon: const Icon(Icons.search, color: Colors.deepPurple),
              onPressed: () {
                if (_locationController.text.isNotEmpty) {
                  weatherProvider.setCurrentLocation(_locationController.text);
                  FocusScope.of(context).unfocus();
                }
              },
            ),
          ),
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              weatherProvider.setCurrentLocation(value);
            }
          },
        ),
      ),
    );
  }

  Widget _buildWeatherContent(WeatherProvider weatherProvider) {
    if (weatherProvider.currentWeather.isLoading) {
      return const Center(child: LoadingIndicator());
    }

    if (weatherProvider.currentWeather.hasError) {
      return WeatherErrorWidget(
        error: weatherProvider.currentWeather.errorMessage!,
        onRetry: () => _handleRefresh(weatherProvider),
      );
    }

    if (!weatherProvider.currentWeather.hasData) {
      return const EmptyStateWidget();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        WeatherCard(
          weather: weatherProvider.currentWeather.data!,
          isCelsius: weatherProvider.isCelsius,
        ),
        const SizedBox(height: 24),
        if (weatherProvider.forecast.hasData) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Forecast',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        offset: Offset(1, 1),
                        blurRadius: 2,
                        color: Colors.black26,
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: IconButton(
                    icon: Icon(
                      weatherProvider.isCelsius
                          ? Icons.thermostat
                          : Icons.thermostat_auto,
                      color: Colors.white,
                    ),
                    onPressed: weatherProvider.toggleUnit,
                    tooltip: 'Toggle temperature unit',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: ForecastList(
              forecast: weatherProvider.forecast.data!,
              isCelsius: weatherProvider.isCelsius,
            ),
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  SliverAppBar _buildAppBar(
    BuildContext context,
    WeatherProvider weatherProvider,
  ) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      pinned: true,
      backgroundColor: Colors.transparent, 
      elevation: 0, 
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true, 
        title: Text(
          weatherProvider.currentLocation ?? 'Weather App',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _isRefreshing
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.white),
          ),
          onPressed:
              _isRefreshing ? null : () => _handleRefresh(weatherProvider),
        ),
        const SizedBox(width: 8), 
      ],
    );
  }
}
