import 'package:bazar/app/routes/app_routes.dart';
import 'package:bazar/app/theme/textstyle.dart';
import 'package:bazar/core/api/api_endpoints.dart';
import 'package:bazar/core/services/storage/user_session_service.dart';
import 'package:bazar/core/utils/snackbar_utils.dart';
import 'package:bazar/features/auth/presentation/pages/LoginPageScreen.dart';
import 'package:bazar/features/auth/presentation/state/auth_state.dart';
import 'package:bazar/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'package:bazar/features/auth/presentation/widgets/media_picker_bottom_sheet.dart';
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
    final theme = Theme.of(context);
    final authState = ref.watch(authViewModelProvider);
    final session = ref.read(userSessionServiceProvider);
    final remotePicturePath = authState.uploadedUrl ??
        authState.user?.profilePic ??
        session.getCurrentUserProfilePic();
    final resolvedRemoteUrl = _resolveImageUrl(remotePicturePath);
    final usernameDisplay = authState.user?.username ??
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

    return DefaultTextStyle.merge(
      style: AppTextStyle.inputBox.copyWith(
        fontSize: 14,
        color: Colors.black87,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          children: [
          SizedBox(
            height: 280,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Align(
                  alignment: Alignment.topCenter,
                  child: Container(
                    height: 220,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8D9AE),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ),
                Positioned(
                  top: 150,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 58,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 54,
                          backgroundColor: const Color(0xFFF3F3F3),
                          backgroundImage: profileImageProvider,
                          child: profileImageProvider == null
                              ? const Icon(
                                  Icons.person_outline_rounded,
                                  size: 48,
                                  color: Colors.black45,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        right: 4,
                        bottom: 4,
                        child: Material(
                          color: Colors.white,
                          shape: const CircleBorder(),
                          elevation: 2,
                          child: InkWell(
                            customBorder: const CircleBorder(),
                            onTap: _showMediaPicker,
                            child: const Padding(
                              padding: EdgeInsets.all(8),
                              child: Icon(Icons.edit_outlined, size: 20),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            usernameDisplay,
            style: AppTextStyle.inputBox.copyWith(
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          _ContactCard(
            phoneNumber: authState.user?.phoneNumber ??
                session.getCurrentUserPhoneNumber() ??
                'Add phone number',
            email: authState.user?.email ??
                session.getCurrentUserEmail() ??
                'Add email',
          ),
          const SizedBox(height: 20),
          _ActionCard(
            onSettingsTap: () {
              SnackbarUtils.showInfo(
                context,
                'Settings coming soon.',
              );
            },
            onLogoutTap: () async {
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

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.phoneNumber,
    required this.email,
  });

  final String phoneNumber;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _ContactRow(
            label: 'Phone',
            value: phoneNumber,
            icon: Icons.phone_rounded,
          ),
          const SizedBox(height: 18),
          _ContactRow(
            label: 'Mail',
            value: email,
            icon: Icons.mail_outline_rounded,
          ),
        ],
      ),
    );
  }
}

class _ContactRow extends StatelessWidget {
  const _ContactRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFF2EFE3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: Colors.brown.shade700),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTextStyle.minimalTexts.copyWith(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                value,
                style: AppTextStyle.inputBox.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.onSettingsTap,
    required this.onLogoutTap,
  });

  final VoidCallback onSettingsTap;
  final VoidCallback onLogoutTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: onSettingsTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF2EFE3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.settings_outlined,
                        size: 20,
                        color: Colors.brown.shade700,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Settings',
                        style: AppTextStyle.inputBox.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: Colors.grey.shade500,
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Align(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 210),
                child: ElevatedButton.icon(
                  onPressed: onLogoutTap,
                  icon: const Icon(Icons.logout, size: 18),
                  label: Text(
                    'Log Out',
                    style: AppTextStyle.inputBox.copyWith(
                      fontSize: 14,
                      color: Colors.white,
                      letterSpacing: 0.4,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 18,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
