import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../explore/domain/entities/category.dart';
import '../controllers/admin_controller.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';
import '../widgets/image_upload_field.dart';

class AddEditCategoryPage extends ConsumerStatefulWidget {
  final Category? category;

  const AddEditCategoryPage({super.key, this.category});

  @override
  ConsumerState<AddEditCategoryPage> createState() => _AddEditCategoryPageState();
}

class _AddEditCategoryPageState extends ConsumerState<AddEditCategoryPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _imageUrlController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _imageUrlController = TextEditingController(text: widget.category?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveCategory() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final controller = ref.read(adminControllerProvider);
        if (widget.category == null) {
          final newCategory = Category(
            id: '',
            name: _nameController.text.trim(),
            imageUrl: _imageUrlController.text.trim(),
          );
          await controller.addCategory(newCategory);
        } else {
          final updatedCategory = widget.category!.copyWith(
            name: _nameController.text.trim(),
            imageUrl: _imageUrlController.text.trim(),
          );
          await controller.updateCategory(updatedCategory);
        }
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Lỗi: $e'), backgroundColor: Colors.redAccent),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.category != null;
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(isEditing ? 'Sửa Thể Loại' : 'Thêm Thể Loại Mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _nameController,
                labelText: 'Tên thể loại',
                prefixIcon: Icons.category,
                validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập tên thể loại' : null,
              ),
              const SizedBox(height: 16),
              ImageUploadField(
                imageUrl: _imageUrlController.text.trim(),
                label: 'Ảnh thể loại',
                onUploaded: (url) {
                  _imageUrlController.text = url;
                },
              ),
              const SizedBox(height: 32),
              GradientButton(
                onPressed: _isLoading ? null : _saveCategory,
                text: 'LƯU THỂ LOẠI',
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
