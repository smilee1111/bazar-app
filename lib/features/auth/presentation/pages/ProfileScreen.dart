import 'package:bazar/app/routes/app_routes.dart';
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
  final _nameController = TextEditingController(text: 'Ramsey');
  final _imagePicker = ImagePicker();

  XFile? _profilePhoto;

  @override
  void dispose() {
    _nameController.dispose();
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

    return SingleChildScrollView(
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
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
                Positioned(
                  top: 160,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 52,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 48,
                          backgroundColor: const Color(0xFFF3F3F3),
                          backgroundImage: profileImageProvider,
                          child: profileImageProvider == null
                              ? const Icon(
                                  Icons.person_outline_rounded,
                                  size: 44,
                                  color: Colors.black54,
                                )
                              : null,
                        ),
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
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
          const SizedBox(height: 32),
          Text(
            _nameController.text.trim().isEmpty
                ? 'Your name'
                : _nameController.text.trim(),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () async {
                await ref.read(authViewModelProvider.notifier).logout();

                if (context.mounted) {
                  AppRoutes.pushAndRemoveUntil(
                    context,
                    const Loginpagescreen(),
                  );
                }
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
