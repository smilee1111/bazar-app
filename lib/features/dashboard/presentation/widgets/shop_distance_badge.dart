import 'package:bazar/app/theme/colors.dart';
import 'package:bazar/app/theme/textstyle.dart';
import 'package:flutter/material.dart';

/// Widget to display distance from user's location to a shop
class ShopDistanceBadge extends StatelessWidget {
  const ShopDistanceBadge({super.key, required this.distanceInKm});

  final double? distanceInKm;

  String _formatDistance(double km) {
    if (km < 1) {
      return '${(km * 1000).toStringAsFixed(0)} m';
    } else if (km < 10) {
      return '${km.toStringAsFixed(1)} km';
    } else {
      return '${km.toStringAsFixed(0)} km';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    if (distanceInKm == null) {
      return const SizedBox.shrink();
    }

    final toneColor = colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: toneColor.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: toneColor.withValues(alpha: 0.48), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.near_me_rounded, size: 12, color: toneColor),
          const SizedBox(width: 4),
          Text(
            _formatDistance(distanceInKm!),
            style: AppTextStyle.inputBox.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: toneColor,
            ),
          ),
        ],
      ),
    );
  }
}
