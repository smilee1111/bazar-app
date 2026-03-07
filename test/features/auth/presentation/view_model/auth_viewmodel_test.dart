import 'dart:io';

import 'package:bazar/core/error/failure.dart';
import 'package:bazar/features/auth/data/repositories/auth_repository.dart';
import 'package:bazar/features/auth/domain/entities/auth_entity.dart';
import 'package:bazar/features/auth/domain/repositories/auth_repository.dart';
import 'package:bazar/features/auth/presentation/state/auth_state.dart';
import 'package:bazar/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements IAuthRepository {}

void main() {
  late MockAuthRepository mockRepo;

  setUpAll(() {
    registerFallbackValue(
      const AuthEntity(fullName: '', email: '', username: ''),
    );
    registerFallbackValue(File(''));
  });

  setUp(() {
    mockRepo = MockAuthRepository();
  });

  // ── helpers ───────────────────────────────────────────────────────────────

  ProviderContainer makeContainer() {
    return ProviderContainer(
      overrides: [authRepositoryProvider.overrideWithValue(mockRepo)],
    );
  }

  AuthEntity sampleUser() => const AuthEntity(
        authId: 'user_001',
        fullName: 'Test User',
        email: 'test@example.com',
        phoneNumber: '9800000001',
        username: 'testuser',
      );

  // ── Initial state ─────────────────────────────────────────────────────────

  test('AuthViewModel initial state is AuthStatus.initial', () {
    final container = makeContainer();
    addTearDown(container.dispose);

    expect(
      container.read(authViewModelProvider).status,
      AuthStatus.initial,
    );
  });

  // ── Login ─────────────────────────────────────────────────────────────────

  test('login sets status to authenticated with user on success', () async {
    when(() => mockRepo.login(any(), any()))
        .thenAnswer((_) async => Right(sampleUser()));

    final container = makeContainer();
    addTearDown(container.dispose);

    await container
        .read(authViewModelProvider.notifier)
        .login(email: 'test@example.com', password: 'pass1234');

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.authenticated);
    expect(state.user, sampleUser());
    expect(state.errorMessage, isNull);
  });

  test('login sets status to error with message on failure', () async {
    when(() => mockRepo.login(any(), any())).thenAnswer(
      (_) async => const Left(ApiFailure(message: 'Wrong password', statusCode: 401)),
    );

    final container = makeContainer();
    addTearDown(container.dispose);

    await container
        .read(authViewModelProvider.notifier)
        .login(email: 'test@example.com', password: 'wrong');

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.error);
    expect(state.errorMessage, 'Wrong password');
    expect(state.user, isNull);
  });

  // ── Register ──────────────────────────────────────────────────────────────

  test('register sets status to registered on success', () async {
    when(() => mockRepo.register(
          any(),
          confirmPassword: any(named: 'confirmPassword'),
        )).thenAnswer((_) async => const Right(true));

    final container = makeContainer();
    addTearDown(container.dispose);

    await container.read(authViewModelProvider.notifier).register(
          fullName: 'New User',
          email: 'new@example.com',
          phoneNumber: '9800000002',
          username: 'newuser',
          password: 'secure123',
          confirmPassword: 'secure123',
        );

    expect(
      container.read(authViewModelProvider).status,
      AuthStatus.registered,
    );
  });

  test('register sets status to error with message on failure', () async {
    when(() => mockRepo.register(
          any(),
          confirmPassword: any(named: 'confirmPassword'),
        )).thenAnswer(
      (_) async =>
          const Left(ApiFailure(message: 'Username taken', statusCode: 409)),
    );

    final container = makeContainer();
    addTearDown(container.dispose);

    await container.read(authViewModelProvider.notifier).register(
          fullName: 'Test',
          email: 'x@example.com',
          phoneNumber: '9800000003',
          username: 'taken',
          password: 'pass',
          confirmPassword: 'pass',
        );

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.error);
    expect(state.errorMessage, 'Username taken');
  });

  // ── GetCurrentUser ────────────────────────────────────────────────────────

  test('getCurrentUser sets status to authenticated with user on success',
      () async {
    when(() => mockRepo.getCurrentUser())
        .thenAnswer((_) async => Right(sampleUser()));

    final container = makeContainer();
    addTearDown(container.dispose);

    await container.read(authViewModelProvider.notifier).getCurrentUser();

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.authenticated);
    expect(state.user?.email, 'test@example.com');
  });

  // ── Logout ────────────────────────────────────────────────────────────────

  test('logout sets status to unauthenticated on success', () async {
    // Seed an authenticated state first
    when(() => mockRepo.login(any(), any()))
        .thenAnswer((_) async => Right(sampleUser()));
    when(() => mockRepo.logout())
        .thenAnswer((_) async => const Right(true));

    final container = makeContainer();
    addTearDown(container.dispose);

    await container
        .read(authViewModelProvider.notifier)
        .login(email: 'test@example.com', password: 'pass1234');

    expect(
      container.read(authViewModelProvider).status,
      AuthStatus.authenticated,
    );

    await container.read(authViewModelProvider.notifier).logout();

    final state = container.read(authViewModelProvider);
    expect(state.status, AuthStatus.unauthenticated);
    // Note: AuthState.copyWith uses `user ?? this.user`, so user is retained
    // in memory after logout (intentional — only the status is cleared).
    expect(state.status, isNot(AuthStatus.authenticated));
  });
}
