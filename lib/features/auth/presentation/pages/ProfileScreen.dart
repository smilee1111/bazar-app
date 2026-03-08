import 'package:bazar/app/routes/app_routes.dart';
import 'package:bazar/app/theme/colors.dart';
import 'package:bazar/app/theme/textstyle.dart';
import 'package:bazar/core/api/api_endpoints.dart';
import 'package:bazar/core/services/storage/user_session_service.dart';
import 'package:bazar/core/utils/snackbar_utils.dart';
import 'package:bazar/features/auth/presentation/pages/LoginPageScreen.dart';
import 'package:bazar/features/auth/presentation/state/auth_state.dart';
import 'package:bazar/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:bazar/features/auth/presentation/widgets/profile_action_card.dart';
import 'package:bazar/features/auth/presentation/widgets/profile_contact_card.dart';
import 'package:bazar/features/auth/presentation/widgets/media_picker_bottom_sheet.dart';
import 'package:bazar/features/auth/presentation/widgets/profile_hero.dart';
import 'package:bazar/features/sellerApplication/presentation/pages/settings_page.dart';
import 'package:bazar/features/sellerApplication/presentation/view_model/seller_application_view_model.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class Profilescreen extends ConsumerStatefulWidget {
  const Profilescreen({super.key});

  @override
  ConsumerState<Profilescreen> createState() => _ProfilescreenState();
}

class _ProfilescreenState extends ConsumerState<Profilescreen> {
  final _imagePicker = ImagePicker();

  XFile? _profilePhoto;

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _requestPermission(Permission permission) async {
    final status = await permission.status;
    if (status.isGranted) return true;

    if (status.isDenied) {
      final result = await permission.request();
      return result.isGranted;
    }

    if (status.isPermanentlyDenied) {
      _showPermissionDeniedDialog();
      return false;
    }

    return false;
  }

  void _showPermissionDeniedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Permission Required"),
        content: const Text(
          "This feature requires permission to access your camera or gallery. Please enable it in your device settings.",
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _pickFromCamera() async {
    final hasPermission = await _requestPermission(Permission.camera);
    if (!hasPermission) return;

    final XFile? photo = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (photo != null) {
      setState(() {
        _profilePhoto = photo;
      });
      await ref
          .read(authViewModelProvider.notifier)
          .uploadPhoto(File(photo.path));
    }
  }

  Future<bool> _ensureGalleryPermission() async {
    Future<bool> requestPhotos() async {
      final status = await Permission.photos.status;

      if (status.isGranted || status.isLimited) {
        return true;
      }

      if (status.isDenied) {
        final refreshedStatus = await Permission.photos.request();
        if (refreshedStatus.isGranted || refreshedStatus.isLimited) {
          return true;
        }
        if (refreshedStatus.isPermanentlyDenied) {
          _showPermissionDeniedDialog();
          return false;
        }
      }

      if (status.isPermanentlyDenied) {
        _showPermissionDeniedDialog();
        return false;
      }

      return false;
    }

    if (await requestPhotos()) {
      return true;
    }

    if (Platform.isAndroid) {
      return _requestPermission(Permission.storage);
    }

    return false;
  }

  Future<void> _pickFromGallery() async {
    final hasPermission = await _ensureGalleryPermission();
    if (!hasPermission) return;

    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _profilePhoto = image;
        });
        await ref
            .read(authViewModelProvider.notifier)
            .uploadPhoto(File(image.path));
      }
    } catch (e) {
      debugPrint('Gallery Error $e');
      if (mounted) {
        SnackbarUtils.showError(
          context,
          'Unable to access gallery. Please try using the camera instead.',
        );
      }
    }
  }

  void _showMediaPicker() {
    MediaPickerBottomSheet.show(
      context,
      onCameraTap: _pickFromCamera,
      onGalleryTap: _pickFromGallery,
    );
  }

  String? _resolveImageUrl(String? path) {
    if (path == null || path.isEmpty) return null;
    if (path.startsWith('http')) return path;
    return '${ApiEndpoints.serverUrl}$path';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final authState = ref.watch(authViewModelProvider);
    final session = ref.read(userSessionServiceProvider);
    final remotePicturePath =
        authState.uploadedUrl ??
        authState.user?.profilePic ??
        session.getCurrentUserProfilePic();
    final resolvedRemoteUrl = _resolveImageUrl(remotePicturePath);
    final usernameDisplay =
        authState.user?.username ??
        session.getCurrentUserUsername() ??
        'Your username';

    ImageProvider? profileImageProvider;
    if (_profilePhoto != null) {
      profileImageProvider = FileImage(File(_profilePhoto!.path));
    } else if (resolvedRemoteUrl != null) {
      profileImageProvider = NetworkImage(resolvedRemoteUrl);
    }

    ref.listen<AuthState>(authViewModelProvider, (previous, next) {
      final didUploadChange = previous?.uploadedUrl != next.uploadedUrl;
      if (next.status == AuthStatus.loaded && didUploadChange) {
        SnackbarUtils.showSuccess(
          context,
          'Profile photo updated successfully!',
        );
        if (mounted) {
          setState(() {
            _profilePhoto = null;
          });
        }
      } else if (next.status == AuthStatus.error && next.errorMessage != null) {
        SnackbarUtils.showError(context, next.errorMessage!);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Hero banner + avatar
            ProfileHero(
              profileImageProvider: profileImageProvider,
              onEditTap: _showMediaPicker,
            ),
            const SizedBox(height: 10),

            // Name
            Text(
              usernameDisplay,
              style: AppTextStyle.inputBox.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              authState.user?.email ?? session.getCurrentUserEmail() ?? '',
              style: AppTextStyle.minimalTexts.copyWith(
                fontSize: 13,
                color: colorScheme.onSurface.withValues(alpha: 0.74),
              ),
            ),
            const SizedBox(height: 24),

            // Section label
            _SectionLabel(label: 'Contact & Info'),
            const SizedBox(height: 10),

            ProfileContactCard(
              phoneNumber:
                  authState.user?.phoneNumber ??
                  session.getCurrentUserPhoneNumber() ??
                  'Add phone number',
              email:
                  authState.user?.email ??
                  session.getCurrentUserEmail() ??
                  'Add email',
              fullName:
                  authState.user?.fullName ??
                  session.getCurrentUserFullName() ??
                  'Your name',
              username:
                  authState.user?.username ??
                  session.getCurrentUserUsername() ??
                  'username',
            ),
            const SizedBox(height: 22),

            // Section label
            _SectionLabel(label: 'Account'),
            const SizedBox(height: 10),

            ProfileActionCard(
              onSettingsTap: () {
                AppRoutes.push(context, const SettingsPage());
              },
              onLogoutTap: () async {
                ref
                    .read(sellerApplicationViewModelProvider.notifier)
                    .resetState();
                await ref.read(authViewModelProvider.notifier).logout();
                if (context.mounted) {
                  AppRoutes.pushAndRemoveUntil(
                    context,
                    const Loginpagescreen(),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label.toUpperCase(),
        style: AppTextStyle.minimalTexts.copyWith(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.accent,
          letterSpacing: 1.4,
        ),
      ),
    );
  }
}
