import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../screens/dashboard_screen.dart';
import '../screens/login_screen.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    await userProvider.initialize();
    if (mounted) {
      setState(() => _isInitialized = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        if (userProvider.isAuthenticated) {
          return const DashboardScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
