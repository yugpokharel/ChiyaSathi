import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chiya_sathi/features/auth/presentation/view_model/auth_view_model_provider.dart';
import 'package:chiya_sathi/features/menu/presentation/providers/order_provider.dart';
import 'package:chiya_sathi/features/dashboard/presentation/pages/bottom/home_screen.dart';
import 'package:chiya_sathi/features/dashboard/presentation/pages/bottom/menu_screen.dart';
import 'package:chiya_sathi/features/dashboard/presentation/pages/bottom/activity_screen.dart';
import 'package:chiya_sathi/features/dashboard/presentation/pages/bottom/profile_screen.dart';
import 'package:chiya_sathi/core/constants/api_constants.dart';
import 'dart:io';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;
  bool _initialTabApplied = false;

  final List<Widget> _lstBottomScreen = [
    const HomeScreen(),
    const MenuScreen(),
    const ActivityScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Accept optional initial tab from route arguments
    if (!_initialTabApplied) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic> && args.containsKey('tab')) {
        _selectedIndex = args['tab'] as int;
      }
      _initialTabApplied = true;
    }

    final authState = ref.watch(authViewModelProvider);
    final profilePicture = authState.user?.profilePicture;
    final order = ref.watch(orderProvider);

    return PopScope(
      canPop: false,
      child: Scaffold(
      extendBodyBehindAppBar: false,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        elevation: 0,
        titleSpacing: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12.0),
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedIndex = 3; // Navigate to Profile
              });
            },
            child: CircleAvatar(
              radius: 20,
              backgroundColor: Colors.orange,
              child: CircleAvatar(
                radius: 18,
                backgroundImage:
                    profilePicture != null && profilePicture.isNotEmpty
                        ? _getProfileImage(profilePicture)
                        : null,
                child: profilePicture == null || profilePicture.isEmpty
                    ? Icon(
                        Icons.person,
                        size: 20,
                        color: Colors.grey.shade400,
                      )
                    : null,
              ),
            ),
          ),
        ),
        title: const Text(''),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, color: Theme.of(context).iconTheme.color),
            onPressed: () {
              // Notification action — can be expanded later
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No new notifications'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
            tooltip: 'Notifications',
          ),
          IconButton(
            icon: Icon(
              Icons.check_circle_outline,
              color: order.hasActiveOrder
                  ? Colors.green
                  : Colors.grey.shade400,
            ),
            onPressed: () {
              if (order.hasActiveOrder) {
                Navigator.pushNamed(context, '/order_status');
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('No active orders'),
                    duration: Duration(seconds: 1),
                  ),
                );
              }
            },
            tooltip: 'View Your Order',
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: _lstBottomScreen[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.orange,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Menu',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Activity',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    ),
    );
  }

  ImageProvider _getProfileImage(String imagePath) {
    if (imagePath.startsWith('http') || imagePath.startsWith('/uploads')) {
      final url = imagePath.startsWith('http')
          ? imagePath
          : '${ApiConstants.serverUrl}$imagePath';
      return NetworkImage(url);
    } else if (File(imagePath).existsSync()) {
      return FileImage(File(imagePath));
    } else {
      // Return a default image provider or handle the error
      return const AssetImage('assets/images/placeholder.png'); // Make sure you have a placeholder image
    }
  }
}
