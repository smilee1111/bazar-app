import 'package:bazar/app/theme/colors.dart';
import 'package:bazar/app/theme/textstyle.dart';
import 'package:bazar/core/utils/snackbar_utils.dart';
import 'package:bazar/features/notification/presentation/pages/notification_list_page.dart';
import 'package:bazar/features/notification/presentation/utils/notification_navigation.dart';
import 'package:bazar/features/notification/presentation/view_model/notification_view_model.dart';
import 'package:bazar/features/notification/presentation/widgets/notification_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationBell extends ConsumerStatefulWidget {
  const NotificationBell({super.key});

  @override
  ConsumerState<NotificationBell> createState() => _NotificationBellState();
}

class _NotificationBellState extends ConsumerState<NotificationBell> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  @override
  void dispose() {
    _removeOverlay(notify: false);
    super.dispose();
  }

  Future<void> _toggleOverlay() async {
    if (_overlayEntry != null) {
      _removeOverlay();
      return;
    }
    HapticFeedback.selectionClick();
    await ref
        .read(notificationViewModelProvider.notifier)
        .loadUnreadCount(forceRefresh: true);
    await ref
        .read(notificationViewModelProvider.notifier)
        .loadNotifications(forceRefresh: true);
    if (!mounted) return;
    _showOverlay();
  }

  void _showOverlay() {
    _overlayEntry = OverlayEntry(
      builder: (overlayContext) {
        final width = MediaQuery.of(overlayContext).size.width;
        final cardWidth = width < 420 ? width - 24 : 390.0;

        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeOverlay,
                child: const SizedBox.expand(),
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomRight,
              followerAnchor: Alignment.topRight,
              offset: const Offset(0, 10),
              child: Material(
                color: Colors.transparent,
                child: Consumer(
                  builder: (context, ref, _) {
                    final colorScheme = Theme.of(context).colorScheme;
                    final state = ref.watch(notificationViewModelProvider);
                    final recent = ref
                        .read(notificationViewModelProvider.notifier)
                        .recentNotifications;

                    return Container(
                      width: cardWidth,
                      constraints: const BoxConstraints(maxHeight: 520),
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 8),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: colorScheme.onSurface.withValues(alpha: 0.14),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: colorScheme.primary.withValues(alpha: 0.14),
                            blurRadius: 24,
                            offset: Offset(0, 12),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(6, 0, 4, 6),
                            child: Row(
                              children: [
                                Text(
                                  'Notifications',
                                  style: AppTextStyle.inputBox.copyWith(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.onSurface,
                                  ),
                                ),
                                const Spacer(),
                                if (state.unreadCount > 0)
                                  Text(
                                    '${state.unreadCount} new',
                                    style: AppTextStyle.minimalTexts.copyWith(
                                      fontSize: 11,
                                      color: AppColors.info,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                TextButton(
                                  onPressed: state.isMarkingAllRead
                                      ? null
                                      : () async {
                                          final ok = await ref
                                              .read(
                                                notificationViewModelProvider
                                                    .notifier,
                                              )
                                              .markAllAsRead();
                                          if (!context.mounted) return;
                                          if (!ok) {
                                            final msg = ref
                                                .read(
                                                  notificationViewModelProvider,
                                                )
                                                .errorMessage;
                                            if ((msg ?? '').isNotEmpty) {
                                              SnackbarUtils.showError(
                                                context,
                                                msg!,
                                              );
                                            }
                                          }
                                        },
                                  child: state.isMarkingAllRead
                                      ? const SizedBox(
                                          width: 12,
                                          height: 12,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text('Read all'),
                                ),
                              ],
                            ),
                          ),
                          if (recent.isEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 22),
                              child: Text(
                                'No notifications yet',
                                style: AppTextStyle.minimalTexts.copyWith(
                                  fontSize: 12,
                                  color: colorScheme.onSurface.withValues(
                                    alpha: 0.72,
                                  ),
                                ),
                              ),
                            )
                          else
                            Flexible(
                              child: ListView.separated(
                                shrinkWrap: true,
                                padding: const EdgeInsets.fromLTRB(2, 0, 2, 2),
                                itemCount: recent.length,
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 7),
                                itemBuilder: (_, index) {
                                  final item = recent[index];
                                  return NotificationItem(
                                    notification: item,
                                    processing: state.processingIds.contains(
                                      item.id,
                                    ),
                                    onTap: () async {
                                      _removeOverlay();
                                      await handleNotificationTap(
                                        context: context,
                                        ref: ref,
                                        notification: item,
                                      );
                                    },
                                    onMarkAsRead: item.isRead
                                        ? null
                                        : () {
                                            ref
                                                .read(
                                                  notificationViewModelProvider
                                                      .notifier,
                                                )
                                                .markAsRead(item.id);
                                          },
                                    onDelete: () {
                                      ref
                                          .read(
                                            notificationViewModelProvider
                                                .notifier,
                                          )
                                          .deleteNotification(item.id);
                                    },
                                  );
                                },
                              ),
                            ),
                          const SizedBox(height: 4),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () {
                                _removeOverlay();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        const NotificationListPage(),
                                  ),
                                );
                              },
                              child: const Text('View all'),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context, rootOverlay: true).insert(_overlayEntry!);
    setState(() {});
  }

  void _removeOverlay({bool notify = true}) {
    _overlayEntry?.remove();
    _overlayEntry = null;
    if (notify && mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final unreadCount = ref.watch(
      notificationViewModelProvider.select((value) => value.unreadCount),
    );
    return CompositedTransformTarget(
      link: _layerLink,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              tooltip: 'Notifications',
              onPressed: _toggleOverlay,
              icon: Icon(
                Icons.notifications_rounded,
                color: colorScheme.primary,
                size: 24,
              ),
            ),
          ),
          if (unreadCount > 0)
            Positioned(
              right: 1,
              top: 1,
              child: Container(
                height: 18,
                constraints: const BoxConstraints(minWidth: 18),
                padding: const EdgeInsets.symmetric(horizontal: 4),
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  unreadCount > 99 ? '99+' : '$unreadCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
