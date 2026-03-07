import 'package:bazar/features/notification/domain/repositories/notification_repository.dart';
import 'package:bazar/features/notification/domain/usecases/notification_usecases.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockNotificationRepository extends Mock
    implements INotificationRepository {}

void main() {
  late _MockNotificationRepository mockRepo;

  setUp(() {
    mockRepo = _MockNotificationRepository();
  });

  test('returns true on successful deletion', () async {
    when(() => mockRepo.deleteNotification(any()))
        .thenAnswer((_) async => const Right(true));

    final usecase = DeleteNotificationUsecase(repository: mockRepo);
    final result = await usecase(const NotificationIdParams('notif_001'));

    expect(result.isRight(), true);
    expect(result.getOrElse(() => false), true);
    verify(() => mockRepo.deleteNotification('notif_001')).called(1);
  });
}
