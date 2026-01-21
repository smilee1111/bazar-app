import 'package:bazar/app/routes/app_routes.dart';
import 'package:bazar/features/auth/presentation/pages/LoginPageScreen.dart';
import 'package:bazar/features/auth/presentation/view_model/auth_viewmodel.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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

  Future<void> _handleSubmit() async {
    // if()
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profileImageProvider = _profilePhoto == null
        ? null
        : FileImage(File(_profilePhoto!.path)) as ImageProvider;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                height: 220,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8D9AE),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
              Positioned(
                bottom: -44,
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
                          onTap: _handleSubmit,
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
          const SizedBox(height: 64),
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
