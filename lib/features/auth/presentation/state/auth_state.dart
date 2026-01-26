import 'package:bazar/features/auth/domain/entities/auth_entity.dart';
import 'package:equatable/equatable.dart';

enum AuthStatus {
  initial,
  loading,
  loaded,
  authenticated,
  unauthenticated,
  registered,
  error,
}

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthEntity? user;
  final String? errorMessage;
  final String? uploadedUrl;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
    this.uploadedUrl
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthEntity? user,
    String? errorMessage,
    String? uploadedPhotoUrl,
    bool resetUploadedPhotoUrl = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      errorMessage: errorMessage ?? this.errorMessage,
      uploadedUrl: resetUploadedPhotoUrl
          ? null
          : (uploadedPhotoUrl ?? this.uploadedUrl),
    );
  }

  @override
  List<Object?> get props => [status, user, errorMessage, uploadedUrl];
}