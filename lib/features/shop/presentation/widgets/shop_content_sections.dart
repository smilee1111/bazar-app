import 'package:bazar/app/theme/colors.dart';
import 'package:bazar/app/theme/textstyle.dart';
import 'package:bazar/core/api/api_endpoints.dart';
import 'package:bazar/features/shopDetail/domain/entities/shop_detail_entity.dart';
import 'package:bazar/features/shopPhoto/domain/entities/shop_photo_entity.dart';
import 'package:bazar/features/shopReview/domain/entities/shop_review_entity.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ShopDetailSection extends StatelessWidget {
  const ShopDetailSection({
    super.key,
    required this.detail,
    required this.canEdit,
    required this.onEdit,
  });

  final ShopDetailEntity? detail;
  final bool canEdit;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final links = <String>[
      detail?.link1 ?? '',
      detail?.link2 ?? '',
      detail?.link3 ?? '',
      detail?.link4 ?? '',
    ].where((link) => link.trim().isNotEmpty).toList();

    return _SectionCard(
      title: 'Shop Details',
      trailing: canEdit
          ? TextButton.icon(
              onPressed: onEdit,
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: const Text('Edit'),
            )
          : null,
      child: links.isEmpty
          ? Text(
              'No additional links available.',
              style: AppTextStyle.minimalTexts.copyWith(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.74),
              ),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(
                links.length,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Icon(
                        Icons.link_rounded,
                        size: 16,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          links[index],
                          style: AppTextStyle.inputBox.copyWith(
                            fontSize: 12,
                            color: colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

class ShopPhotosSection extends StatelessWidget {
  const ShopPhotosSection({
    super.key,
    required this.photos,
    required this.canEdit,
    required this.onAdd,
    required this.onUpdate,
    required this.onDelete,
  });

  final List<ShopPhotoEntity> photos;
  final bool canEdit;
  final VoidCallback onAdd;
  final void Function(ShopPhotoEntity photo) onUpdate;
  final void Function(ShopPhotoEntity photo) onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return _SectionCard(
      title: 'Photos',
      trailing: canEdit
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  onPressed: onAdd,
                  icon: const Icon(Icons.add_a_photo_outlined, size: 16),
                  label: const Text('Add'),
                ),
                if (photos.isNotEmpty)
                  TextButton.icon(
                    onPressed: () => _openPhotoManagerSheet(context),
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Edit'),
                  ),
              ],
            )
          : null,
      child: photos.isEmpty
          ? Text(
              'No photos uploaded yet.',
              style: AppTextStyle.minimalTexts.copyWith(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.74),
              ),
            )
          : SizedBox(
              height: 140,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: photos.length,
                separatorBuilder: (_, index) => const SizedBox(width: 10),
                itemBuilder: (_, index) {
                  final photo = photos[index];
                  final photoUrl = _resolvePhotoUrl(photo);
                  return Container(
                    width: 190,
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.onSurface.withValues(alpha: 0.14),
                      ),
                    ),
                    child: Stack(
                      children: [
                        Positioned.fill(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: photoUrl != null
                                ? Image.network(
                                    photoUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, error, stackTrace) =>
                                        _PhotoFallback(label: photo.photoName),
                                  )
                                : _PhotoFallback(label: photo.photoName),
                          ),
                        ),
                        if (canEdit)
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Row(
                              children: [
                                _IconBadge(
                                  icon: Icons.edit_outlined,
                                  onTap: () => onUpdate(photo),
                                ),
                                const SizedBox(width: 4),
                                _IconBadge(
                                  icon: Icons.delete_outline_rounded,
                                  onTap: () => onDelete(photo),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
    );
  }

  void _openPhotoManagerSheet(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    showModalBottomSheet<void>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Text(
              'Manage Photos',
              style: AppTextStyle.inputBox.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            ...photos.map(
              (photo) => ListTile(
                leading: const Icon(Icons.image_outlined),
                title: Text(
                  photo.photoName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyle.inputBox.copyWith(
                    fontSize: 12,
                    color: colorScheme.onSurface,
                  ),
                ),
                trailing: Wrap(
                  spacing: 6,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onUpdate(photo);
                      },
                      icon: const Icon(Icons.edit_outlined),
                      tooltip: 'Update',
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onDelete(photo);
                      },
                      icon: const Icon(Icons.delete_outline_rounded),
                      tooltip: 'Delete',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class ShopReviewsSection extends StatelessWidget {
  const ShopReviewsSection({
    super.key,
    required this.reviews,
    required this.onLike,
    required this.onDislike,
    this.canEditReview,
    this.onEditReview,
    this.onDeleteReview,
    this.isLiked,
    this.isDisliked,
    this.isReacting,
    this.canAddReview = true,
    this.onAddReview,
  });

  final List<ShopReviewEntity> reviews;
  final void Function(ShopReviewEntity review) onLike;
  final void Function(ShopReviewEntity review) onDislike;
  final bool Function(ShopReviewEntity review)? canEditReview;
  final void Function(ShopReviewEntity review)? onEditReview;
  final void Function(ShopReviewEntity review)? onDeleteReview;
  final bool Function(ShopReviewEntity review)? isLiked;
  final bool Function(ShopReviewEntity review)? isDisliked;
  final bool Function(ShopReviewEntity review)? isReacting;
  final bool canAddReview;
  final VoidCallback? onAddReview;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return _SectionCard(
      title: 'Reviews',
      trailing: canAddReview && onAddReview != null
          ? TextButton.icon(
              onPressed: onAddReview,
              icon: const Icon(Icons.rate_review_outlined, size: 16),
              label: const Text('Add'),
            )
          : null,
      child: reviews.isEmpty
          ? Text(
              'No reviews yet. Be the first to review.',
              style: AppTextStyle.minimalTexts.copyWith(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.74),
              ),
            )
          : Column(
              children: reviews
                  .map(
                    (review) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: _ReviewTile(
                        review: review,
                        canEdit: canEditReview?.call(review) ?? false,
                        onEdit: onEditReview == null
                            ? null
                            : () => onEditReview!(review),
                        onDelete: onDeleteReview == null
                            ? null
                            : () => onDeleteReview!(review),
                        isLiked: isLiked?.call(review) ?? false,
                        isDisliked: isDisliked?.call(review) ?? false,
                        isReacting: isReacting?.call(review) ?? false,
                        onLike: () => onLike(review),
                        onDislike: () => onDislike(review),
                      ),
                    ),
                  )
                  .toList(),
            ),
    );
  }
}

class _ReviewTile extends StatelessWidget {
  const _ReviewTile({
    required this.review,
    required this.onLike,
    required this.onDislike,
    required this.canEdit,
    required this.onEdit,
    required this.onDelete,
    required this.isLiked,
    required this.isDisliked,
    required this.isReacting,
  });

  final ShopReviewEntity review;
  final VoidCallback onLike;
  final VoidCallback onDislike;
  final bool canEdit;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool isLiked;
  final bool isDisliked;
  final bool isReacting;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final reviewerName = _resolveReviewerName(review);
    final reviewerRole = _resolveReviewerRole(review);
    final reviewedDateText = _resolveReviewedDateText(review);
    final reviewerPhotoUrl = _resolveReviewerPhotoUrl(review);

    final subtitleParts = <String>[];
    if (reviewerRole != null && reviewerRole.isNotEmpty) {
      subtitleParts.add(reviewerRole);
    }
    if (reviewedDateText != null && reviewedDateText.isNotEmpty) {
      subtitleParts.add(reviewedDateText);
    }
    final reviewerSubtitle = subtitleParts.join(' • ');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.primary.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.14),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ReviewerAvatar(
                name: reviewerName ?? 'Reviewer',
                photoUrl: reviewerPhotoUrl,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: reviewerName == null
                    ? const SizedBox.shrink()
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reviewerName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyle.inputBox.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: colorScheme.onSurface,
                            ),
                          ),
                          if (reviewerSubtitle.isNotEmpty)
                            Text(
                              reviewerSubtitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: AppTextStyle.minimalTexts.copyWith(
                                fontSize: 11,
                                color: colorScheme.onSurface.withValues(
                                  alpha: 0.74,
                                ),
                              ),
                            ),
                        ],
                      ),
              ),
              _ReviewStars(stars: review.starNum),
              if (canEdit && onEdit != null) ...[
                const SizedBox(width: 6),
                IconButton(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  tooltip: 'Edit review',
                ),
              ],
              if (canEdit && onDelete != null)
                IconButton(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline_rounded, size: 18),
                  tooltip: 'Delete review',
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            review.reviewName,
            style: AppTextStyle.inputBox.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _ReactButton(
                icon: isLiked
                    ? Icons.thumb_up_alt_rounded
                    : Icons.thumb_up_alt_outlined,
                label: '${review.likesCount}',
                onTap: isReacting ? null : onLike,
                isActive: isLiked,
                activeColor: AppColors.primary,
              ),
              const SizedBox(width: 6),
              _ReactButton(
                icon: isDisliked
                    ? Icons.thumb_down_alt_rounded
                    : Icons.thumb_down_alt_outlined,
                label: '${review.dislikeCount}',
                onTap: isReacting ? null : onDislike,
                isActive: isDisliked,
                activeColor: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReviewerAvatar extends StatelessWidget {
  const _ReviewerAvatar({required this.name, required this.photoUrl});

  final String name;
  final String? photoUrl;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final trimmed = name.trim();
    final letter = trimmed.isEmpty
        ? 'R'
        : trimmed.substring(0, 1).toUpperCase();
    return CircleAvatar(
      radius: 18,
      backgroundColor: colorScheme.primary.withValues(alpha: 0.30),
      foregroundImage: (photoUrl != null && photoUrl!.isNotEmpty)
          ? NetworkImage(photoUrl!)
          : null,
      child: Text(
        letter,
        style: AppTextStyle.inputBox.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _ReviewStars extends StatelessWidget {
  const _ReviewStars({required this.stars});
  final int stars;

  @override
  Widget build(BuildContext context) {
    final safeStars = stars.clamp(1, 5);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        children: List.generate(5, (index) {
          final filled = index < safeStars;
          return Icon(
            filled ? Icons.star_rounded : Icons.star_border_rounded,
            size: 13,
            color: AppColors.warning,
          );
        }),
      ),
    );
  }
}

class _ReactButton extends StatelessWidget {
  const _ReactButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isActive,
    required this.activeColor,
  });

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
  final bool isActive;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: isActive
              ? activeColor.withValues(alpha: 0.15)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive
                ? activeColor
                : colorScheme.onSurface.withValues(alpha: 0.14),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14,
              color: isActive ? activeColor : colorScheme.primary,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyle.inputBox.copyWith(
                fontSize: 11,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child, this.trailing});

  final String title;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                  title,
                  style: AppTextStyle.inputBox.copyWith(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _PhotoFallback extends StatelessWidget {
  const _PhotoFallback({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      color: colorScheme.primary.withValues(alpha: 0.10),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(10),
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: AppTextStyle.inputBox.copyWith(
          fontSize: 12,
          color: colorScheme.onSurface,
        ),
      ),
    );
  }
}

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.45),
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(5),
        child: Icon(icon, size: 16, color: Colors.white),
      ),
    );
  }
}

String? _resolvePhotoUrl(ShopPhotoEntity photo) {
  final raw = (photo.photoUrl ?? '').trim().isNotEmpty
      ? photo.photoUrl!.trim()
      : photo.photoName.trim();
  if (raw.isEmpty) return null;
  if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
  if (raw.startsWith('/')) return '${ApiEndpoints.serverUrl}$raw';
  if (raw.startsWith('uploads/')) return '${ApiEndpoints.serverUrl}/$raw';
  return null;
}

String? _resolveReviewerName(ShopReviewEntity review) {
  final named = review.reviewedByName?.trim() ?? '';
  if (named.isNotEmpty) return named;
  final raw = review.reviewedBy?.trim() ?? '';
  if (raw.isEmpty) return 'Reviewer';
  if (raw.length <= 20 || raw.contains('@')) return raw;
  return 'Reviewer';
}

String? _resolveReviewerRole(ShopReviewEntity review) {
  final role = review.reviewedByRole?.trim() ?? '';
  if (role.isEmpty) return null;
  return role;
}

String? _resolveReviewedDateText(ShopReviewEntity review) {
  final reviewedAt = review.reviewedAt;
  if (reviewedAt == null) return null;
  return DateFormat('d MMM yyyy').format(reviewedAt.toLocal());
}

String? _resolveReviewerPhotoUrl(ShopReviewEntity review) {
  final raw = review.reviewedByProfilePic?.trim() ?? '';
  if (raw.isEmpty) return null;
  if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
  if (raw.startsWith('/')) return '${ApiEndpoints.serverUrl}$raw';
  if (raw.startsWith('uploads/')) return '${ApiEndpoints.serverUrl}/$raw';
  return null;
}
