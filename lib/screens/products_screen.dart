import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/combo_item.dart';
import '../models/product.dart';
import '../providers/category_provider.dart';
import '../providers/product_provider.dart';
import '../providers/user_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/design_constants.dart';
import '../utils/image_helper.dart';
import '../utils/uuid_generator.dart';
import '../widgets/placeholder_image.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _selectedFilter = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadProducts();
    });
  }

  void _loadProducts() {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    switch (_selectedFilter) {
      case 'Active':
        productProvider.loadProducts(activeOnly: true);
        break;
      case 'Inactive':
        productProvider.loadInactiveProducts();
        break;
      case 'All':
      default:
        productProvider.loadProducts(activeOnly: false);
        break;
    }
  }

  void _showErrorDialog(BuildContext context, String title, String message) {
    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 24),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ],
        ),
        content: Text(message, style: AppTextStyles.bodyMedium),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _onSelectImage(
    BuildContext context,
    void Function(void Function()) setModalState,
    List<Object?> imageState,
  ) async {
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Select Image Source',
          style: AppTextStyles.heading3.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library, color: AppColors.primary),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt, color: AppColors.primary),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null || !context.mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      ),
    );

    try {
      final File? image = await ImageHelper.pickImage(source: source);
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();

      if (image == null || !await image.exists()) return;
      await Future<void>.delayed(const Duration(milliseconds: 200));
      if (!context.mounted) return;

      File? croppedImage;
      try {
        croppedImage = await ImageHelper.cropImage(image);
      } catch (e) {
        if (context.mounted) {
          _showErrorDialog(
            context,
            'Error Cropping Image',
            'Something went wrong while cropping. Please try again.\n\n$e',
          );
        }
        return;
      }

      if (croppedImage != null && context.mounted) {
        setModalState(() {
          imageState[1] = croppedImage;
          imageState[0] = null;
          imageState[2] = false;
        });
      }
    } catch (e) {
      if (context.mounted) {
        try {
          Navigator.of(context, rootNavigator: true).pop();
        } catch (_) {}
        _showErrorDialog(
          context,
          'Error Selecting Image',
          'Something went wrong while selecting the image.\n\n$e',
        );
      }
    }
  }

  void _showAddProductDialog(BuildContext context) {
    _showProductDialog(context, null);
  }

  void _showEditProductDialog(BuildContext context, Product product) {
    _showProductDialog(context, product);
  }

  void _showProductDialog(BuildContext context, Product? product) async {
    final nameController = TextEditingController(text: product?.name ?? '');
    final priceController =
        TextEditingController(text: product?.price.toString() ?? '');
    final formKey = GlobalKey<FormState>();
    final imageState = <Object?>[
      product?.imageUrl,
      null,
      false,
    ];

    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    await categoryProvider.loadCategories(activeOnly: true);
    final categories = categoryProvider.categories.map((c) => c.name).toList();
    String selectedCategory =
        product?.category ?? (categories.isNotEmpty ? categories.first : '');

    if (categories.isEmpty && context.mounted) {
      showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          title: Text(
            'No Categories',
            style: AppTextStyles.heading3.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            'Please create at least one category before adding products.',
            style: AppTextStyles.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                'OK',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.primary,
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    if (!context.mounted) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product == null ? 'Add Product' : 'Edit Product',
                      style: AppTextStyles.heading3.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Product Image',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            GestureDetector(
                              onTap: () =>
                                  _onSelectImage(context, setModalState, imageState),
                              child: Container(
                                height: 150,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: AppColors.greyVeryLight,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.button),
                                  border: Border.all(color: AppTheme.divider),
                                ),
                                child: imageState[2] == true
                                    ? _buildImagePlaceholder()
                                    : imageState[1] != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                AppRadius.button),
                                            child: Image.file(
                                              imageState[1]! as File,
                                              fit: BoxFit.cover,
                                              width: double.infinity,
                                              height: 150,
                                            ),
                                          )
                                        : imageState[0] != null
                                            ? ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppRadius.button),
                                                child: Image.file(
                                                  File(imageState[0]! as String),
                                                  fit: BoxFit.cover,
                                                  width: double.infinity,
                                                  height: 150,
                                                  errorBuilder: (c, e, s) {
                                                    return _buildImagePlaceholder();
                                                  },
                                                ),
                                              )
                                            : _buildImagePlaceholder(),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            if (imageState[1] != null ||
                                (imageState[0] != null &&
                                    imageState[2] != true))
                              TextButton.icon(
                                onPressed: () {
                                  setModalState(() {
                                    imageState[1] = null;
                                    imageState[0] = null;
                                    imageState[2] = true;
                                  });
                                },
                                icon: const Icon(Icons.delete_outline, size: 18),
                                label: const Text('Remove Image'),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.error,
                                ),
                              ),
                            if (imageState[1] != null ||
                                imageState[0] != null)
                              const SizedBox(height: AppSpacing.lg),
                            TextFormField(
                              controller: nameController,
                              textCapitalization: TextCapitalization.words,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[a-zA-Z0-9\s]'),
                                ),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Product Name',
                                labelStyle: AppTextStyles.bodyMedium.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                                filled: true,
                                fillColor: AppColors.greyVeryLight,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.button),
                                  borderSide:
                                      BorderSide(color: AppTheme.divider),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.button),
                                  borderSide:
                                      BorderSide(color: AppTheme.divider),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.button),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                contentPadding:
                                    const EdgeInsets.all(AppSpacing.lg),
                              ),
                              style: AppTextStyles.bodyMedium,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter product name';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            TextFormField(
                              controller: priceController,
                              decoration: InputDecoration(
                                labelText: 'Price',
                                labelStyle: AppTextStyles.bodyMedium.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                                filled: true,
                                fillColor: AppColors.greyVeryLight,
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.button),
                                  borderSide:
                                      BorderSide(color: AppTheme.divider),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.button),
                                  borderSide:
                                      BorderSide(color: AppTheme.divider),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.button),
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                ),
                                contentPadding:
                                    const EdgeInsets.all(AppSpacing.lg),
                              ),
                              style: AppTextStyles.bodyMedium,
                              keyboardType: const TextInputType.numberWithOptions(
                                decimal: true,
                              ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'^\d+\.?\d{0,2}'),
                                ),
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter price';
                                }
                                final parsed = double.tryParse(value);
                                if (parsed == null) {
                                  return 'Please enter a valid number';
                                }
                                if (parsed < 0) {
                                  return 'Price cannot be negative';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.greyVeryLight,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.button),
                                border: Border.all(color: AppTheme.divider),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.lg,
                              ),
                              child: DropdownButtonFormField<String>(
                                key: ValueKey<String>(selectedCategory),
                                initialValue: categories.contains(
                                          selectedCategory,
                                        )
                                    ? selectedCategory
                                    : (categories.isNotEmpty
                                        ? categories.first
                                        : null),
                                decoration: InputDecoration(
                                  labelText: 'Category',
                                  labelStyle:
                                      AppTextStyles.bodyMedium.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                  border: InputBorder.none,
                                  contentPadding:
                                      const EdgeInsets.all(AppSpacing.lg),
                                ),
                                style: AppTextStyles.bodyMedium,
                                items: categories
                                    .map(
                                      (c) => DropdownMenuItem<String>(
                                        value: c,
                                        child: Text(c),
                                      ),
                                    )
                                    .toList(),
                                onChanged: categories.isEmpty
                                    ? null
                                    : (String? newValue) {
                                        setModalState(() {
                                          selectedCategory = newValue ??
                                              (categories.isNotEmpty
                                                  ? categories.first
                                                  : '');
                                        });
                                      },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select category';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
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
                            if (!formKey.currentState!.validate()) return;
                            final now = DateTime.now();
                            final productId =
                                product?.id ?? UUIDGenerator.generate();

                            String? imagePath;
                            var clearImageUrl = false;

                            if (imageState[1] != null) {
                              if (product != null &&
                                  product.imageUrl != null &&
                                  product.imageUrl!.isNotEmpty) {
                                await ImageHelper.deleteImage(product.imageUrl);
                              }
                              imagePath = await ImageHelper.saveImageToAppDirectory(
                                imageState[1]! as File,
                                productId,
                              );
                              if (imagePath == null) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: const Text(
                                        'Failed to save image. Please try again.',
                                      ),
                                      backgroundColor: AppColors.error,
                                    ),
                                  );
                                }
                                return;
                              }
                              clearImageUrl = false;
                            } else if (imageState[2] == true) {
                              if (product != null &&
                                  product.imageUrl != null &&
                                  product.imageUrl!.isNotEmpty) {
                                await ImageHelper.deleteImage(product.imageUrl);
                              }
                              imagePath = null;
                              clearImageUrl = true;
                            } else {
                              if (product != null &&
                                  product.imageUrl != null &&
                                  product.imageUrl!.isNotEmpty) {
                                imagePath = product.imageUrl;
                              } else {
                                imagePath = null;
                              }
                            }

                            final productToSave = product == null
                                ? Product(
                                    id: productId,
                                    name: nameController.text.trim(),
                                    price: double.parse(priceController.text),
                                    category: selectedCategory,
                                    productType: 'regular',
                                    imageUrl: imagePath,
                                    createdAt: now,
                                    updatedAt: now,
                                  )
                                : product.copyWith(
                                    name: nameController.text.trim(),
                                    price: double.parse(priceController.text),
                                    category: selectedCategory,
                                    productType: 'regular',
                                    imageUrl: imagePath,
                                    clearImageUrl: clearImageUrl,
                                    updatedAt: now,
                                  );

                            if (!context.mounted) return;
                            final productProvider =
                                Provider.of<ProductProvider>(context,
                                    listen: false);
                            final success = product == null
                                ? await productProvider.addProduct(productToSave)
                                : await productProvider
                                    .updateProduct(productToSave);

                            if (context.mounted) {
                              if (success) {
                                Navigator.pop(context);
                                _loadProducts();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      productProvider.error ??
                                          'Failed to save product',
                                    ),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.secondary,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.button),
                            ),
                          ),
                          child: Text(product == null ? 'Add' : 'Update'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateComboDialog(BuildContext context) async {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    final categoryProvider =
        Provider.of<CategoryProvider>(context, listen: false);
    await categoryProvider.loadCategories(activeOnly: true);
    if (!context.mounted) return;
    final categories = categoryProvider.categories.map((c) => c.name).toList();
    String selectedCategory =
        categories.isNotEmpty ? categories.first : '';

    final productProvider =
        Provider.of<ProductProvider>(context, listen: false);
    await productProvider.loadProducts(activeOnly: true);
    if (!context.mounted) return;
    final regularProducts = productProvider.products
        .where((p) => p.productType == 'regular')
        .toList();

    final selectedComponents = <String, int>{};

    if (!context.mounted) return;

    showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setModalState) => Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 650, maxHeight: 750),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create Combo',
                      style: AppTextStyles.heading3.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormField(
                              controller: nameController,
                              textCapitalization: TextCapitalization.words,
                              decoration: const InputDecoration(
                                labelText: 'Combo Name',
                              ),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Enter combo name'
                                  : null,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            TextFormField(
                              controller: priceController,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                    RegExp(r'^\d+\.?\d{0,2}')),
                              ],
                              decoration: const InputDecoration(
                                labelText: 'Combo Price',
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Enter combo price';
                                }
                                if (double.tryParse(v) == null) {
                                  return 'Enter valid number';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            if (categories.isNotEmpty)
                              Container(
                                decoration: BoxDecoration(
                                  color: AppColors.greyVeryLight,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.button),
                                  border:
                                      Border.all(color: AppTheme.divider),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.lg),
                                child: DropdownButtonFormField<String>(
                                  key: ValueKey<String>(selectedCategory),
                                  initialValue: categories.contains(
                                          selectedCategory)
                                      ? selectedCategory
                                      : categories.first,
                                  decoration: const InputDecoration(
                                    labelText: 'Category',
                                    border: InputBorder.none,
                                  ),
                                  items: categories
                                      .map((c) => DropdownMenuItem(
                                          value: c, child: Text(c)))
                                      .toList(),
                                  onChanged: (v) => setModalState(
                                      () => selectedCategory = v ?? ''),
                                ),
                              ),
                            const SizedBox(height: AppSpacing.xl),
                            Text(
                              'Select Items',
                              style: AppTextStyles.labelLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            if (regularProducts.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(AppSpacing.lg),
                                child: Text(
                                  'No regular products available',
                                  style: AppTextStyles.bodyMedium
                                      .copyWith(color: AppTheme.textSecondary),
                                ),
                              )
                            else
                              ...regularProducts.map((product) {
                                final isSelected = selectedComponents
                                    .containsKey(product.id);
                                final qty =
                                    selectedComponents[product.id] ?? 0;
                                return Container(
                                  margin: const EdgeInsets.only(
                                      bottom: AppSpacing.sm),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppColors.primary
                                            .withValues(alpha: 0.05)
                                        : AppColors.greyVeryLight,
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.sm),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppColors.primary
                                          : AppTheme.divider,
                                    ),
                                  ),
                                  child: ListTile(
                                    dense: true,
                                    title: Text(product.name,
                                        style: AppTextStyles.labelLarge),
                                    subtitle: Text(
                                      CurrencyFormatter.format(
                                          product.price),
                                      style: AppTextStyles.bodySmall,
                                    ),
                                    trailing: isSelected
                                        ? Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.remove,
                                                    size: 18),
                                                onPressed: () {
                                                  setModalState(() {
                                                    if (qty <= 1) {
                                                      selectedComponents
                                                          .remove(
                                                              product.id);
                                                    } else {
                                                      selectedComponents[
                                                              product.id] =
                                                          qty - 1;
                                                    }
                                                  });
                                                },
                                              ),
                                              Text('$qty',
                                                  style: AppTextStyles
                                                      .labelLarge),
                                              IconButton(
                                                icon: const Icon(
                                                    Icons.add,
                                                    size: 18),
                                                onPressed: () {
                                                  setModalState(() {
                                                    selectedComponents[
                                                            product.id] =
                                                        qty + 1;
                                                  });
                                                },
                                              ),
                                            ],
                                          )
                                        : IconButton(
                                            icon: const Icon(
                                                Icons.add_circle_outline,
                                                color: AppColors.primary),
                                            onPressed: () {
                                              setModalState(() {
                                                selectedComponents[
                                                    product.id] = 1;
                                              });
                                            },
                                          ),
                                  ),
                                );
                              }),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.labelLarge
                                .copyWith(color: AppTheme.textSecondary),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        ElevatedButton(
                          onPressed: () async {
                            if (!formKey.currentState!.validate()) return;
                            if (selectedComponents.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                      'Select at least one item for the combo'),
                                  backgroundColor: AppColors.error,
                                ),
                              );
                              return;
                            }

                            final now = DateTime.now();
                            final comboId = UUIDGenerator.generate();
                            final combo = Product(
                              id: comboId,
                              name: nameController.text.trim(),
                              price:
                                  double.parse(priceController.text),
                              category: selectedCategory,
                              productType: 'combo',
                              createdAt: now,
                              updatedAt: now,
                            );
                            final items = selectedComponents.entries
                                .map((e) => ComboItem(
                                      id: UUIDGenerator.generate(),
                                      comboProductId: comboId,
                                      componentProductId: e.key,
                                      quantity: e.value,
                                      createdAt: now,
                                    ))
                                .toList();

                            if (!context.mounted) return;
                            final pp = Provider.of<ProductProvider>(
                                context,
                                listen: false);
                            final ok =
                                await pp.addComboProduct(combo, items);
                            if (context.mounted) {
                              if (ok) {
                                Navigator.pop(context);
                                _loadProducts();
                              } else {
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(
                                  SnackBar(
                                    content: Text(pp.error ??
                                        'Failed to create combo'),
                                    backgroundColor: AppColors.error,
                                  ),
                                );
                              }
                            }
                          },
                          child: const Text('Create Combo'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.greyVeryLight,
        borderRadius: BorderRadius.circular(AppRadius.button),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 48,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Tap to add image',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
        _loadProducts();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.15)
              : AppColors.greyVeryLight,
          borderRadius: BorderRadius.circular(AppRadius.button),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppTheme.divider,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected ? AppShadows.soft : null,
        ),
        child: Text(
          label,
          style: AppTextStyles.labelMedium.copyWith(
            color: isSelected ? AppColors.primary : AppTheme.textSecondary,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Product product) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Text(
          'Deactivate Product',
          style: AppTextStyles.heading3.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to deactivate "${product.name}"? '
          'It can be reactivated later.',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: AppTextStyles.labelLarge.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final productProvider =
                  Provider.of<ProductProvider>(ctx, listen: false);
              await productProvider.deleteProduct(product.id);
              if (ctx.mounted) {
                Navigator.pop(ctx);
                _loadProducts();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.secondary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.button),
              ),
            ),
            child: const Text('Deactivate'),
          ),
        ],
      ),
    );
  }

  Future<void> _reactivateProduct(BuildContext context, Product product) async {
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    final success = await productProvider.reactivateProduct(product.id);
    if (!context.mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.name} has been reactivated'),
          backgroundColor: AppColors.primary,
        ),
      );
      _loadProducts();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(productProvider.error ?? 'Failed to reactivate'),
          backgroundColor: AppColors.error,
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
                'Product Management',
                style: AppTextStyles.heading3.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              iconTheme: const IconThemeData(color: AppTheme.textPrimary),
            ),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.xl),
                child: Text(
                  'Only administrators can manage products.',
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
              'Product Management',
              style: AppTextStyles.heading3.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            iconTheme: const IconThemeData(color: AppTheme.textPrimary),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddProductDialog(context),
                tooltip: 'Add Product',
              ),
              IconButton(
                icon: const Icon(Icons.playlist_add),
                onPressed: () => _showCreateComboDialog(context),
                tooltip: 'Create Combo',
              ),
            ],
          ),
          body: Consumer<ProductProvider>(
            builder: (context, productProvider, child) {
              if (productProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              if (productProvider.error != null) {
                return Center(
                  child: Text(
                    'Error: ${productProvider.error}',
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
                                'Active',
                                _selectedFilter == 'Active',
                              ),
                              const SizedBox(width: AppSpacing.md),
                              _buildFilterChip(
                                'Inactive',
                                _selectedFilter == 'Inactive',
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (productProvider.products.isEmpty)
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.inventory_2_outlined,
                              size: 64,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            Text(
                              'No products available',
                              style: AppTextStyles.bodyLarge.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xl),
                            ElevatedButton.icon(
                              onPressed: () =>
                                  _showAddProductDialog(context),
                              icon: const Icon(Icons.add),
                              label: const Text('Add Product'),
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
                        itemCount: productProvider.products.length,
                        itemBuilder: (context, index) {
                          final product = productProvider.products[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: AppSpacing.md),
                            decoration: BoxDecoration(
                              color: product.isActive
                                  ? AppColors.surface
                                  : AppColors.greyVeryLight,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.card),
                              boxShadow: AppShadows.soft,
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () =>
                                    _showEditProductDialog(context, product),
                                borderRadius:
                                    BorderRadius.circular(AppRadius.card),
                                child: Padding(
                                  padding: const EdgeInsets.all(AppSpacing.xl),
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width: 48,
                                        height: 48,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            AppRadius.md,
                                          ),
                                          child: product.imageUrl != null &&
                                                  product.imageUrl!.isNotEmpty
                                              ? Image.file(
                                                  File(product.imageUrl!),
                                                  fit: BoxFit.cover,
                                                  errorBuilder:
                                                      (context, error, st) {
                                                    return PlaceholderImage(
                                                      category: product.category,
                                                      iconSize: 24,
                                                    );
                                                  },
                                                )
                                              : PlaceholderImage(
                                                  category: product.category,
                                                  iconSize: 24,
                                                ),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.lg),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    product.name,
                                                    style: AppTextStyles.bodyLarge
                                                        .copyWith(
                                                      fontWeight: FontWeight.w600,
                                                      color: product.isActive
                                                          ? AppTheme.textPrimary
                                                          : AppTheme.textTertiary,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (product.productType == 'combo') ...[
                                                  const SizedBox(width: AppSpacing.sm),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(
                                                      horizontal: AppSpacing.sm,
                                                      vertical: 2,
                                                    ),
                                                    decoration: BoxDecoration(
                                                      color: AppColors.primary.withValues(alpha: 0.15),
                                                      borderRadius: BorderRadius.circular(AppRadius.sm),
                                                    ),
                                                    child: Text(
                                                      'COMBO',
                                                      style: AppTextStyles.labelSmall.copyWith(
                                                        color: AppColors.primary,
                                                        fontWeight: FontWeight.w700,
                                                        fontSize: 10,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            const SizedBox(
                                              height: AppSpacing.xs,
                                            ),
                                            Text(
                                              product.category,
                                              style: AppTextStyles.bodySmall
                                                  .copyWith(
                                                color: AppTheme.textSecondary,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.lg),
                                      Text(
                                        CurrencyFormatter.format(product.price),
                                        style: AppTextStyles.heading3.copyWith(
                                          color: product.isActive
                                              ? AppColors.primary
                                              : AppTheme.textTertiary,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.md),
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit_outlined,
                                              size: 20,
                                            ),
                                            onPressed: () =>
                                                _showEditProductDialog(
                                                  context,
                                                  product,
                                                ),
                                            color: AppColors.primary,
                                            constraints: const BoxConstraints(
                                              minWidth: AppTouchTarget.minSize,
                                              minHeight: AppTouchTarget.minSize,
                                            ),
                                          ),
                                          if (product.isActive)
                                            IconButton(
                                              icon: const Icon(
                                                Icons.delete_outline,
                                                size: 20,
                                              ),
                                              onPressed: () =>
                                                  _showDeleteConfirmation(
                                                    context,
                                                    product,
                                                  ),
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
                                                Icons.refresh,
                                                size: 20,
                                              ),
                                              onPressed: () =>
                                                  _reactivateProduct(
                                                    context,
                                                    product,
                                                  ),
                                              color: AppColors.primary,
                                              tooltip: 'Reactivate',
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
