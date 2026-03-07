import 'package:bazar/features/auth/domain/repositories/auth_repository.dart';
import 'package:bazar/features/auth/domain/usecases/logout_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late _MockAuthRepository mockRepo;

  setUp(() {
    mockRepo = _MockAuthRepository();
  });

  test('returns true on successful logout', () async {
    when(() => mockRepo.logout())
        .thenAnswer((_) async => const Right(true));

    final usecase = LogoutUsecase(authRepository: mockRepo);
    final result = await usecase();

    expect(result.isRight(), true);
    expect(result.getOrElse(() => false), true);
    verify(() => mockRepo.logout()).called(1);
  });
}
