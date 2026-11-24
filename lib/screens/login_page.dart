import 'package:flutter/material.dart';
import 'package:pharmadex/services/auth_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _authService = AuthService();
  bool _isLoading = false;

  Future<void> _handleGoogleLogin() async {
    setState(() => _isLoading = true);
    final user = await _authService.loginWithGoogle();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login gagal atau dibatalkan')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton.icon(
          onPressed: _isLoading ? null : _handleGoogleLogin,
          icon: const Icon(Icons.login),
          label: _isLoading ? const Text('Sedang masuk...') : const Text('Masuk dengan Google'),
        ),
      ),
    );
  }
}