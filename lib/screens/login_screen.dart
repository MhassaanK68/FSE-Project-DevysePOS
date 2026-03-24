import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/user_provider.dart';
import '../services/database_service.dart';
import '../utils/design_constants.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _rememberMe = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
    _loadRememberMeState();
  }

  Future<void> _loadRememberMeState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rememberMe = prefs.getBool('remember_me') ?? false;
      if (mounted) {
        setState(() => _rememberMe = rememberMe);
      }
    } catch (e) {
      debugPrint('Failed to load remember me state: $e');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    await Future.delayed(const Duration(milliseconds: 600));

    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    final user =
        await DatabaseService.instance.authenticateUser(username, password);

    if (!mounted) return;

    if (user != null) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.login(user, rememberMe: _rememberMe);
      HapticFeedback.lightImpact();
    } else {
      HapticFeedback.heavyImpact();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.error_outline, color: Colors.white, size: 20),
              SizedBox(width: AppSpacing.md),
              Text('Invalid username or password'),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          margin: const EdgeInsets.all(AppSpacing.xl),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isSmallScreen = size.height < 700;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!isSmallScreen) const SizedBox(height: AppSpacing.huge),
                      Image.asset(
                        'assets/logo.png',
                        height: isSmallScreen ? 80 : 120,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: isSmallScreen ? 80 : 120,
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppRadius.lg),
                            ),
                            child: Icon(
                              Icons.point_of_sale,
                              size: isSmallScreen ? 40 : 60,
                              color: AppColors.primary,
                            ),
                          );
                        },
                      ),
                      if (!isSmallScreen) const SizedBox(height: AppSpacing.xxxl),
                      if (isSmallScreen) const SizedBox(height: AppSpacing.xxl),
                      Text(
                        'Welcome Back',
                        style: AppTextStyles.heading1.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Sign in to continue to DevysePOS',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: AppSpacing.xxxl),
                      Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'Username',
                                hintText: 'Enter your username',
                                prefixIcon: const Icon(Icons.person_outline),
                                suffixIcon: _usernameController.text.isNotEmpty
                                    ? IconButton(
                                        icon:
                                            const Icon(Icons.clear, size: 20),
                                        onPressed: () {
                                          _usernameController.clear();
                                          setState(() {});
                                        },
                                      )
                                    : null,
                              ),
                              textInputAction: TextInputAction.next,
                              keyboardType: TextInputType.text,
                              autofillHints: const [AutofillHints.username],
                              validator: (value) {
                                if (value == null || value.trim().isEmpty) {
                                  return 'Please enter your username';
                                }
                                return null;
                              },
                              onChanged: (_) => setState(() {}),
                              onFieldSubmitted: (_) =>
                                  FocusScope.of(context).nextFocus(),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                hintText: 'Enter your password',
                                prefixIcon: const Icon(Icons.lock_outline),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_outlined
                                        : Icons.visibility_off_outlined,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                    HapticFeedback.selectionClick();
                                  },
                                ),
                              ),
                              textInputAction: TextInputAction.done,
                              keyboardType: TextInputType.visiblePassword,
                              autofillHints: const [AutofillHints.password],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                return null;
                              },
                              onFieldSubmitted: (_) => _handleLogin(),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Checkbox(
                                      value: _rememberMe,
                                      onChanged: (value) {
                                        setState(() {
                                          _rememberMe = value ?? false;
                                        });
                                        HapticFeedback.selectionClick();
                                      },
                                      activeColor: AppColors.primary,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                    ),
                                    Text(
                                      'Remember me',
                                      style: AppTextStyles.bodyMedium.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                                TextButton(
                                  onPressed: () {
                                    HapticFeedback.selectionClick();
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'Forgot password feature coming soon',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.button,
                                          ),
                                        ),
                                        margin: const EdgeInsets.all(
                                          AppSpacing.xl,
                                        ),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    'Forgot Password?',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xxl),
                            SizedBox(
                              height: AppTouchTarget.buttonHeight,
                              child: ElevatedButton(
                                onPressed: _isLoading ? null : _handleLogin,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.secondary,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.button,
                                    ),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            AppColors.secondary,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'Sign In',
                                        style: AppTextStyles.labelLarge.copyWith(
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.secondary,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
