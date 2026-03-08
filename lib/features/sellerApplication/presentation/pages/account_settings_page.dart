import 'package:bazar/app/theme/colors.dart';
import 'package:bazar/app/theme/textstyle.dart';
import 'package:bazar/features/category/domain/entities/category_entity.dart';
import 'package:bazar/features/category/domain/usecases/get_all_category_usecase.dart';
import 'package:bazar/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:bazar/features/sellerApplication/domain/entities/seller_application_entity.dart';
import 'package:bazar/features/sellerApplication/presentation/pages/seller_application_page.dart';
import 'package:bazar/features/sellerApplication/presentation/view_model/seller_application_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AccountSettingsPage extends ConsumerStatefulWidget {
  const AccountSettingsPage({super.key});

  @override
  ConsumerState<AccountSettingsPage> createState() =>
      _AccountSettingsPageState();
}

class _AccountSettingsPageState extends ConsumerState<AccountSettingsPage> {
  List<CategoryEntity> _categories = const [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await _loadCategories();
      if (!mounted) return;
      await ref
          .read(sellerApplicationViewModelProvider.notifier)
          .fetchMyApplication();
    });
  }

  Future<void> _loadCategories() async {
    final result = await ref.read(getAllCategoryUseCaseProvider)();
    if (!mounted) return;
    result.fold((_) {}, (categories) {
      setState(() {
        _categories = categories;
      });
    });
  }

  bool _isAlreadySeller() {
    final authState = ref.read(authViewModelProvider);
    final roleName = authState.user?.role?.roleName.toLowerCase();
    return roleName == 'seller';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(sellerApplicationViewModelProvider);
    final app = state.application;

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(sellerApplicationViewModelProvider.notifier)
              .fetchMyApplication(forceRefresh: true);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          children: [
            Text(
              'Seller Account',
              style: AppTextStyle.inputBox.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Upgrade your account to start selling. Track your application status here.',
              style: AppTextStyle.minimalTexts.copyWith(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.74),
              ),
            ),
            const SizedBox(height: 16),
            if (state.isLoading && !state.hasFetched)
              const Center(child: CircularProgressIndicator())
            else ...[
              if ((state.errorMessage ?? '').isNotEmpty) ...[
                _InfoCard(
                  title: 'Unable to load application',
                  body: state.errorMessage!,
                  icon: Icons.error_outline_rounded,
                  iconColor: AppColors.error,
                ),
                const SizedBox(height: 12),
              ],
              if (_isAlreadySeller())
                _InfoCard(
                  title: 'Seller account active',
                  body:
                      'Your account already has seller access. You can now create and manage your shop.',
                  icon: Icons.verified_rounded,
                  iconColor: AppColors.success,
                )
              else if (app == null)
                _NoApplicationCard(
                  onApplyTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SellerApplicationPage(),
                      ),
                    );
                    if (context.mounted) {
                      ref
                          .read(sellerApplicationViewModelProvider.notifier)
                          .fetchMyApplication(forceRefresh: true);
                    }
                  },
                )
              else
                _ApplicationCard(
                  application: app,
                  resolvedCategoryName: _resolveCategoryName(app.categoryName),
                ),
              if (app != null &&
                  app.status == SellerApplicationStatus.rejected) ...[
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SellerApplicationPage(
                            initialData: app,
                            isReapply: true,
                          ),
                        ),
                      );
                      if (context.mounted) {
                        ref
                            .read(sellerApplicationViewModelProvider.notifier)
                            .fetchMyApplication(forceRefresh: true);
                      }
                    },
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Apply Again'),
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  String _resolveCategoryName(String rawValue) {
    if (_categories.isEmpty) return rawValue;
    final matchById = _categories
        .where((category) => category.categoryId == rawValue)
        .toList();
    if (matchById.isNotEmpty) {
      return matchById.first.categoryName;
    }

    final matchByName = _categories
        .where(
          (category) =>
              category.categoryName.toLowerCase() == rawValue.toLowerCase(),
        )
        .toList();
    if (matchByName.isNotEmpty) {
      return matchByName.first.categoryName;
    }
    return rawValue;
  }
}

class _NoApplicationCard extends StatelessWidget {
  const _NoApplicationCard({required this.onApplyTap});

  final VoidCallback onApplyTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Convert to Seller',
            style: AppTextStyle.inputBox.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Submit your business details for verification.',
            style: AppTextStyle.minimalTexts.copyWith(
              fontSize: 13,
              color: colorScheme.onSurface.withValues(alpha: 0.74),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onApplyTap,
              child: const Text('Request Seller Access'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.body,
    required this.icon,
    required this.iconColor,
  });

  final String title;
  final String body;
  final IconData icon;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyle.inputBox.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  body,
                  style: AppTextStyle.minimalTexts.copyWith(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.74),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ApplicationCard extends StatelessWidget {
  const _ApplicationCard({
    required this.application,
    required this.resolvedCategoryName,
  });

  final SellerApplicationEntity application;
  final String resolvedCategoryName;

  Color _statusColor(SellerApplicationStatus status) {
    switch (status) {
      case SellerApplicationStatus.approved:
        return AppColors.success;
      case SellerApplicationStatus.rejected:
        return AppColors.error;
      case SellerApplicationStatus.pending:
        return AppColors.warning;
    }
  }

  String _statusText(SellerApplicationStatus status) {
    switch (status) {
      case SellerApplicationStatus.approved:
        return 'Approved';
      case SellerApplicationStatus.rejected:
        return 'Rejected';
      case SellerApplicationStatus.pending:
        return 'Pending';
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(application.status);
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.12),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  application.businessName,
                  style: AppTextStyle.inputBox.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  _statusText(application.status),
                  style: AppTextStyle.inputBox.copyWith(
                    fontSize: 12,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Category', value: resolvedCategoryName),
          _InfoRow(label: 'Phone', value: application.businessPhone),
          _InfoRow(label: 'Address', value: application.businessAddress),
          if ((application.description ?? '').isNotEmpty)
            _InfoRow(label: 'Description', value: application.description!),
          if ((application.adminRemark ?? '').isNotEmpty)
            _InfoRow(label: 'Admin remark', value: application.adminRemark!),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 96,
            child: Text(
              '$label:',
              style: AppTextStyle.minimalTexts.copyWith(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.74),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyle.inputBox.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
