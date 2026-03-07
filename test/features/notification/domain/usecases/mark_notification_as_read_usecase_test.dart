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

void main() {
  late _MockNotificationRepository mockRepo;

  setUp(() {
    mockRepo = _MockNotificationRepository();
  });

  test('returns updated notification on success', () async {
    final readNotification = _sampleNotification().copyWith(isRead: true);

    when(() => mockRepo.markAsRead(any()))
        .thenAnswer((_) async => Right(readNotification));

    final usecase = MarkNotificationAsReadUsecase(repository: mockRepo);
    final result = await usecase(const NotificationIdParams('notif_001'));

    expect(result.isRight(), true);
    result.fold(
      (_) => fail('Expected Right'),
      (notif) => expect(notif.isRead, true),
    );
    verify(() => mockRepo.markAsRead('notif_001')).called(1);
  });
}
