import 'package:flutter/material.dart';
import 'package:kelompok6_manajemen_farmasi/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatelessWidget {
  ProfilePage({super.key});
  final user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.account_circle),
              title: Text(user?.displayName ?? 'Nama tidak tersedia'),
              subtitle: Text(user?.email ?? 'Email tidak tersedia'),
            ),
            ElevatedButton(
              onPressed: () async {
                await AuthService().logout();
              },
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }
}