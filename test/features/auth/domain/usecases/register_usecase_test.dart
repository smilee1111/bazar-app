import 'package:bazar/core/error/failure.dart';
import 'package:bazar/features/auth/domain/entities/auth_entity.dart';
import 'package:bazar/features/auth/domain/repositories/auth_repository.dart';
import 'package:bazar/features/auth/domain/usecases/register_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late _MockAuthRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(
      const AuthEntity(fullName: '', email: '', username: ''),
    );
  });

  setUp(() {
    mockRepo = _MockAuthRepository();
  });

  test('returns true on successful registration', () async {
    when(() => mockRepo.register(
          any(),
          confirmPassword: any(named: 'confirmPassword'),
        )).thenAnswer((_) async => const Right(true));

    final usecase = RegisterUsecase(authRepository: mockRepo);
    final result = await usecase(
      const RegisterParams(
        fullName: 'New User',
        email: 'newuser@example.com',
        phoneNumber: '9800000002',
        username: 'newuser',
        password: 'secure123',
        confirmPassword: 'secure123',
      ),
    );

    expect(result.isRight(), true);
    expect(result.getOrElse(() => false), true);
  });

  test('returns Failure when email already exists', () async {
    when(() => mockRepo.register(
          any(),
          confirmPassword: any(named: 'confirmPassword'),
        )).thenAnswer(
      (_) async =>
          const Left(ApiFailure(message: 'Email already registered', statusCode: 409)),
    );

    final usecase = RegisterUsecase(authRepository: mockRepo);
    final result = await usecase(
      const RegisterParams(
        fullName: 'Test',
        email: 'existing@example.com',
        phoneNumber: '9800000003',
        username: 'existinguser',
        password: 'pass123',
        confirmPassword: 'pass123',
      ),
    );

    expect(result.isLeft(), true);
    result.fold(
      (failure) => expect(failure.message, 'Email already registered'),
      (_) => fail('Expected Left'),
    );
  });
}
