import 'package:bazar/app/theme/colors.dart';
import 'package:bazar/app/theme/textstyle.dart';
import 'package:bazar/features/shop/domain/entities/shop_entity.dart';
import 'package:bazar/features/shop/presentation/pages/shop_form_page.dart';
import 'package:bazar/features/shop/presentation/pages/shop_public_detail_page.dart';
import 'package:bazar/features/shop/presentation/view_model/shop_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SellerShopPage extends ConsumerStatefulWidget {
  const SellerShopPage({super.key});

  @override
  ConsumerState<SellerShopPage> createState() => _SellerShopPageState();
}

class _SellerShopPageState extends ConsumerState<SellerShopPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(shopViewModelProvider.notifier).loadSellerShops();
    });
  }

  Future<void> _openForm(ShopEntity shop) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ShopFormPage(initialShop: shop)),
    );
    if (!mounted) return;
    await ref
        .read(shopViewModelProvider.notifier)
        .loadSellerShops(forceRefresh: true);
  }

  Future<void> _openContentManager(ShopEntity shop) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ShopPublicDetailPage(shop: shop, allowOwnerEdit: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(shopViewModelProvider);
    final myShop = state.myShop;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref
              .read(shopViewModelProvider.notifier)
              .loadSellerShops(forceRefresh: true);
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Manage Shop',
                    style: AppTextStyle.inputBox.copyWith(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Update and maintain your seller shop details.',
              style: AppTextStyle.minimalTexts.copyWith(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.74),
              ),
            ),
            const SizedBox(height: 16),
            if (state.isLoadingSeller && !state.hasLoadedSeller)
              const Center(child: CircularProgressIndicator())
            else ...[
              if ((state.errorMessage ?? '').isNotEmpty) ...[
                _InfoBanner(message: state.errorMessage!, isError: true),
                const SizedBox(height: 12),
              ],
              if (myShop != null) ...[
                _SectionTitle(title: 'My Shop'),
                _ShopCard(
                  shop: myShop,
                  onEdit: () => _openForm(myShop),
                  onManageContent: () => _openContentManager(myShop),
                ),
                const SizedBox(height: 14),
              ],
              if (myShop == null) ...[
                _SectionTitle(title: 'My Shop'),
                _InfoBanner(
                  message:
                      'No shop found. Shop creation is not available from this screen.',
                  isError: false,
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: AppTextStyle.inputBox.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.message, required this.isError});
  final String message;
  final bool isError;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isError ? AppColors.error : AppColors.info).withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isError ? AppColors.error : AppColors.info,
          width: 0.8,
        ),
      ),
      child: Text(
        message,
        style: AppTextStyle.inputBox.copyWith(
          fontSize: 13,
          color: isError ? AppColors.error : AppColors.info,
        ),
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  const _ShopCard({
    required this.shop,
    required this.onEdit,
    required this.onManageContent,
  });

  final ShopEntity shop;
  final VoidCallback onEdit;
  final VoidCallback onManageContent;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final categoryText = shop.categoryNames.isEmpty
        ? 'Uncategorized'
        : shop.categoryNames.join(', ');
    final priceText = (shop.priceRange ?? '').trim().isEmpty
        ? 'Not specified'
        : shop.priceRange!.trim();
    final descText = (shop.description ?? '').trim();
    final slugText = (shop.slug ?? '').trim().isEmpty
        ? '--'
        : shop.slug!.trim();
    final secondaryPhone = (shop.contactNumber ?? '').trim();
    final email = (shop.email ?? '').trim();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  shop.shopName,
                  style: AppTextStyle.inputBox.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              IconButton(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit shop',
              ),
              IconButton(
                onPressed: onManageContent,
                icon: const Icon(Icons.photo_library_outlined),
                tooltip: 'Manage details/photos/reviews',
              ),
            ],
          ),
          const SizedBox(height: 10),
          _MiniRow(icon: Icons.location_on_outlined, value: shop.shopAddress),
          _MiniRow(icon: Icons.phone_outlined, value: shop.shopContact),
          if (secondaryPhone.isNotEmpty)
            _MiniRow(icon: Icons.call_outlined, value: secondaryPhone),
          if (email.isNotEmpty)
            _MiniRow(icon: Icons.mail_outline_rounded, value: email),
          const SizedBox(height: 6),
          _MetaGrid(
            values: [
              _MetaValue(label: 'Category', value: categoryText),
              _MetaValue(label: 'Price Range', value: priceText),
              _MetaValue(label: 'Slug', value: slugText),
              _MetaValue(label: 'Status', value: 'Active'),
            ],
          ),
          if (descText.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                descText,
                style: AppTextStyle.minimalTexts.copyWith(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.76),
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: onEdit,
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Edit'),
              ),
              OutlinedButton.icon(
                onPressed: onManageContent,
                icon: const Icon(Icons.info_outline_rounded, size: 16),
                label: const Text('View Details'),
              ),
              OutlinedButton.icon(
                onPressed: onManageContent,
                icon: const Icon(Icons.photo_library_outlined, size: 16),
                label: const Text('View Photos'),
              ),
              OutlinedButton.icon(
                onPressed: onManageContent,
                icon: const Icon(Icons.rate_review_outlined, size: 16),
                label: const Text('View Reviews'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniRow extends StatelessWidget {
  const _MiniRow({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 16, color: colorScheme.primary),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              value,
              style: AppTextStyle.inputBox.copyWith(
                fontSize: 12,
                color: colorScheme.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaValue {
  final String label;
  final String value;

  const _MetaValue({required this.label, required this.value});
}

class _MetaGrid extends StatelessWidget {
  const _MetaGrid({required this.values});

  final List<_MetaValue> values;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: values
          .map(
            (item) => Container(
              constraints: const BoxConstraints(minWidth: 145, maxWidth: 220),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colorScheme.onSurface.withValues(alpha: 0.14),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.label,
                    style: AppTextStyle.minimalTexts.copyWith(
                      fontSize: 10,
                      color: colorScheme.onSurface.withValues(alpha: 0.74),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.value,
                    style: AppTextStyle.inputBox.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
