import 'package:bazar/app/theme/colors.dart';
import 'package:flutter/material.dart';

class ShopSkeletonCard extends StatelessWidget {
  const ShopSkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 110,
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
          _SkeletonLine(
            widthFactor: 0.55,
            height: 14,
            color: colorScheme.primary.withValues(alpha: 0.14),
          ),
          const SizedBox(height: 10),
          _SkeletonLine(
            widthFactor: 0.95,
            height: 11,
            color: colorScheme.primary.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 6),
          _SkeletonLine(
            widthFactor: 0.8,
            height: 11,
            color: colorScheme.primary.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 12),
          _SkeletonLine(
            widthFactor: 0.4,
            height: 11,
            color: colorScheme.primary.withValues(alpha: 0.12),
          ),
        ],
      ),
    );
  }
}

class _SkeletonLine extends StatelessWidget {
  const _SkeletonLine({
    required this.widthFactor,
    required this.height,
    required this.color,
  });

  final double widthFactor;
  final double height;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }
}
