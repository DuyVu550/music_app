import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../player/domain/entities/album.dart';
import '../../../player/data/repositories/album_repository_impl.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';
import '../widgets/image_upload_field.dart';

class AddEditAlbumPage extends ConsumerStatefulWidget {
  final Album? album;

  const AddEditAlbumPage({super.key, this.album});

  @override
  ConsumerState<AddEditAlbumPage> createState() => _AddEditAlbumPageState();
}

class _AddEditAlbumPageState extends ConsumerState<AddEditAlbumPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _coverUrlController;
  late TextEditingController _artistController;
  late TextEditingController _yearController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.album?.title ?? '');
    _coverUrlController =
        TextEditingController(text: widget.album?.coverUrl ?? '');
    _artistController = TextEditingController(
      text: widget.album?.artistIds.join(', ') ?? '',
    );
    _yearController = TextEditingController(
      text: widget.album?.releaseYear != null && widget.album!.releaseYear > 0
          ? widget.album!.releaseYear.toString()
          : '',
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _coverUrlController.dispose();
    _artistController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _isLoading = true);
    try {
      final repo = ref.read(albumRepositoryImplProvider);
      final artistIds = _artistController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final releaseYear = int.tryParse(_yearController.text.trim()) ?? 0;

      if (widget.album == null) {
        await repo.createAlbum(Album(
          id: '',
          title: _titleController.text.trim(),
          coverUrl: _coverUrlController.text.trim().isNotEmpty
              ? _coverUrlController.text.trim()
              : null,
          artistIds: artistIds,
          releaseYear: releaseYear,
        ));
      } else {
        await repo.updateAlbum(widget.album!.copyWith(
          title: _titleController.text.trim(),
          coverUrl: _coverUrlController.text.trim().isNotEmpty
              ? _coverUrlController.text.trim()
              : null,
          artistIds: artistIds,
          releaseYear: releaseYear,
        ));
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.album != null;
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          isEditing ? 'Sửa Album' : 'Thêm Album Mới',
          style: const TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              ImageUploadField(
                imageUrl: _coverUrlController.text.trim(),
                label: 'Ảnh bìa Album',
                onUploaded: (url) {
                  setState(() {
                    _coverUrlController.text = url;
                  });
                },
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _titleController,
                labelText: 'Tên Album',
                prefixIcon: Icons.album_rounded,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Vui lòng nhập tên album' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _artistController,
                labelText: 'Nghệ sĩ (cách nhau bằng dấu phẩy)',
                prefixIcon: Icons.person_rounded,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _yearController,
                labelText: 'Năm phát hành',
                prefixIcon: Icons.calendar_today_rounded,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              GradientButton(
                onPressed: _isLoading ? null : _save,
                text: isEditing ? 'CẬP NHẬT ALBUM' : 'TẠO ALBUM',
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
