import 'package:bazar/app/theme/colors.dart';
import 'package:bazar/app/theme/textstyle.dart';
import 'package:bazar/features/category/domain/entities/category_entity.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Data models
// ---------------------------------------------------------------------------

enum PriceFilter { any, budget, mid, premium }

class ShopFilters {
  final String? categoryName;
  final String locationQuery;
  final double minRating;
  final PriceFilter priceFilter;

  const ShopFilters({
    this.categoryName,
    this.locationQuery = '',
    this.minRating = 0,
    this.priceFilter = PriceFilter.any,
  });

  int get activeCount {
    var count = 0;
    if ((categoryName ?? '').trim().isNotEmpty) count++;
    if (locationQuery.trim().isNotEmpty) count++;
    if (minRating > 0) count++;
    if (priceFilter != PriceFilter.any) count++;
    return count;
  }

  ShopFilters copyWith({
    String? categoryName,
    String? locationQuery,
    double? minRating,
    PriceFilter? priceFilter,
    bool clearCategory = false,
  }) {
    return ShopFilters(
      categoryName: clearCategory ? null : (categoryName ?? this.categoryName),
      locationQuery: locationQuery ?? this.locationQuery,
      minRating: minRating ?? this.minRating,
      priceFilter: priceFilter ?? this.priceFilter,
    );
  }
}

// ---------------------------------------------------------------------------
// Filter bottom sheet (stateful + self-contained)
// ---------------------------------------------------------------------------

class ShopFilterSheet extends StatefulWidget {
  const ShopFilterSheet({
    super.key,
    required this.initialFilters,
    required this.categories,
  });

  final ShopFilters initialFilters;
  final List<CategoryEntity> categories;

  /// Shows the sheet and returns the applied [ShopFilters], or `null` if the
  /// user dismissed without changes.
  static Future<ShopFilters?> show(
    BuildContext context, {
    required ShopFilters initialFilters,
    required List<CategoryEntity> categories,
  }) {
    return showModalBottomSheet<ShopFilters>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => ShopFilterSheet(
        initialFilters: initialFilters,
        categories: categories,
      ),
    );
  }

  @override
  State<ShopFilterSheet> createState() => _ShopFilterSheetState();
}

class _ShopFilterSheetState extends State<ShopFilterSheet> {
  late String? _selectedCategory;
  late final TextEditingController _locationCtrl;
  late int _selectedMinRating;
  late PriceFilter _selectedPrice;

  @override
  void initState() {
    super.initState();
    _selectedCategory = widget.initialFilters.categoryName;
    _locationCtrl = TextEditingController(
      text: widget.initialFilters.locationQuery,
    );
    _selectedMinRating = widget.initialFilters.minRating.round();
    _selectedPrice = widget.initialFilters.priceFilter;
  }

  @override
  void dispose() {
    _locationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 46,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.onSurface.withValues(alpha: 0.28),
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Filter Shops',
              style: AppTextStyle.inputBox.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Refine by category, location, price and rating.',
              style: AppTextStyle.minimalTexts.copyWith(
                fontSize: 12,
                color: colorScheme.onSurface.withValues(alpha: 0.74),
              ),
            ),
            const SizedBox(height: 14),

            // Category
            Text(
              'Category',
              style: AppTextStyle.inputBox.copyWith(
                fontSize: 12,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String?>(
              value: _selectedCategory,
              style: AppTextStyle.inputBox.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.category_outlined),
              ),
              items: [
                DropdownMenuItem<String?>(
                  value: null,
                  child: Text(
                    'Any category',
                    style: AppTextStyle.inputBox.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
                ...widget.categories.map(
                  (item) => DropdownMenuItem<String?>(
                    value: item.categoryName,
                    child: Text(
                      item.categoryName,
                      style: AppTextStyle.inputBox.copyWith(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ],
              onChanged: (value) => setState(() => _selectedCategory = value),
            ),
            const SizedBox(height: 12),

            // Location
            Text(
              'Location',
              style: AppTextStyle.inputBox.copyWith(
                fontSize: 12,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _locationCtrl,
              decoration: const InputDecoration(
                hintText: 'City, street, area',
                prefixIcon: Icon(Icons.location_on_outlined),
              ),
            ),
            const SizedBox(height: 12),

            // Price range
            Text(
              'Price Range',
              style: AppTextStyle.inputBox.copyWith(
                fontSize: 12,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<PriceFilter>(
              value: _selectedPrice,
              style: AppTextStyle.inputBox.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.sell_outlined),
              ),
              items: [
                DropdownMenuItem(
                  value: PriceFilter.any,
                  child: Text(
                    'Any',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ),
                DropdownMenuItem(
                  value: PriceFilter.budget,
                  child: Text(
                    'Budget',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ),
                DropdownMenuItem(
                  value: PriceFilter.mid,
                  child: Text(
                    'Mid',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ),
                DropdownMenuItem(
                  value: PriceFilter.premium,
                  child: Text(
                    'Premium',
                    style: TextStyle(color: colorScheme.onSurface),
                  ),
                ),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _selectedPrice = value);
              },
            ),
            const SizedBox(height: 12),

            // Min rating
            Text(
              'Minimum Rating',
              style: AppTextStyle.inputBox.copyWith(
                fontSize: 12,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 6),
            RatingStarSelector(
              selectedMinRating: _selectedMinRating,
              onChanged: (value) => setState(() => _selectedMinRating = value),
            ),
            const SizedBox(height: 20),

            // Actions
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        Navigator.pop(context, const ShopFilters()),
                    child: const Text('Reset'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(
                      context,
                      ShopFilters(
                        categoryName: _selectedCategory,
                        locationQuery: _locationCtrl.text.trim(),
                        minRating: _selectedMinRating.toDouble(),
                        priceFilter: _selectedPrice,
                      ),
                    ),
                    child: const Text('Apply'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Reusable rating selector widget
// ---------------------------------------------------------------------------

class RatingStarSelector extends StatelessWidget {
  const RatingStarSelector({
    super.key,
    required this.selectedMinRating,
    required this.onChanged,
  });

  final int selectedMinRating;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _RatingChip(
          label: 'Any',
          active: selectedMinRating == 0,
          onTap: () => onChanged(0),
        ),
        ...List.generate(5, (index) {
          final rating = index + 1;
          return _RatingChip(
            label: '$rating+',
            active: selectedMinRating == rating,
            onTap: () => onChanged(rating),
            showStar: true,
          );
        }),
      ],
    );
  }
}

class _RatingChip extends StatelessWidget {
  const _RatingChip({
    required this.label,
    required this.active,
    required this.onTap,
    this.showStar = false,
  });

  final String label;
  final bool active;
  final VoidCallback onTap;
  final bool showStar;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? AppColors.warning.withValues(alpha: 0.16)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: active
                ? AppColors.warning
                : colorScheme.onSurface.withValues(alpha: 0.14),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showStar) ...[
              const Icon(
                Icons.star_rounded,
                size: 14,
                color: AppColors.warning,
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: AppTextStyle.inputBox.copyWith(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
