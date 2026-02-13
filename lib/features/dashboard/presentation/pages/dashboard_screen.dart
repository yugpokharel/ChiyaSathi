import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chiya_sathi/features/auth/presentation/view_model/auth_view_model_provider.dart';
import 'package:chiya_sathi/features/dashboard/presentation/pages/bottom/home_screen.dart';
import 'package:chiya_sathi/features/dashboard/presentation/pages/bottom/menu_screen.dart';
import 'package:chiya_sathi/features/dashboard/presentation/pages/bottom/profile_screen.dart';
import 'dart:io';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> {
  int _selectedIndex = 0;

  final List<Widget> _lstBottomScreen = [
    HomeScreen(),
    MenuScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authViewModelProvider);
    final profilePicture = authState.authEntity?.profilePicture;

    return Scaffold(
      extendBodyBehindAppBar: false, // Prevent body from drawing behind app bar
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(''), // Empty title
        backgroundColor: Colors.white, // Use a solid color
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 2; // Navigate to Profile
                });
              },
              child: CircleAvatar(
                radius: 24,
                backgroundColor: Colors.orange,
                child: CircleAvatar(
                  radius: 22,
                  backgroundImage: profilePicture != null && profilePicture.isNotEmpty
                      ? _getProfileImage(profilePicture)
                      : null,
                  child: profilePicture == null || profilePicture.isEmpty
                      ? Icon(
                          Icons.person,
                          color: Colors.grey.shade400,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
      body: _lstBottomScreen[_selectedIndex], // Removed SafeArea from here
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
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  ImageProvider _getProfileImage(String imagePath) {
    if (imagePath.startsWith('http') || imagePath.startsWith('/uploads')) {
      final url = imagePath.startsWith('http')
          ? imagePath
          : 'http://192.168.1.3:5000$imagePath';
      return NetworkImage(url);
    } else if (File(imagePath).existsSync()) {
      return FileImage(File(imagePath));
    } else {
      // Return a default image provider or handle the error
      return const AssetImage('assets/images/placeholder.png'); // Make sure you have a placeholder image
    }
  }
}
