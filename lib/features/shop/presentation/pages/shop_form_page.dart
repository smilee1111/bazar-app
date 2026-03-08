import 'package:bazar/app/theme/textstyle.dart';
import 'package:bazar/core/models/geo_point.dart';
import 'package:bazar/core/utils/snackbar_utils.dart';
import 'package:bazar/core/widgets/location_picker_map.dart';
import 'package:bazar/features/shop/domain/entities/shop_entity.dart';
import 'package:bazar/features/shop/presentation/view_model/shop_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

class ShopFormPage extends ConsumerStatefulWidget {
  const ShopFormPage({super.key, this.initialShop});

  final ShopEntity? initialShop;

  @override
  ConsumerState<ShopFormPage> createState() => _ShopFormPageState();
}

class _ShopFormPageState extends ConsumerState<ShopFormPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _shopNameCtrl;
  late final TextEditingController _slugCtrl;
  late final TextEditingController _descriptionCtrl;
  late final TextEditingController _addressCtrl;
  late final TextEditingController _shopContactCtrl;
  late final TextEditingController _contactNumberCtrl;
  late final TextEditingController _emailCtrl;
  GeoPoint? _selectedLocation;

  bool get _isEditMode => widget.initialShop != null;

  @override
  void initState() {
    super.initState();
    final shop = widget.initialShop;
    _shopNameCtrl = TextEditingController(text: shop?.shopName ?? '');
    _slugCtrl = TextEditingController(text: shop?.slug ?? '');
    _descriptionCtrl = TextEditingController(text: shop?.description ?? '');
    _addressCtrl = TextEditingController(text: shop?.shopAddress ?? '');
    _shopContactCtrl = TextEditingController(text: shop?.shopContact ?? '');
    _contactNumberCtrl = TextEditingController(text: shop?.contactNumber ?? '');
    _emailCtrl = TextEditingController(text: shop?.email ?? '');
    _selectedLocation = shop?.location;

    if (!_isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        SnackbarUtils.showError(
          context,
          'Creating a new shop is currently unavailable.',
        );
        Navigator.pop(context);
      });
    }
  }

  @override
  void dispose() {
    _shopNameCtrl.dispose();
    _slugCtrl.dispose();
    _descriptionCtrl.dispose();
    _addressCtrl.dispose();
    _shopContactCtrl.dispose();
    _contactNumberCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_isEditMode) return;
    if (!_formKey.currentState!.validate()) return;

    final entity = ShopEntity(
      shopId: widget.initialShop?.shopId,
      ownerId: widget.initialShop?.ownerId,
      shopName: _shopNameCtrl.text.trim(),
      slug: _emptyToNull(_slugCtrl.text),
      description: _emptyToNull(_descriptionCtrl.text),
      shopAddress: _addressCtrl.text.trim(),
      location: _selectedLocation,
      shopContact: _shopContactCtrl.text.trim(),
      contactNumber: _emptyToNull(_contactNumberCtrl.text),
      email: _emptyToNull(_emailCtrl.text),
    );

    final notifier = ref.read(shopViewModelProvider.notifier);
    final ok = await notifier.updateShop(entity);

    if (!mounted) return;
    if (ok) {
      SnackbarUtils.showSuccess(
        context,
        _isEditMode ? 'Shop updated successfully' : 'Shop created successfully',
      );
      Navigator.pop(context, true);
      return;
    }

    final error =
        ref.read(shopViewModelProvider).errorMessage ?? 'Operation failed';
    SnackbarUtils.showError(context, error);
  }

  String? _emptyToNull(String text) {
    final value = text.trim();
    return value.isEmpty ? null : value;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(shopViewModelProvider);
    final isBusy = state.isSaving;

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Shop')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Update your shop details for customers.',
                style: AppTextStyle.minimalTexts.copyWith(
                  fontSize: 13,
                  color: colorScheme.onSurface.withValues(alpha: 0.74),
                ),
              ),
              const SizedBox(height: 14),
              _input(
                controller: _shopNameCtrl,
                label: 'Shop Name',
                icon: Icons.storefront_outlined,
                validator: (value) {
                  if (value == null || value.trim().length < 2) {
                    return 'Shop name must be at least 2 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _input(
                controller: _slugCtrl,
                label: 'Slug (Optional)',
                icon: Icons.tag_outlined,
              ),
              const SizedBox(height: 12),
              _input(
                controller: _descriptionCtrl,
                label: 'Description (Optional)',
                icon: Icons.description_outlined,
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              _input(
                controller: _addressCtrl,
                label: 'Shop Address',
                icon: Icons.location_on_outlined,
                validator: (value) {
                  if (value == null || value.trim().length < 10) {
                    return 'Address must be at least 10 characters.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Text(
                'Pin Shop Location',
                style: AppTextStyle.inputBox.copyWith(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 8),
              LocationPickerMap(
                initialLocation: _selectedLocation == null
                    ? null
                    : LatLng(
                        _selectedLocation!.latitude,
                        _selectedLocation!.longitude,
                      ),
                height: 280,
                onChanged: (location, address) {
                  setState(() {
                    _selectedLocation = GeoPoint(
                      latitude: location.latitude,
                      longitude: location.longitude,
                    );
                    if ((address ?? '').trim().isNotEmpty) {
                      _addressCtrl.text = address!.trim();
                    }
                  });
                },
              ),
              const SizedBox(height: 12),
              _input(
                controller: _shopContactCtrl,
                label: 'Shop Contact (10 digits)',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (!RegExp(r'^\d{10}$').hasMatch(text)) {
                    return 'Phone number must be exactly 10 digits.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              _input(
                controller: _contactNumberCtrl,
                label: 'Alternate Contact (Optional)',
                icon: Icons.call_outlined,
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 12),
              _input(
                controller: _emailCtrl,
                label: 'Email (Optional)',
                icon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  final text = value?.trim() ?? '';
                  if (text.isEmpty) return null;
                  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
                    return 'Enter a valid email address.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isBusy ? null : _submit,
                child: isBusy
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Update Shop'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon)),
    );
  }
}
