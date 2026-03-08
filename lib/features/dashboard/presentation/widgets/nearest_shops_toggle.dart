import 'package:bazar/app/theme/colors.dart';
import 'package:bazar/app/theme/textstyle.dart';
import 'package:flutter/material.dart';

/// Widget for toggling the "Show nearest shops only" filter
class NearestShopsToggle extends StatelessWidget {
  const NearestShopsToggle({
    super.key,
    required this.isEnabled,
    required this.onToggle,
    this.isLoading = false,
    this.categorySelected = true,
  });

  final bool isEnabled;
  final ValueChanged<bool> onToggle;
  final bool isLoading;
  final bool categorySelected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDisabled = !categorySelected;
    final baseLabelColor = colorScheme.onSurface;
    final mutedLabelColor = colorScheme.onSurface.withValues(alpha: 0.72);
    final disabledLabelColor = colorScheme.onSurface.withValues(alpha: 0.45);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled || isLoading ? null : () => onToggle(!isEnabled),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isEnabled && !isDisabled
                ? colorScheme.primary.withValues(alpha: 0.14)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isEnabled && !isDisabled
                  ? colorScheme.primary.withValues(alpha: 0.45)
                  : colorScheme.onSurface.withValues(alpha: 0.12),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                isLoading
                    ? Icons.location_searching_rounded
                    : Icons.location_on_outlined,
                color: isDisabled
                    ? disabledLabelColor
                    : (isEnabled ? colorScheme.primary : mutedLabelColor),
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Show nearest shops only',
                      style: AppTextStyle.inputBox.copyWith(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: isDisabled ? disabledLabelColor : baseLabelColor,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isDisabled
                          ? 'Select a category first'
                          : (isLoading
                                ? 'Getting your location...'
                                : 'Filter shops near you'),
                      style: AppTextStyle.minimalTexts.copyWith(
                        fontSize: 11,
                        color: isDisabled
                            ? disabledLabelColor
                            : mutedLabelColor,
                      ),
                    ),
                  ],
                ),
              ),
              if (isLoading)
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation(colorScheme.primary),
                  ),
                )
              else
                Switch(
                  value: isEnabled && !isDisabled,
                  onChanged: isDisabled ? null : onToggle,
                  activeColor: colorScheme.primary,
                  inactiveThumbColor: colorScheme.onSurface.withValues(
                    alpha: 0.65,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
