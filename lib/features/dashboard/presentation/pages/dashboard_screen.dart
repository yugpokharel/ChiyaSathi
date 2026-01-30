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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Chiya Sathi',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedIndex = 2; // Navigate to Profile tab
                });
              },
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange, width: 2),
                ),
                child: ClipOval(
                  child: profilePicture != null && File(profilePicture).existsSync()
                      ? Image.file(
                          File(profilePicture),
                          fit: BoxFit.cover,
                        )
                      : Container(
                          color: Colors.grey.shade200,
                          child: Icon(
                            Icons.person,
                            color: Colors.grey.shade400,
                          ),
                        ),
                ),
              ),
            ),
          ),
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
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
