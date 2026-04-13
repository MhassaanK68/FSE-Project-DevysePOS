import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/transaction.dart' as models;
import '../models/transaction_item.dart';
import '../providers/transaction_provider.dart';
import '../providers/user_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/design_constants.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() =>
      _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadTransactions());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadTransactions() {
    final userProvider = context.read<UserProvider>();
    final txnProvider = context.read<TransactionProvider>();
    txnProvider.searchTransactions(
      query: _searchQuery.isEmpty ? null : _searchQuery,
      cashierUsername: userProvider.isAdmin ? null : userProvider.currentUser?.username,
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: now,
      initialDateRange: _startDate != null && _endDate != null
          ? DateTimeRange(start: _startDate!, end: _endDate!)
          : DateTimeRange(
              start: now.subtract(const Duration(days: 30)), end: now),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
                  primary: AppColors.primary,
                ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _loadTransactions();
    }
  }

  void _clearFilters() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _startDate = null;
      _endDate = null;
    });
    _loadTransactions();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(context),
          _buildFilters(),
          Expanded(child: _buildTransactionList()),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
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
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor: AppColors.greyLight,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Text(
            'Transaction History',
            style: AppTextStyles.heading3.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    final hasFilters =
        _searchQuery.isNotEmpty || _startDate != null || _endDate != null;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      color: AppColors.surface,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by transaction number...',
                    prefixIcon: const Icon(Icons.search,
                        color: AppTheme.textSecondary),
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() => _searchQuery = '');
                              _loadTransactions();
                            },
                          )
                        : null,
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                    _loadTransactions();
                  },
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              OutlinedButton.icon(
                onPressed: _pickDateRange,
                icon: const Icon(Icons.date_range, size: 18),
                label: Text(_startDate != null && _endDate != null
                    ? '${_formatDate(_startDate!)} - ${_formatDate(_endDate!)}'
                    : 'Date Range'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: _startDate != null
                      ? AppColors.primary
                      : AppTheme.textSecondary,
                  side: BorderSide(
                    color: _startDate != null
                        ? AppColors.primary
                        : AppTheme.divider,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.button),
                  ),
                ),
              ),
              if (hasFilters) ...[
                const SizedBox(width: AppSpacing.sm),
                IconButton(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.filter_alt_off, size: 20),
                  tooltip: 'Clear filters',
                  color: AppColors.error,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionList() {
    return Consumer<TransactionProvider>(
      builder: (context, txnProvider, _) {
        if (txnProvider.isLoading) {
          return const Center(
              child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (txnProvider.transactions.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_outlined,
                    size: 56, color: AppColors.grey),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'No transactions found',
                  style: AppTextStyles.bodyLarge
                      .copyWith(color: AppTheme.textSecondary),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.lg),
          itemCount: txnProvider.transactions.length,
          itemBuilder: (context, index) {
            final txn = txnProvider.transactions[index];
            return _buildTransactionCard(txn);
          },
        );
      },
    );
  }

  Widget _buildTransactionCard(models.Transaction txn) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: AppShadows.soft,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showReceiptDetail(txn),
          borderRadius: BorderRadius.circular(AppRadius.card),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Icon(Icons.receipt_outlined,
                      color: AppColors.primary, size: 24),
                ),
                const SizedBox(width: AppSpacing.lg),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        txn.transactionNumber,
                        style: AppTextStyles.labelLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        '${_formatDateTime(txn.createdAt)}  ·  ${txn.cashierUsername}  ·  ${txn.itemCount ?? 0} item(s)',
                        style: AppTextStyles.bodySmall
                            .copyWith(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      CurrencyFormatter.format(txn.total),
                      style: AppTextStyles.labelLarge.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    if (txn.discountPercentage > 0)
                      Text(
                        '-${txn.discountPercentage.toStringAsFixed(1)}%',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: AppSpacing.sm),
                const Icon(Icons.chevron_right, color: AppTheme.textTertiary),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReceiptDetail(models.Transaction txn) async {
    final txnProvider = context.read<TransactionProvider>();
    final items = await txnProvider.getTransactionItems(txn.id);

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (ctx) => _ReceiptDetailDialog(transaction: txn, items: items),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }

  String _formatDateTime(DateTime dt) {
    final date = _formatDate(dt);
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    return '$date $time';
  }
}

class _ReceiptDetailDialog extends StatelessWidget {
  final models.Transaction transaction;
  final List<TransactionItem> items;

  const _ReceiptDetailDialog({
    required this.transaction,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.lg),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 650),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.receipt_long,
                    color: AppColors.primary, size: 32),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                'Receipt',
                style: AppTextStyles.heading3
                    .copyWith(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                transaction.transactionNumber,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${_formatDateTime(transaction.createdAt)}  ·  ${transaction.cashierUsername}',
                style: AppTextStyles.bodySmall
                    .copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Divider(),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.productName,
                                    style: AppTextStyles.labelLarge),
                                Text(
                                  '${CurrencyFormatter.format(item.productPrice)} x ${item.quantity}',
                                  style: AppTextStyles.bodySmall.copyWith(
                                      color: AppTheme.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(item.subtotal),
                            style: AppTextStyles.labelLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
              const SizedBox(height: AppSpacing.sm),
              _buildRow('Subtotal',
                  CurrencyFormatter.format(transaction.subtotal)),
              if (transaction.discountPercentage > 0) ...[
                const SizedBox(height: AppSpacing.xs),
                _buildRow(
                  'Discount (${transaction.discountPercentage.toStringAsFixed(1)}%)',
                  '- ${CurrencyFormatter.format(transaction.discountAmount)}',
                  valueColor: AppColors.error,
                ),
              ],
              const SizedBox(height: AppSpacing.sm),
              _buildRow(
                'Total',
                CurrencyFormatter.format(transaction.total),
                isBold: true,
                valueColor: AppColors.primary,
              ),
              const SizedBox(height: AppSpacing.xs),
              _buildRow('Payment', transaction.paymentMethod.toUpperCase()),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(String label, String value,
      {bool isBold = false, Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: (isBold ? AppTextStyles.labelLarge : AppTextStyles.bodyMedium)
              .copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style:
              (isBold ? AppTextStyles.labelLarge : AppTextStyles.bodyMedium)
                  .copyWith(
            fontWeight: isBold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor,
            fontSize: isBold ? 18 : null,
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dt) {
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
  }
}
