import 'package:bazar/app/theme/colors.dart';
import 'package:bazar/app/theme/textstyle.dart';
import 'package:bazar/core/utils/snackbar_utils.dart';
import 'package:bazar/features/notification/presentation/state/notification_state.dart';
import 'package:bazar/features/notification/presentation/utils/notification_navigation.dart';
import 'package:bazar/features/notification/presentation/utils/notification_ui_utils.dart';
import 'package:bazar/features/notification/presentation/view_model/notification_view_model.dart';
import 'package:bazar/features/notification/presentation/widgets/notification_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotificationListPage extends ConsumerStatefulWidget {
  const NotificationListPage({super.key});

  @override
  ConsumerState<NotificationListPage> createState() =>
      _NotificationListPageState();
}

class _NotificationListPageState extends ConsumerState<NotificationListPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref
          .read(notificationViewModelProvider.notifier)
          .loadNotifications();
      await ref.read(notificationViewModelProvider.notifier).loadUnreadCount();
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final threshold = _scrollController.position.maxScrollExtent - 240;
    if (_scrollController.position.pixels >= threshold) {
      ref.read(notificationViewModelProvider.notifier).loadMore();
    }
  }

  Future<void> _confirmDeleteAll() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete all notifications?'),
        content: const Text(
          'This action will remove your full notification history and cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    HapticFeedback.mediumImpact();
    final success = await ref
        .read(notificationViewModelProvider.notifier)
        .deleteAllNotifications();
    if (!mounted) return;
    if (success) {
      SnackbarUtils.showSuccess(context, 'All notifications deleted');
    } else {
      final msg = ref.read(notificationViewModelProvider).errorMessage;
      if ((msg ?? '').isNotEmpty) SnackbarUtils.showError(context, msg!);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(notificationViewModelProvider);
    final vm = ref.read(notificationViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          if (state.notifications.isNotEmpty)
            IconButton(
              tooltip: 'Delete all',
              onPressed: state.isDeletingAll ? null : _confirmDeleteAll,
              icon: state.isDeletingAll
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.delete_sweep_rounded),
            ),
        ],
      ),
      body: Column(
        children: [
          _FilterTabs(
            selected: state.filter,
            onChanged: (value) {
              HapticFeedback.selectionClick();
              vm.setFilter(value);
            },
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: Row(
              children: [
                Text(
                  '${state.unreadCount} unread',
                  style: AppTextStyle.minimalTexts.copyWith(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.74),
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: state.isMarkingAllRead
                      ? null
                      : () async {
                          HapticFeedback.selectionClick();
                          final ok = await vm.markAllAsRead();
                          if (!mounted) return;
                          if (ok) {
                            SnackbarUtils.showSuccess(
                              context,
                              'All notifications marked as read',
                            );
                          } else {
                            final msg = ref
                                .read(notificationViewModelProvider)
                                .errorMessage;
                            if ((msg ?? '').isNotEmpty) {
                              SnackbarUtils.showError(context, msg!);
                            }
                          }
                        },
                  child: state.isMarkingAllRead
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Mark all as read'),
                ),
              ],
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => vm.refresh(),
              child: _buildBody(context, state),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotificationState state) {
    final colorScheme = Theme.of(context).colorScheme;

    if (state.isLoading && state.notifications.isEmpty) {
      return ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: 8,
        itemBuilder: (_, _) => const Padding(
          padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
          child: _NotificationSkeleton(),
        ),
      );
    }

    if ((state.errorMessage ?? '').isNotEmpty && state.notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: AppTextStyle.inputBox.copyWith(color: AppColors.error),
              ),
            ),
          ),
        ],
      );
    }

    if (state.notifications.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: const [SizedBox(height: 100), _EmptyState()],
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: state.notifications.length + (state.isLoadingMore ? 1 : 0),
      itemBuilder: (_, index) {
        if (index >= state.notifications.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
          );
        }

        final notification = state.notifications[index];
        final section = NotificationUiUtils.sectionLabel(
          notification.createdAt,
        );
        final prevSection = index == 0
            ? null
            : NotificationUiUtils.sectionLabel(
                state.notifications[index - 1].createdAt,
              );
        final showHeader = section != prevSection;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showHeader)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 14, 12, 6),
                child: Text(
                  section,
                  style: AppTextStyle.inputBox.copyWith(
                    fontSize: 12,
                    color: colorScheme.onSurface.withValues(alpha: 0.74),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
              child: Dismissible(
                key: ValueKey('notification_${notification.id}'),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    color: AppColors.error,
                  ),
                ),
                confirmDismiss: (_) async {
                  HapticFeedback.lightImpact();
                  return true;
                },
                onDismissed: (_) async {
                  final ok = await ref
                      .read(notificationViewModelProvider.notifier)
                      .deleteNotification(notification.id);
                  if (!mounted) return;
                  if (ok) {
                    SnackbarUtils.showSuccess(context, 'Notification deleted');
                  } else {
                    final msg = ref
                        .read(notificationViewModelProvider)
                        .errorMessage;
                    if ((msg ?? '').isNotEmpty) {
                      SnackbarUtils.showError(context, msg!);
                    }
                  }
                },
                child: NotificationItem(
                  notification: notification,
                  processing: state.processingIds.contains(notification.id),
                  onTap: () => handleNotificationTap(
                    context: context,
                    ref: ref,
                    notification: notification,
                  ),
                  onMarkAsRead: notification.isRead
                      ? null
                      : () async {
                          HapticFeedback.selectionClick();
                          final ok = await ref
                              .read(notificationViewModelProvider.notifier)
                              .markAsRead(notification.id);
                          if (!mounted) return;
                          if (!ok) {
                            final msg = ref
                                .read(notificationViewModelProvider)
                                .errorMessage;
                            if ((msg ?? '').isNotEmpty) {
                              SnackbarUtils.showError(context, msg!);
                            }
                          }
                        },
                  onDelete: () async {
                    HapticFeedback.lightImpact();
                    final ok = await ref
                        .read(notificationViewModelProvider.notifier)
                        .deleteNotification(notification.id);
                    if (!mounted) return;
                    if (ok) {
                      SnackbarUtils.showSuccess(
                        context,
                        'Notification deleted',
                      );
                    } else {
                      final msg = ref
                          .read(notificationViewModelProvider)
                          .errorMessage;
                      if ((msg ?? '').isNotEmpty)
                        SnackbarUtils.showError(context, msg!);
                    }
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _FilterTabs extends StatelessWidget {
  const _FilterTabs({required this.selected, required this.onChanged});

  final NotificationReadFilter selected;
  final ValueChanged<NotificationReadFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final tabs = [
      (NotificationReadFilter.all, 'All'),
      (NotificationReadFilter.unread, 'Unread'),
      (NotificationReadFilter.read, 'Read'),
    ];
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 2),
      child: Row(
        children: tabs.map((item) {
          final active = item.$1 == selected;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                decoration: BoxDecoration(
                  color: active
                      ? AppColors.primary.withValues(alpha: 0.12)
                      : colorScheme.surface,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: active
                        ? AppColors.primary
                        : colorScheme.onSurface.withValues(alpha: 0.14),
                  ),
                ),
                child: InkWell(
                  onTap: () => onChanged(item.$1),
                  borderRadius: BorderRadius.circular(999),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 9),
                    child: Text(
                      item.$2,
                      textAlign: TextAlign.center,
                      style: AppTextStyle.inputBox.copyWith(
                        fontSize: 12,
                        color: active
                            ? AppColors.primary
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: colorScheme.onSurface.withValues(alpha: 0.14),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: AppColors.accent2.withValues(alpha: 0.45),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                size: 34,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'No notifications yet',
              style: AppTextStyle.inputBox.copyWith(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotificationSkeleton extends StatelessWidget {
  const _NotificationSkeleton();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 88,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.14),
        ),
      ),
    );
  }
}
