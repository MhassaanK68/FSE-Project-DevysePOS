import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../services/database_service.dart';
import '../utils/design_constants.dart';

class AppSettingsScreen extends StatefulWidget {
  const AppSettingsScreen({super.key});

  @override
  State<AppSettingsScreen> createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  final _storeNameController = TextEditingController();
  final _receiptFooterController = TextEditingController();
  bool _loading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final store = await DatabaseService.instance.getSetting('store_name');
    final footer = await DatabaseService.instance.getSetting('receipt_footer');
    if (mounted) {
      setState(() {
        _storeNameController.text = store ?? '';
        _receiptFooterController.text = footer ?? '';
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _storeNameController.dispose();
    _receiptFooterController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await DatabaseService.instance.setSetting(
      'store_name',
      _storeNameController.text.trim(),
    );
    await DatabaseService.instance.setSetting(
      'receipt_footer',
      _receiptFooterController.text.trim(),
    );
    if (mounted) {
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Settings saved'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.button),
          ),
          margin: const EdgeInsets.all(AppSpacing.xl),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('App Settings'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Store',
                      style: AppTextStyles.heading3.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextField(
                      controller: _storeNameController,
                      decoration: const InputDecoration(
                        labelText: 'Store name',
                        hintText: 'Shown on receipts and dashboards',
                        prefixIcon: Icon(Icons.storefront_outlined),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'Receipts',
                      style: AppTextStyles.heading3.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    TextField(
                      controller: _receiptFooterController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Receipt footer',
                        hintText: 'Thank you message',
                        prefixIcon: Icon(Icons.receipt_long_outlined),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      'About',
                      style: AppTextStyles.heading3.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '${AppConfig.appName} v${AppConfig.appVersion}',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxxl),
                    SizedBox(
                      height: AppTouchTarget.buttonHeight,
                      child: ElevatedButton(
                        onPressed: _saving ? null : _save,
                        child: _saving
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.secondary,
                                ),
                              )
                            : Text(
                                'Save settings',
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
            ),
    );
  }
}
