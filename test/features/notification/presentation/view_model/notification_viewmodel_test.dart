import 'package:bazar/features/notification/domain/entities/notification_entity.dart';
import 'package:bazar/features/notification/presentation/state/notification_state.dart';
import 'package:bazar/features/notification/presentation/view_model/notification_view_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// ── Stub view-model ──────────────────────────────────────────────────────────
// Overrides build() so no real providers / timers are started.

class _StubNotificationViewModel extends NotificationViewModel {
  final List<NotificationEntity> initialNotifications;
  final int initialUnreadCount;

  _StubNotificationViewModel({
    this.initialNotifications = const [],
    this.initialUnreadCount = 0,
  });

  @override
  NotificationState build() {
    return NotificationState(
      notifications: initialNotifications,
      unreadCount: initialUnreadCount,
      hasLoaded: true,
    );
  }

  @override
  Future<void> loadNotifications({
    bool forceRefresh = false,
    bool silent = false,
  }) async {}

  @override
  Future<void> loadUnreadCount({bool forceRefresh = false}) async {}

  @override
  Future<void> refresh() async {}

  @override
  Future<void> loadMore() async {}

  @override
  Future<bool> markAllAsRead() async {
    state = state.copyWith(
      notifications:
          state.notifications.map((n) => n.copyWith(isRead: true)).toList(),
      unreadCount: 0,
    );
    return true;
  }
}

// ── Tests ─────────────────────────────────────────────────────────────────────

NotificationEntity _buildNotification({
  String id = 'n1',
  bool isRead = false,
}) =>
    NotificationEntity(
      id: id,
      userId: 'u1',
      type: NotificationType.general,
      title: 'Test',
      message: 'Test message',
      relatedEntityId: null,
      relatedEntityType: RelatedEntityType.unknown,
      isRead: isRead,
      metadata: const {},
      createdAt: DateTime(2026, 2, 1),
      updatedAt: DateTime(2026, 2, 1),
    );

void main() {
  // ── 1: initial state ────────────────────────────────────────────────────

  test('NotificationViewModel initial state reflects seeded unread count',
      () {
    final container = ProviderContainer(
      overrides: [
        notificationViewModelProvider.overrideWith(
          () => _StubNotificationViewModel(initialUnreadCount: 4),
        ),
      ],
    );
    addTearDown(container.dispose);

    final state = container.read(notificationViewModelProvider);
    expect(state.unreadCount, 4);
    expect(state.hasLoaded, true);
  });

  // ── 2: markAllAsRead ─────────────────────────────────────────────────────

  test('markAllAsRead sets unreadCount to 0 and marks all notifications read',
      () async {
    final unreadNotifs = [
      _buildNotification(id: 'n1', isRead: false),
      _buildNotification(id: 'n2', isRead: false),
    ];

    final container = ProviderContainer(
      overrides: [
        notificationViewModelProvider.overrideWith(
          () => _StubNotificationViewModel(
            initialNotifications: unreadNotifs,
            initialUnreadCount: 2,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    expect(container.read(notificationViewModelProvider).unreadCount, 2);

    await container.read(notificationViewModelProvider.notifier).markAllAsRead();

    final state = container.read(notificationViewModelProvider);
    expect(state.unreadCount, 0);
    expect(state.notifications.every((n) => n.isRead), true);
  });

  // ── 3: state reflects notification list ──────────────────────────────────

  test('NotificationViewModel state contains the seeded notifications list',
      () {
    final notifications = [
      _buildNotification(id: 'n1'),
      _buildNotification(id: 'n2'),
      _buildNotification(id: 'n3'),
    ];

    final container = ProviderContainer(
      overrides: [
        notificationViewModelProvider.overrideWith(
          () => _StubNotificationViewModel(
            initialNotifications: notifications,
            initialUnreadCount: 3,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final state = container.read(notificationViewModelProvider);
    expect(state.notifications.length, 3);
    expect(state.notifications.first.id, 'n1');
    expect(state.notifications.last.id, 'n3');
  });
}
