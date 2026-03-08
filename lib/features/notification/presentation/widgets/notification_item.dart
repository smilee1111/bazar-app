import 'package:bazar/app/theme/colors.dart';
import 'package:bazar/app/theme/textstyle.dart';
import 'package:bazar/features/notification/domain/entities/notification_entity.dart';
import 'package:bazar/features/notification/presentation/utils/notification_ui_utils.dart';
import 'package:flutter/material.dart';

class NotificationItem extends StatelessWidget {
  final NotificationEntity notification;
  final bool processing;
  final VoidCallback? onTap;
  final VoidCallback? onMarkAsRead;
  final VoidCallback? onDelete;

  const NotificationItem({
    super.key,
    required this.notification,
    this.processing = false,
    this.onTap,
    this.onMarkAsRead,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final iconColor = NotificationUiUtils.iconColorForType(notification.type);
    final tileColor = notification.isRead
        ? colorScheme.surface
        : colorScheme.primary.withValues(alpha: 0.10);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: tileColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: notification.isRead
              ? colorScheme.onSurface.withValues(alpha: 0.14)
              : colorScheme.primary.withValues(alpha: 0.35),
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: processing ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  NotificationUiUtils.iconForType(notification.type),
                  color: iconColor,
                  size: 19,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      notification.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.inputBox.copyWith(
                        fontSize: 13,
                        fontWeight: notification.isRead
                            ? FontWeight.w600
                            : FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification.message,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.minimalTexts.copyWith(
                        fontSize: 12,
                        color: colorScheme.onSurface.withValues(alpha: 0.76),
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Text(
                          NotificationUiUtils.relativeTime(
                            notification.createdAt,
                          ),
                          style: AppTextStyle.minimalTexts.copyWith(
                            fontSize: 11,
                            color: colorScheme.onSurface.withValues(
                              alpha: 0.68,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.warning,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  if (processing)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: Padding(
                        padding: EdgeInsets.all(2),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                  else ...[
                    if (!notification.isRead)
                      IconButton(
                        onPressed: onMarkAsRead,
                        tooltip: 'Mark as read',
                        icon: const Icon(
                          Icons.done_rounded,
                          size: 18,
                          color: AppColors.info,
                        ),
                      ),
                    IconButton(
                      onPressed: onDelete,
                      tooltip: 'Delete',
                      icon: const Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: AppColors.error,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
