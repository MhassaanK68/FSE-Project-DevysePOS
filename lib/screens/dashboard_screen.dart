import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../config/app_config.dart';
import '../providers/user_provider.dart';
import '../services/database_service.dart';
import '../utils/currency_formatter.dart';
import '../utils/design_constants.dart';
import '../widgets/metric_card.dart';
import '../widgets/settings_menu.dart';
import 'categories_screen.dart';
import 'flow_placeholder_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DatabaseService _db = DatabaseService.instance;
  int _todayOrders = 0;
  double _todayRevenue = 0;
  int _pendingSync = 0;
  bool _loadingMetrics = true;

  @override
  void initState() {
    super.initState();
    _loadMetrics();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadMetrics();
  }

  Future<void> _loadMetrics() async {
    setState(() => _loadingMetrics = true);
    try {
      final orders = await _db.getTodayOrdersCount();
      final revenue = await _db.getTodayRevenue();
      final sync = await _db.getPendingSyncCount();
      if (mounted) {
        setState(() {
          _todayOrders = orders;
          _todayRevenue = revenue;
          _pendingSync = sync;
          _loadingMetrics = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loadingMetrics = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.only(
              top: topPadding + AppSpacing.md,
              bottom: AppSpacing.lg,
              left: AppSpacing.xl,
              right: AppSpacing.xl,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              boxShadow: AppShadows.light,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<UserProvider>(
                  builder: (context, userProvider, child) {
                    return Text(
                      'Welcome back, ${userProvider.displayName}!',
                      style: AppTextStyles.heading3.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    );
                  },
                ),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Consumer<UserProvider>(
                      builder: (context, userProvider, child) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              userProvider.displayName,
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              userProvider.isAdmin ? 'Admin' : 'Cashier',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(width: AppSpacing.md),
                    const SettingsMenu(),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MetricCard(
                          icon: Icons.shopping_cart_outlined,
                          title: "Today's Orders",
                          value: _loadingMetrics ? '...' : _todayOrders.toString(),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xl),
                      Expanded(
                        child: MetricCard(
                          icon: Icons.attach_money_outlined,
                          title: "Today's Revenue",
                          value: _loadingMetrics
                              ? '...'
                              : CurrencyFormatter.format(_todayRevenue),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xl),
                      Expanded(
                        child: MetricCard(
                          icon: Icons.sync_outlined,
                          title: 'Pending Sync',
                          value: _loadingMetrics ? '...' : _pendingSync.toString(),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xl),
                      Expanded(
                        child: MetricCard(
                          icon: Icons.notes_outlined,
                          title: 'App Version',
                          value: AppConfig.appVersion,
                        ),
                      ),
                    ],
                  ),
                  Consumer<UserProvider>(
                    builder: (context, userProvider, child) {
                      if (!userProvider.isAdmin) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.section),
                          Text(
                            'Quick Actions',
                            style: AppTextStyles.heading3.copyWith(
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          GridView.count(
                            crossAxisCount: 4,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisSpacing: AppSpacing.xl,
                            mainAxisSpacing: AppSpacing.xl,
                            childAspectRatio: 1.2,
                            children: [
                              _buildActionCard(
                                icon: Icons.restaurant_menu_outlined,
                                title: 'Products',
                                description: 'Manage menu items and pricing',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (context) =>
                                        const FlowPlaceholderScreen(
                                      title: 'Products',
                                      description:
                                          'Product catalog management will be available here.',
                                      icon: Icons.restaurant_menu_outlined,
                                    ),
                                  ),
                                ),
                              ),
                              _buildActionCard(
                                icon: Icons.category_outlined,
                                title: 'Categories',
                                description: 'Manage product categories',
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute<void>(
                                    builder: (context) =>
                                        const CategoriesScreen(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(
          minHeight: AppTouchTarget.cardMinHeight,
        ),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.card),
          boxShadow: AppShadows.soft,
        ),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Icon(icon, color: AppColors.primary, size: 32),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              description,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
