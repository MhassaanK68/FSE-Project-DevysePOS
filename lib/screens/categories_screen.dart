import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/category.dart' as models;
import '../providers/category_provider.dart';
import '../providers/user_provider.dart';
import '../utils/category_icons.dart';
import '../utils/design_constants.dart';
import '../utils/uuid_generator.dart';

typedef Category = models.Category;

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final user = Provider.of<UserProvider>(context, listen: false);
      if (user.isAdmin) _loadCategories();
    });
  }

  void _loadCategories() {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    switch (_selectedFilter) {
      case 'Active':
        categoryProvider.loadCategories(activeOnly: true);
        break;
      case 'Inactive':
        categoryProvider.loadInactiveCategories();
        break;
      case 'All':
      default:
        categoryProvider.loadCategories(activeOnly: false);
        break;
    }
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = label;
        });
        _loadCategories();
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.2),
      checkmarkColor: AppColors.primary,
      labelStyle: AppTextStyles.bodyMedium.copyWith(
        color: isSelected ? AppColors.primary : AppTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
    );
  }

  void _showAddCategoryDialog(BuildContext context) {
    _showCategoryDialog(context, null);
  }

  void _showEditCategoryDialog(BuildContext context, Category category) {
    _showCategoryDialog(context, category);
  }

  void _showCategoryDialog(BuildContext context, Category? category) {
    final nameController = TextEditingController(text: category?.name ?? '');
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: 500,
            maxHeight: 400,
          ),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xl),
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    category == null ? 'Add Category' : 'Edit Category',
                    style: AppTextStyles.heading3.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  TextFormField(
                    controller: nameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Category Name',
                      labelStyle: AppTextStyles.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                      filled: true,
                      fillColor: AppColors.greyVeryLight,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                        borderSide: BorderSide(color: AppTheme.divider),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                        borderSide: BorderSide(color: AppTheme.divider),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppRadius.button),
                        borderSide:
                            BorderSide(color: AppColors.primary, width: 2),
                      ),
                      contentPadding: const EdgeInsets.all(AppSpacing.lg),
                    ),
                    style: AppTextStyles.bodyMedium,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter category name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(
                          'Cancel',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final categoryProvider =
                                Provider.of<CategoryProvider>(context,
                                    listen: false);
                            final now = DateTime.now();

                            final categoryToSave = category == null
                                ? Category(
                                    id: UUIDGenerator.generate(),
                                    name: nameController.text.trim(),
                                    isActive: true,
                                    createdAt: now,
                                    updatedAt: now,
                                  )
                                : category.copyWith(
                                    name: nameController.text.trim(),
                                    updatedAt: now,
                                  );

                            final success = category == null
                                ? await categoryProvider
                                    .addCategory(categoryToSave)
                                : await categoryProvider
                                    .updateCategory(categoryToSave);

                            if (context.mounted) {
                              Navigator.pop(context);
                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      category == null
                                          ? 'Category added successfully'
                                          : 'Category updated successfully',
                                    ),
                                    backgroundColor: AppColors.primary,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      categoryProvider.error ??
                                          'Failed to save category',
                                    ),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            }
                          }
                        },
                        child: Text(
                          category == null ? 'Add' : 'Update',
                          style: AppTextStyles.labelLarge.copyWith(
                            color: AppColors.secondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Category category) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Delete Category',
          style: AppTextStyles.heading3.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${category.name}"? This will deactivate the category. Products using this category will remain assigned to it.',
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
              final categoryProvider =
                  Provider.of<CategoryProvider>(context, listen: false);
              final success =
                  await categoryProvider.deleteCategory(category.id);

              if (context.mounted) {
                Navigator.pop(context);
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Category deleted successfully'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        categoryProvider.error ?? 'Failed to delete category',
                      ),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.secondary,
            ),
            child: Text(
              'Delete',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showProductCountDialog(
      BuildContext context, Category category) async {
    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    final productCount =
        await categoryProvider.getProductCountForCategory(category.name);

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: Text(
            category.name,
            style: AppTextStyles.heading3.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            'This category has $productCount product(s).',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'Close',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (!userProvider.isAdmin) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              toolbarHeight: 56 + topPadding,
              backgroundColor: AppColors.surface,
              elevation: 0,
              title: Text(
                'Category Management',
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              iconTheme: const IconThemeData(
                color: AppTheme.textPrimary,
              ),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'Only administrators can manage categories.',
                  style: AppTextStyles.bodyLarge.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            toolbarHeight: 56 + topPadding,
            backgroundColor: AppColors.surface,
            elevation: 0,
            title: Text(
              'Category Management',
              style: AppTextStyles.heading3.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            iconTheme: const IconThemeData(
              color: AppTheme.textPrimary,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddCategoryDialog(context),
                tooltip: 'Add Category',
              ),
            ],
          ),
          body: Consumer<CategoryProvider>(
            builder: (context, categoryProvider, child) {
              if (categoryProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                  ),
                );
              }

              if (categoryProvider.error != null) {
                return Center(
                  child: Text(
                    'Error: ${categoryProvider.error}',
                    style: AppTextStyles.bodyLarge,
                  ),
                );
              }

              return Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      boxShadow: AppShadows.light,
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Filter:',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(
                          child: Row(
                            children: [
                              _buildFilterChip('All', _selectedFilter == 'All'),
                              const SizedBox(width: AppSpacing.md),
                              _buildFilterChip(
                                  'Active', _selectedFilter == 'Active'),
                              const SizedBox(width: AppSpacing.md),
                              _buildFilterChip(
                                  'Inactive', _selectedFilter == 'Inactive'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (categoryProvider.categories.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.category_outlined,
                              size: 64,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'No categories available',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _showAddCategoryDialog(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Category'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.secondary,
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.button),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(AppSpacing.xl),
                        itemCount: categoryProvider.categories.length,
                        itemBuilder: (context, index) {
                          final category = categoryProvider.categories[index];
                          return Container(
                            margin:
                                const EdgeInsets.only(bottom: AppSpacing.md),
                            decoration: BoxDecoration(
                              color: category.isActive
                                  ? AppColors.surface
                                  : AppColors.greyVeryLight,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.card),
                              boxShadow: AppShadows.soft,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _showProductCountDialog(
                                    context, category),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.card),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.xl),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        decoration: BoxDecoration(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.md),
                                        ),
                                        child: Icon(
                                          CategoryIcons.getIcon(category.name),
                                          color: AppColors.primary,
                                          size: 24,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.lg),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              category.name,
                                              style: AppTextStyles.bodyLarge
                                                  .copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: category.isActive
                                                    ? AppTheme.textPrimary
                                                    : AppTheme.textTertiary,
                                              ),
                                            ),
                                            const SizedBox(
                                                height: AppSpacing.xs),
                                            Text(
                                              category.isActive
                                                  ? 'Active'
                                                  : 'Inactive',
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                color: category.isActive
                                                    ? AppColors.primary
                                                    : AppTheme.textTertiary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                                Icons.edit_outlined,
                                                size: 20),
                                            onPressed: () =>
                                                _showEditCategoryDialog(
                                                    context, category),
                                            color: AppColors.primary,
                                            constraints: const BoxConstraints(
                                              minWidth: AppTouchTarget.minSize,
                                              minHeight: AppTouchTarget.minSize,
                                            ),
                                          ),
                                          if (category.isActive)
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.delete_outline,
                                                  size: 20),
                                              onPressed: () =>
                                                  _showDeleteConfirmation(
                                                      context, category),
                                              color: AppColors.error,
                                              constraints:
                                                  const BoxConstraints(
                                                minWidth:
                                                    AppTouchTarget.minSize,
                                                minHeight:
                                                    AppTouchTarget.minSize,
                                              ),
                                            )
                                          else
                                            IconButton(
                                              icon: const Icon(
                                                  Icons.restore_outlined,
                                                  size: 20),
                                              onPressed: () async {
                                                final categoryProvider =
                                                    Provider.of<
                                                            CategoryProvider>(
                                                        context,
                                                        listen: false);
                                                final success =
                                                    await categoryProvider
                                                        .reactivateCategory(
                                                            category.id);
                                                if (context.mounted) {
                                                  if (success) {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      const SnackBar(
                                                        content: Text(
                                                            'Category reactivated successfully'),
                                                        backgroundColor:
                                                            AppColors.primary,
                                                      ),
                                                    );
                                                  } else {
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(
                                                      SnackBar(
                                                        content: Text(
                                                          categoryProvider
                                                                  .error ??
                                                              'Failed to reactivate category',
                                                        ),
                                                        backgroundColor:
                                                            AppColors.error,
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                              color: AppColors.primary,
                                              constraints:
                                                  const BoxConstraints(
                                                minWidth:
                                                    AppTouchTarget.minSize,
                                                minHeight:
                                                    AppTouchTarget.minSize,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
