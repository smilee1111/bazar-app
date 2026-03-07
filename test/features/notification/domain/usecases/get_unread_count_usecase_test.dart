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

  test('returns unread count on success', () async {
    when(() => mockRepo.getUnreadCount())
        .thenAnswer((_) async => const Right(7));

    final usecase = GetUnreadCountUsecase(repository: mockRepo);
    final result = await usecase();

    expect(result.isRight(), true);
    expect(result.getOrElse(() => 0), 7);
    verify(() => mockRepo.getUnreadCount()).called(1);
  });
}
