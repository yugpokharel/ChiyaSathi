import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:chiya_sathi/features/auth/presentation/view_model/auth_view_model_provider.dart';
import 'dart:io';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final authEntity = authState.authEntity;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black, fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: authEntity != null
          ? SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 20),
                  // Profile Picture
                  _buildProfilePicture(authEntity.profilePicture),
                  const SizedBox(height: 30),
                  
                  // User Info
                  _buildInfoCard('Full Name', authEntity.fullName),
                  const SizedBox(height: 16),
                  _buildInfoCard('Username', authEntity.username),
                  const SizedBox(height: 16),
                  _buildInfoCard('Email', authEntity.email),
                  const SizedBox(height: 16),
                  _buildInfoCard('Phone Number', authEntity.phoneNumber),
                  const SizedBox(height: 30),
                  
                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        // Add logout functionality here
                        Navigator.pushReplacementNamed(context, '/login');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red.shade400,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'LOGOUT',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No user logged in',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProfilePicture(String? profilePicturePath) {
    return Center(
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.orange, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withAlpha(50),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipOval(
          child: profilePicturePath != null && File(profilePicturePath).existsSync()
              ? Image.file(
                  File(profilePicturePath),
                  fit: BoxFit.cover,
                )
              : Container(
                  color: Colors.grey.shade200,
                  child: Icon(
                    Icons.person,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
