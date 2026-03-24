import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../providers/user_provider.dart';
import '../screens/app_settings_screen.dart';
import '../services/database_service.dart';
import '../utils/design_constants.dart';

class SettingsMenu extends StatelessWidget {
  const SettingsMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.settings_outlined,
        color: AppTheme.textPrimary,
        size: 24,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      itemBuilder: (BuildContext context) => [
        PopupMenuItem<String>(
          value: 'settings',
          child: Row(
            children: [
              Icon(
                Icons.tune_outlined,
                color: AppTheme.textPrimary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'App Settings',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'wipe_db',
          child: Row(
            children: [
              Icon(
                Icons.delete_forever_outlined,
                color: AppColors.error,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Wipe Local Database',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.error,
                ),
              ),
            ],
          ),
        ),
        PopupMenuItem<String>(
          value: 'logout',
          child: Row(
            children: [
              Icon(
                Icons.logout_outlined,
                color: AppTheme.textPrimary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.md),
              Text(
                'Logout',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
      onSelected: (String value) {
        if (value == 'settings') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AppSettingsScreen(),
            ),
          );
        } else if (value == 'wipe_db') {
          _showWipeDatabaseDialog(context);
        } else if (value == 'logout') {
          _showLogoutConfirmation(context);
        }
      },
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Logout',
          style: AppTextStyles.heading3.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final nav = Navigator.of(context, rootNavigator: true);
              final messenger = ScaffoldMessenger.maybeOf(context);
              final userProvider =
                  Provider.of<UserProvider>(context, listen: false);
              Navigator.pop(context);
              await userProvider.logout();
              nav.popUntil((route) => route.isFirst);
              messenger?.showSnackBar(
                SnackBar(
                  content: const Text('Logged out successfully'),
                  backgroundColor: AppColors.primary,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  void _showWipeDatabaseDialog(BuildContext context) {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 24),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Wipe Database',
              style: AppTextStyles.heading3.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This will permanently delete ALL local SQLite data and reseed default users and settings.',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Enter password to confirm:',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppRadius.button),
                ),
              ),
              autofocus: true,
              onSubmitted: (_) => _handleWipeDatabase(
                dialogContext,
                passwordController.text,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: Text(
              'Cancel',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => _handleWipeDatabase(
              dialogContext,
              passwordController.text,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            child: const Text('Wipe Database'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleWipeDatabase(BuildContext context, String password) async {
    if (password != AppConfig.wipeDatabasePassword) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Incorrect password'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            Icon(Icons.dangerous, color: AppColors.error, size: 24),
            const SizedBox(width: AppSpacing.md),
            Text(
              'Final Confirmation',
              style: AppTextStyles.heading3.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.error,
              ),
            ),
          ],
        ),
        content: Text(
          'This action CANNOT be undone. Wipe everything?',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppTheme.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            child: const Text('Yes, wipe everything'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    if (!context.mounted) return;

    final nav = Navigator.of(context, rootNavigator: true);
    final messenger = ScaffoldMessenger.maybeOf(context);

    if (context.mounted) {
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );
    }

    try {
      await DatabaseService.instance.wipeDatabase();
      if (!context.mounted) return;
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      await userProvider.logout();
      nav.popUntil((route) => route.isFirst);
      messenger?.showSnackBar(
        SnackBar(
          content: const Text('Local database wiped successfully'),
          backgroundColor: AppColors.primary,
          duration: const Duration(seconds: 3),
        ),
      );
    } catch (e) {
      if (nav.canPop()) {
        nav.pop();
      }
      messenger?.showSnackBar(
        SnackBar(
          content: Text('Failed to wipe database: $e'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }
}
