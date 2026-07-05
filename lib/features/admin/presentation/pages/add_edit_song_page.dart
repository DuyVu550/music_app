import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/song_model.dart';
import '../controllers/admin_controller.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';

class AddEditSongPage extends ConsumerStatefulWidget {
  final SongModel? song;

  const AddEditSongPage({super.key, this.song});

  @override
  ConsumerState<AddEditSongPage> createState() => _AddEditSongPageState();
}

class _AddEditSongPageState extends ConsumerState<AddEditSongPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _artistController;
  late TextEditingController _audioUrlController;
  late TextEditingController _coverUrlController;
  late TextEditingController _lyricsController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.song?.title ?? '');
    _artistController = TextEditingController(text: widget.song?.artist ?? '');
    _audioUrlController = TextEditingController(text: widget.song?.audioUrl ?? '');
    _coverUrlController = TextEditingController(text: widget.song?.coverUrl ?? '');
    _lyricsController = TextEditingController(text: widget.song?.lyrics ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _audioUrlController.dispose();
    _coverUrlController.dispose();
    _lyricsController.dispose();
    super.dispose();
  }

  Future<void> _saveSong() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      try {
        final controller = ref.read(adminControllerProvider);
        if (widget.song == null) {
          final newSong = SongModel(
            id: '',
            title: _titleController.text.trim(),
            artist: _artistController.text.trim(),
            audioUrl: _audioUrlController.text.trim(),
            coverUrl: _coverUrlController.text.trim(),
            createdAt: DateTime.now(),
            lyrics: _lyricsController.text.trim().isNotEmpty ? _lyricsController.text.trim() : null,
          );
          await controller.addSong(newSong);
        } else {
          final updatedSong = widget.song!.copyWith(
            title: _titleController.text.trim(),
            artist: _artistController.text.trim(),
            audioUrl: _audioUrlController.text.trim(),
            coverUrl: _coverUrlController.text.trim(),
            lyrics: _lyricsController.text.trim().isNotEmpty ? _lyricsController.text.trim() : null,
          );
          await controller.updateSong(updatedSong);
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
    final isEditing = widget.song != null;
    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(isEditing ? 'Sửa Bài Hát' : 'Thêm Bài Hát Mới'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              CustomTextField(
                controller: _titleController,
                labelText: 'Tên bài hát',
                prefixIcon: Icons.music_note,
                validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _artistController,
                labelText: 'Nghệ sĩ',
                prefixIcon: Icons.person,
                validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập nghệ sĩ' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _audioUrlController,
                labelText: 'Link nhạc (Audio URL)',
                prefixIcon: Icons.link,
                validator: (val) => val == null || val.isEmpty ? 'Vui lòng nhập link nhạc' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _coverUrlController,
                labelText: 'Link ảnh bìa (Cover URL)',
                prefixIcon: Icons.image,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _lyricsController,
                labelText: 'Lời bài hát (LRC hoặc văn bản thô)',
                prefixIcon: Icons.text_snippet_rounded,
                maxLines: 5,
              ),
              const SizedBox(height: 32),
              GradientButton(
                onPressed: _isLoading ? null : _saveSong,
                text: 'LƯU BÀI HÁT',
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
