import 'package:bazar/features/auth/domain/entities/auth_entity.dart';
import 'package:bazar/features/auth/domain/repositories/auth_repository.dart';
import 'package:bazar/features/auth/domain/usecases/get_current_user_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late _MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = _MockAuthRepository();
  });

  const sampleUser = AuthEntity(
    authId: 'user_001',
    fullName: 'Test User',
    email: 'test@example.com',
    phoneNumber: '9800000001',
    username: 'testuser',
  );

  test('returns AuthEntity for authenticated user', () async {
    when(() => mockRepo.getCurrentUser())
        .thenAnswer((_) async => const Right(sampleUser));

    final usecase = GetCurrentUserUsecase(authRepository: mockRepo);
    final result = await usecase();

    expect(result.isRight(), true);
    result.fold(
      (_) => fail('Expected Right'),
      (user) {
        expect(user.authId, 'user_001');
        expect(user.email, 'test@example.com');
      },
    );
  });
}
