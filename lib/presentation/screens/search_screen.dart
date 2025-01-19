import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/weather_provider.dart';
import '../widgets/animated_background.dart';
import '../widgets/weather_card.dart';
import '../widgets/loading_indicator.dart';
import '../widgets/error_widget.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late TextEditingController _searchController;
  final FocusNode _searchFocusNode = FocusNode();
  bool _showResults = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    _searchController = TextEditingController();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _handleSearch(WeatherProvider provider) {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      provider.fetchWeather(query);
      setState(() => _showResults = true);
      _searchFocusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WeatherProvider>(
      builder: (context, weatherProvider, child) {
        final isNight = weatherProvider.currentWeather.hasData
            ? weatherProvider.currentWeather.data!.isNight
            : null;
        return Scaffold(
          body: Stack(
            children: [
              AnimatedBackground(
                isNight: isNight,
              ),
              SafeArea(
                child: Column(
                  children: [
                    _buildSearchBar(weatherProvider),
                    Expanded(
                      child: _showResults
                          ? _buildSearchResults(weatherProvider)
                          : _buildRecentSearches(weatherProvider),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSearchBar(WeatherProvider weatherProvider) {
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Hero(
          tag: 'searchBar',
          child: Material(
            elevation: 8,
            borderRadius: BorderRadius.circular(30),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search city...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _showResults = false);
                        },
                      ),
                    IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: () => _handleSearch(weatherProvider),
                    ),
                  ],
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              onSubmitted: (_) => _handleSearch(weatherProvider),
              textInputAction: TextInputAction.search,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults(WeatherProvider weatherProvider) {
  if (weatherProvider.currentWeather.isLoading) {
    return const LoadingIndicator();
  }

  if (weatherProvider.currentWeather.hasError) {
    return WeatherErrorWidget(
      error: weatherProvider.currentWeather.errorMessage!,
      onRetry: () => _handleSearch(weatherProvider),
    );
  }

  if (!weatherProvider.currentWeather.hasData) {
    return const Center(
      child: Text('No results found'),
    );
  }

  return SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(
      children: [
        WeatherCard(
          weather: weatherProvider.currentWeather.data!,
          isCelsius: weatherProvider.isCelsius,
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: () {
            weatherProvider.setCurrentLocation(_searchController.text);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Location set as current location'),
              ),
            );
          },
          icon: const Icon(Icons.location_on),
          label: const Text('Set as current location'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
        ),
      ],
    ),
  );
}

  Widget _buildRecentSearches(WeatherProvider weatherProvider) {
    final recentSearches = weatherProvider.searchHistory;

    if (recentSearches.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search,
              size: 80,
              color: Colors.grey[600],
            ),
            const SizedBox(height: 16),
            Text(
              'Search for a city',
              style: TextStyle(
                fontSize: 20,
                color: Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Enter a city name to see the weather',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: recentSearches.length + 1,
      itemBuilder: (context, index) {
        if (index == 0) {
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recent Searches',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (recentSearches.isNotEmpty)
                  TextButton(
                    onPressed: () {
                      weatherProvider.clearSearchHistory();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Search history cleared'),
                        ),
                      );
                    },
                    child: const Text('Clear All',
                    style: TextStyle(
                    color: Colors.white
                  ),
                  ),
                  ),
              ],
            ),
          );
        }

        final city = recentSearches[index - 1];
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 400 + (index * 100)),
          builder: (context, value, child) {
            return Transform.scale(
              scale: value,
              child: Opacity(
                opacity: value,
                child: Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.history),
                    title: Text(city),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      _searchController.text = city;
                      _handleSearch(weatherProvider);
                    },
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class CitySearchDelegate extends SearchDelegate<String> {
  final WeatherProvider weatherProvider;

  CitySearchDelegate(this.weatherProvider);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Please enter a city name'),
      );
    }

    weatherProvider.fetchWeather(query);
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final suggestions = weatherProvider.searchHistory
        .where((city) => city.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final suggestion = suggestions[index];
        return ListTile(
          leading: const Icon(Icons.history),
          title: Text(suggestion),
          onTap: () {
            query = suggestion;
            showResults(context);
          },
        );
      },
    );
  }
}