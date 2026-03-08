import 'package:bazar/app/theme/textstyle.dart';
import 'package:bazar/core/models/geo_point.dart';
import 'package:bazar/core/utils/snackbar_utils.dart';
import 'package:bazar/core/widgets/location_picker_map.dart';
import 'package:bazar/features/category/domain/entities/category_entity.dart';
import 'package:bazar/features/category/domain/usecases/get_all_category_usecase.dart';
import 'package:bazar/features/sellerApplication/domain/entities/seller_application_entity.dart';
import 'package:bazar/features/sellerApplication/presentation/view_model/seller_application_view_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:path/path.dart' as p;

class SellerApplicationPage extends ConsumerStatefulWidget {
  const SellerApplicationPage({
    super.key,
    this.initialData,
    this.isReapply = false,
  });

  final SellerApplicationEntity? initialData;
  final bool isReapply;

  @override
  ConsumerState<SellerApplicationPage> createState() =>
      _SellerApplicationPageState();
}

class _SellerApplicationPageState extends ConsumerState<SellerApplicationPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _businessNameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _descriptionController;

  List<CategoryEntity> _categories = const [];
  String? _selectedCategoryName;
  bool _isLoadingCategories = true;
  String? _categoriesError;

  String? _selectedDocumentPath;
  String? _selectedDocumentName;
  bool _hasPickedNewDocument = false;
  GeoPoint? _selectedLocation;

  @override
  void initState() {
    super.initState();
    final data = widget.initialData;
    _businessNameController = TextEditingController(
      text: data?.businessName ?? '',
    );
    _selectedCategoryName = data?.categoryName;
    _phoneController = TextEditingController(text: data?.businessPhone ?? '');
    _addressController = TextEditingController(
      text: data?.businessAddress ?? '',
    );
    _descriptionController = TextEditingController(
      text: data?.description ?? '',
    );
    _selectedLocation = data?.location;
    _selectedDocumentPath = data?.documentUrl;
    final existingDocument = data?.documentUrl;
    _selectedDocumentName =
        (existingDocument == null || existingDocument.isEmpty)
        ? null
        : p.basename(existingDocument);

    Future.microtask(_loadCategories);
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    setState(() {
      _isLoadingCategories = true;
      _categoriesError = null;
    });

    final result = await ref.read(getAllCategoryUseCaseProvider)();
    if (!mounted) return;

    result.fold(
      (failure) {
        setState(() {
          _isLoadingCategories = false;
          _categoriesError = failure.message;
          _categories = const [];
        });
      },
      (categories) {
        final items = [...categories];
        final selected = _selectedCategoryName;
        final containsSelected =
            selected != null && items.any((c) => c.categoryName == selected);
        if (!containsSelected && (selected?.isNotEmpty ?? false)) {
          items.add(CategoryEntity(categoryName: selected!));
        }

        setState(() {
          _isLoadingCategories = false;
          _categoriesError = items.isEmpty ? 'No categories found.' : null;
          _categories = items;
        });
      },
    );
  }

  Future<void> _pickPdfDocument() async {
    try {
      final picked = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: const ['pdf'],
      );

      if (picked == null || picked.files.isEmpty) return;

      final file = picked.files.single;
      if (file.path == null || file.path!.isEmpty) {
        if (!mounted) return;
        SnackbarUtils.showError(
          context,
          'Unable to access selected file path on this device.',
        );
        return;
      }

      setState(() {
        _selectedDocumentPath = file.path;
        _selectedDocumentName = file.name;
        _hasPickedNewDocument = true;
      });
    } catch (_) {
      if (!mounted) return;
      SnackbarUtils.showError(context, 'Unable to pick PDF document.');
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedLocation == null) {
      SnackbarUtils.showError(context, 'Please pin your business location.');
      return;
    }

    final success = await ref
        .read(sellerApplicationViewModelProvider.notifier)
        .submitApplication(
          businessName: _businessNameController.text,
          categoryName: _selectedCategoryName ?? '',
          businessPhone: _phoneController.text,
          businessAddress: _addressController.text,
          location: _selectedLocation,
          description: _descriptionController.text,
          documentUrl: _hasPickedNewDocument ? null : _selectedDocumentPath,
          documentFilePath: _hasPickedNewDocument
              ? _selectedDocumentPath
              : null,
        );

    if (!mounted) return;
    if (success) {
      SnackbarUtils.showSuccess(
        context,
        'Seller application submitted successfully.',
      );
      Navigator.pop(context);
      return;
    }

    final error =
        ref.read(sellerApplicationViewModelProvider).errorMessage ??
        'Unable to submit seller application.';
    SnackbarUtils.showError(context, error);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(sellerApplicationViewModelProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isReapply ? 'Reapply Seller Access' : 'Seller Application',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.isReapply
                      ? 'Update your information and submit a new request.'
                      : 'Submit your business details for seller verification.',
                  style: AppTextStyle.minimalTexts.copyWith(
                    fontSize: 13,
                    color: colorScheme.onSurface.withValues(alpha: 0.74),
                  ),
                ),
                const SizedBox(height: 16),
                _buildInput(
                  controller: _businessNameController,
                  label: 'Business Name',
                  icon: Icons.storefront_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Business name is required.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _CategoryDropdownField(
                  categories: _categories,
                  selectedValue: _selectedCategoryName,
                  isLoading: _isLoadingCategories,
                  errorMessage: _categoriesError,
                  onRetry: _loadCategories,
                  onChanged: (value) {
                    setState(() {
                      _selectedCategoryName = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                _buildInput(
                  controller: _phoneController,
                  label: 'Business Phone',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Business phone is required.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                _buildInput(
                  controller: _addressController,
                  label: 'Business Address',
                  icon: Icons.location_on_outlined,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Business address is required.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Pin Business Location',
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
                  height: 320,
                  onChanged: (location, address) {
                    setState(() {
                      _selectedLocation = GeoPoint(
                        latitude: location.latitude,
                        longitude: location.longitude,
                      );
                      if ((address ?? '').trim().isNotEmpty) {
                        _addressController.text = address!.trim();
                      }
                    });
                  },
                ),
                const SizedBox(height: 12),
                _buildInput(
                  controller: _descriptionController,
                  label: 'Description (Optional)',
                  icon: Icons.description_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                _DocumentUploadField(
                  fileName: _selectedDocumentName,
                  onPickTap: _pickPdfDocument,
                  onRemoveTap: _selectedDocumentPath == null
                      ? null
                      : () {
                          setState(() {
                            _selectedDocumentPath = null;
                            _selectedDocumentName = null;
                            _hasPickedNewDocument = false;
                          });
                        },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: state.isSubmitting ? null : _submit,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: state.isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.isReapply
                                ? 'Submit Again'
                                : 'Submit Application',
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
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
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
      ),
    );
  }
}

class _CategoryDropdownField extends StatelessWidget {
  const _CategoryDropdownField({
    required this.categories,
    required this.selectedValue,
    required this.isLoading,
    required this.errorMessage,
    required this.onRetry,
    required this.onChanged,
  });

  final List<CategoryEntity> categories;
  final String? selectedValue;
  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onRetry;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasOptions = categories.isNotEmpty;
    final validValue =
        selectedValue != null &&
            categories.any((c) => c.categoryName == selectedValue)
        ? selectedValue
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DropdownButtonFormField<String>(
          initialValue: validValue,
          isExpanded: true,
          style: AppTextStyle.inputBox.copyWith(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          onChanged: isLoading || !hasOptions ? null : onChanged,
          items: categories
              .map(
                (category) => DropdownMenuItem<String>(
                  value: category.categoryName,
                  child: Text(
                    category.categoryName,
                    style: AppTextStyle.inputBox.copyWith(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                ),
              )
              .toList(),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Category is required.';
            }
            return null;
          },
          decoration: InputDecoration(
            labelText: 'Business Category',
            prefixIcon: const Icon(Icons.category_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            isDense: true,
          ),
        ),
        if (isLoading) ...[
          const SizedBox(height: 8),
          const LinearProgressIndicator(minHeight: 2),
        ],
        if ((errorMessage ?? '').isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Text(
                  errorMessage!,
                  style: AppTextStyle.minimalTexts.copyWith(
                    fontSize: 12,
                    color: Colors.redAccent,
                  ),
                ),
              ),
              TextButton(onPressed: onRetry, child: const Text('Retry')),
            ],
          ),
        ],
      ],
    );
  }
}

class _DocumentUploadField extends StatelessWidget {
  const _DocumentUploadField({
    required this.fileName,
    required this.onPickTap,
    required this.onRemoveTap,
  });

  final String? fileName;
  final VoidCallback onPickTap;
  final VoidCallback? onRemoveTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.22),
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Business Document (PDF)',
            style: AppTextStyle.inputBox.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Upload registration or verification document (optional).',
            style: AppTextStyle.minimalTexts.copyWith(
              fontSize: 12,
              color: colorScheme.onSurface.withValues(alpha: 0.74),
            ),
          ),
          const SizedBox(height: 10),
          if ((fileName ?? '').isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.picture_as_pdf_outlined,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      fileName!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.inputBox.copyWith(
                        fontSize: 12,
                        color: colorScheme.onSurface,
                      ),
                    ),
                  ),
                  if (onRemoveTap != null)
                    IconButton(
                      onPressed: onRemoveTap,
                      icon: const Icon(Icons.close_rounded, size: 18),
                      tooltip: 'Remove file',
                    ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onPickTap,
            icon: const Icon(Icons.upload_file_rounded),
            label: Text(fileName == null ? 'Choose PDF' : 'Replace PDF'),
          ),
        ],
      ),
    );
  }
}
