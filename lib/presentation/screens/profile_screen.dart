import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/providers/theme_providers.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    const CircleAvatar(
                      radius: 50,
                      backgroundImage: AssetImage('assets/images/profile_placeholder.png'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Weather App User',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            ...List.generate(
              _getSettingsList(context).length,
              (index) => TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 400 + (index * 100)),
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(
                      opacity: value,
                      child: _getSettingsList(context)[index],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getSettingsList(BuildContext context) {
    return [
      _buildSettingTile(
        icon: Icons.dark_mode,
        title: 'Dark Mode',
        trailing: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Switch(
              value: themeProvider.isDarkMode,
              onChanged: (value) => themeProvider.toggleTheme(),
            );
          },
        ),
      ),
      _buildSettingTile(
        icon: Icons.notifications,
        title: 'Notifications',
        trailing: Switch(
          value: true,
          onChanged: (value) {},
        ),
      ),
      _buildSettingTile(
        icon: Icons.language,
        title: 'Language',
        trailing: const Text('English'),
        onTap: () {},
      ),
      _buildSettingTile(
        icon: Icons.info,
        title: 'About',
        onTap: () {},
      ),
      _buildSettingTile(
        icon: Icons.logout,
        title: 'Logout',
        onTap: () {},
      ),
    ];
  }

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}