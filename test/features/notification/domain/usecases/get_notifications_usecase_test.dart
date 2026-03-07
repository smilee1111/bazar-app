import 'package:bazar/core/error/failure.dart';
import 'package:bazar/features/notification/domain/entities/notification_entity.dart';
import 'package:bazar/features/notification/domain/repositories/notification_repository.dart';
import 'package:bazar/features/notification/domain/usecases/notification_usecases.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockNotificationRepository extends Mock
    implements INotificationRepository {}

NotificationEntity _sampleNotification() => NotificationEntity(
      id: 'notif_001',
      userId: 'user_001',
      type: NotificationType.general,
      title: 'Test Notification',
      message: 'This is a test',
      relatedEntityId: null,
      relatedEntityType: RelatedEntityType.unknown,
      isRead: false,
      metadata: const {},
      createdAt: DateTime(2026, 2, 1),
      updatedAt: DateTime(2026, 2, 1),
    );

PaginatedNotificationEntity _samplePaginatedResult() =>
    PaginatedNotificationEntity(
      items: [_sampleNotification()],
      pagination: const NotificationPaginationEntity(
        page: 1,
        size: 20,
        total: 1,
        totalPages: 1,
      ),
      unreadCount: 1,
      message: 'ok',
    );

void main() {
  late _MockNotificationRepository mockRepo;

  setUp(() {
    mockRepo = _MockNotificationRepository();
  });

  test('returns paginated notifications on success', () async {
    when(() => mockRepo.getNotifications(
          page: any(named: 'page'),
          size: any(named: 'size'),
          isRead: any(named: 'isRead'),
        )).thenAnswer((_) async => Right(_samplePaginatedResult()));

    final usecase = GetNotificationsUsecase(repository: mockRepo);
    final result = await usecase(const GetNotificationsParams());

    expect(result.isRight(), true);
    result.fold(
      (_) => fail('Expected Right'),
      (data) {
        expect(data.items.length, 1);
        expect(data.unreadCount, 1);
        expect(data.pagination.total, 1);
      },
    );
  });

  test('returns Failure when network is unavailable', () async {
    when(() => mockRepo.getNotifications(
          page: any(named: 'page'),
          size: any(named: 'size'),
          isRead: any(named: 'isRead'),
        )).thenAnswer(
      (_) async => const Left(NetworkFailure(message: 'No internet connection')),
    );

    final usecase = GetNotificationsUsecase(repository: mockRepo);
    final result = await usecase(const GetNotificationsParams());

    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure.message, 'No internet connection'),
      (_) => fail('Expected Left'),
    );
  });
}
