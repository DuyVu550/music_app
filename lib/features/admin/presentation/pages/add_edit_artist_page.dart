import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../explore/domain/entities/artist.dart';
import '../controllers/admin_controller.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';

class AddEditArtistPage extends ConsumerStatefulWidget {
  final Artist? artist;

  const AddEditArtistPage({super.key, this.artist});

  @override
  ConsumerState<AddEditArtistPage> createState() => _AddEditArtistPageState();
}

class _AddEditArtistPageState extends ConsumerState<AddEditArtistPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _imageUrlController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.artist?.name ?? '');
    _imageUrlController = TextEditingController(text: widget.artist?.imageUrl ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  Future<void> _saveArtist() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final controller = ref.read(adminControllerProvider);
        if (widget.artist == null) {
          final newArtist = Artist(
            id: '',
            name: _nameController.text.trim(),
            imageUrl: _imageUrlController.text.trim(),
          );
          await controller.addArtist(newArtist);
        } else {
          final updatedArtist = widget.artist!.copyWith(
            name: _nameController.text.trim(),
            imageUrl: _imageUrlController.text.trim(),
          );
          await controller.updateArtist(updatedArtist);
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
    final isEditing = widget.artist != null;
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(isEditing ? 'Sửa Nghệ Sĩ' : 'Thêm Nghệ Sĩ Mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _nameController,
                labelText: 'Tên nghệ sĩ',
                prefixIcon: Icons.person,
                validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập tên nghệ sĩ' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _imageUrlController,
                labelText: 'Link ảnh nghệ sĩ (Image URL)',
                prefixIcon: Icons.image,
                validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập link ảnh' : null,
              ),
              const SizedBox(height: 32),
              GradientButton(
                onPressed: _isLoading ? null : _saveArtist,
                text: 'LƯU NGHỆ SĨ',
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
