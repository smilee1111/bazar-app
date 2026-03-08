import 'package:bazar/app/theme/colors.dart';
import 'package:bazar/app/theme/textstyle.dart';
import 'package:bazar/features/dashboard/presentation/view_model/shop_card_preview_provider.dart';
import 'package:bazar/features/dashboard/presentation/widgets/shop_distance_badge.dart';
import 'package:bazar/features/shop/domain/entities/shop_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PublicShopCard extends ConsumerWidget {
  const PublicShopCard({
    super.key,
    required this.shop,
    required this.onTap,
    required this.onToggleSave,
    required this.onToggleFavourite,
    required this.isSaved,
    required this.isFavourite,
    required this.isReviewed,
    this.isSaveBusy = false,
    this.isFavouriteBusy = false,
    this.distanceInKm,
  });

  final ShopEntity shop;
  final VoidCallback onTap;
  final VoidCallback onToggleSave;
  final VoidCallback onToggleFavourite;
  final bool isSaved;
  final bool isFavourite;
  final bool isReviewed;
  final bool isSaveBusy;
  final bool isFavouriteBusy;
  final double? distanceInKm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final previewState = ref.watch(shopCardPreviewProvider(shop));
    final preview = previewState.maybeWhen(
      data: (value) => value,
      orElse: () => ShopCardPreview.empty,
    );

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(16),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: colorScheme.onSurface.withValues(alpha: 0.14),
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.primary.withValues(alpha: 0.08),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
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
                  _ActionIcon(
                    icon: isFavourite ? Icons.favorite : Icons.favorite_border,
                    activeColor: AppColors.error,
                    isActive: isFavourite,
                    isBusy: isFavouriteBusy,
                    onPressed: onToggleFavourite,
                    tooltip: isFavourite
                        ? 'Remove from favourites'
                        : 'Add to favourites',
                  ),
                  const SizedBox(width: 4),
                  _ActionIcon(
                    icon: isSaved ? Icons.bookmark : Icons.bookmark_border,
                    activeColor: AppColors.primary,
                    isActive: isSaved,
                    isBusy: isSaveBusy,
                    onPressed: onToggleSave,
                    tooltip: isSaved ? 'Remove from saved' : 'Save shop',
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: colorScheme.onSurface.withValues(alpha: 0.65),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _RatingBadge(
                    average: preview.averageRating,
                    reviewCount: preview.reviewCount,
                  ),
                  if (distanceInKm != null) ...[
                    const SizedBox(width: 8),
                    ShopDistanceBadge(distanceInKm: distanceInKm),
                  ],
                  if ((preview.priceRange ?? '').trim().isNotEmpty) ...[
                    const SizedBox(width: 8),
                    _MetaTag(label: preview.priceRange!),
                  ],
                  if (isReviewed) ...[
                    const SizedBox(width: 8),
                    const _ReviewedTag(),
                  ],
                ],
              ),
              if (preview.categoryNames.isNotEmpty) ...[
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: preview.categoryNames
                      .take(3)
                      .map((name) => _MetaTag(label: name))
                      .toList(),
                ),
              ],
              const SizedBox(height: 6),
              Text(
                shop.shopAddress,
                style: AppTextStyle.minimalTexts.copyWith(
                  fontSize: 12,
                  color: colorScheme.onSurface.withValues(alpha: 0.78),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              if ((shop.description ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  shop.description!.trim(),
                  style: AppTextStyle.minimalTexts.copyWith(
                    fontSize: 11,
                    color: colorScheme.onSurface.withValues(alpha: 0.74),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              if ((preview.detailSnippet ?? '').trim().isNotEmpty) ...[
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(
                      Icons.link_rounded,
                      size: 14,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        preview.detailSnippet!,
                        style: AppTextStyle.inputBox.copyWith(
                          fontSize: 11,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 8),
              _PreviewPhotos(photoUrls: preview.photoUrls),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.phone_outlined,
                    size: 16,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      shop.shopContact,
                      style: AppTextStyle.inputBox.copyWith(
                        fontSize: 12,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PreviewPhotos extends StatelessWidget {
  const _PreviewPhotos({required this.photoUrls});

  final List<String> photoUrls;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (photoUrls.isEmpty) {
      return Container(
        height: 74,
        decoration: BoxDecoration(
          color: colorScheme.primary.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.14),
          ),
        ),
        alignment: Alignment.center,
        child: Text(
          'No photos yet',
          style: AppTextStyle.minimalTexts.copyWith(
            fontSize: 11,
            color: colorScheme.onSurface.withValues(alpha: 0.75),
          ),
        ),
      );
    }

    return SizedBox(
      height: 74,
      child: Row(
        children: List.generate(3, (index) {
          final hasImage = index < photoUrls.length;
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index == 2 ? 0 : 6),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: colorScheme.onSurface.withValues(alpha: 0.14),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: hasImage
                  ? Image.network(
                      photoUrls[index],
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const _PhotoPlaceholder(),
                    )
                  : const _PhotoPlaceholder(),
            ),
          );
        }),
      ),
    );
  }
}

class _PhotoPlaceholder extends StatelessWidget {
  const _PhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      color: colorScheme.primary.withValues(alpha: 0.10),
      alignment: Alignment.center,
      child: Icon(Icons.photo_outlined, size: 18, color: colorScheme.primary),
    );
  }
}

class _RatingBadge extends StatelessWidget {
  const _RatingBadge({required this.average, required this.reviewCount});

  final double average;
  final int reviewCount;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.28)),
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
          const SizedBox(width: 4),
          Text(
            reviewCount == 0
                ? 'No ratings'
                : '${average.toStringAsFixed(1)} ($reviewCount)',
            style: AppTextStyle.inputBox.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: colorScheme.brightness == Brightness.dark
                  ? const Color(0xFFFFD487)
                  : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetaTag extends StatelessWidget {
  const _MetaTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.14),
        ),
      ),
      child: Text(
        label,
        style: AppTextStyle.inputBox.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _ActionIcon extends StatelessWidget {
  const _ActionIcon({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
    required this.activeColor,
    required this.isActive,
    required this.isBusy,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String tooltip;
  final Color activeColor;
  final bool isActive;
  final bool isBusy;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      width: 28,
      height: 28,
      child: isBusy
          ? const Padding(
              padding: EdgeInsets.all(6),
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : IconButton(
              onPressed: onPressed,
              tooltip: tooltip,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
              icon: Icon(
                icon,
                size: 18,
                color: isActive
                    ? activeColor
                    : colorScheme.onSurface.withValues(alpha: 0.62),
              ),
            ),
    );
  }
}

class _ReviewedTag extends StatelessWidget {
  const _ReviewedTag();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.35)),
      ),
      child: Text(
        'You reviewed this',
        style: AppTextStyle.inputBox.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: colorScheme.brightness == Brightness.dark
              ? const Color(0xFFAFC0E0)
              : AppColors.info,
        ),
      ),
    );
  }
}
