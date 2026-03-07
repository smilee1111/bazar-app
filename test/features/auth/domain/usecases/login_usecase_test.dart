import 'package:bazar/core/error/failure.dart';
import 'package:bazar/features/auth/domain/entities/auth_entity.dart';
import 'package:bazar/features/auth/domain/repositories/auth_repository.dart';
import 'package:bazar/features/auth/domain/usecases/login_usecase.dart';
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

  test('returns AuthEntity on successful login', () async {
    when(() => mockRepo.login(any(), any()))
        .thenAnswer((_) async => const Right(sampleUser));

    final usecase = LoginUsecase(authRepository: mockRepo);
    final result = await usecase(
      const LoginParams(email: 'test@example.com', password: 'pass1234'),
    );

    expect(result.isRight(), true);
    expect(result.getOrElse(() => throw Exception()), sampleUser);
    verify(() => mockRepo.login('test@example.com', 'pass1234')).called(1);
  });

  test('returns Failure on invalid credentials', () async {
    when(() => mockRepo.login(any(), any())).thenAnswer(
      (_) async =>
          const Left(ApiFailure(message: 'Invalid credentials', statusCode: 401)),
    );

    final usecase = LoginUsecase(authRepository: mockRepo);
    final result = await usecase(
      const LoginParams(email: 'wrong@example.com', password: 'badpass'),
    );

    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure.message, 'Invalid credentials'),
      (_) => fail('Expected Left'),
    );
  });
}
