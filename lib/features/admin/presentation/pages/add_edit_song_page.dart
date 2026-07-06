import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/song_model.dart';
import '../controllers/admin_controller.dart';
import '../../../auth/presentation/widgets/custom_text_field.dart';
import '../../../auth/presentation/widgets/gradient_button.dart';
import '../../../player/domain/entities/album.dart';
import '../../../player/data/repositories/album_repository_impl.dart';

final _albumsForPickerProvider = FutureProvider<List<Album>>((ref) async {
  return ref.read(albumRepositoryImplProvider).getAllAlbums();
});

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
  String? _selectedAlbumId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.song?.title ?? '');
    _artistController = TextEditingController(text: widget.song?.artist ?? '');
    _audioUrlController = TextEditingController(
      text: widget.song?.audioUrl ?? '',
    );
    _coverUrlController = TextEditingController(
      text: widget.song?.coverUrl ?? '',
    );
    _lyricsController = TextEditingController(text: widget.song?.lyrics ?? '');
    _selectedAlbumId = widget.song?.albumId;
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
            lyrics: _lyricsController.text.trim().isNotEmpty
                ? _lyricsController.text.trim()
                : null,
            albumId: _selectedAlbumId,
          );
          await controller.addSong(newSong);
        } else {
          final updatedSong = widget.song!.copyWith(
            title: _titleController.text.trim(),
            artist: _artistController.text.trim(),
            audioUrl: _audioUrlController.text.trim(),
            coverUrl: _coverUrlController.text.trim(),
            lyrics: _lyricsController.text.trim().isNotEmpty
                ? _lyricsController.text.trim()
                : null,
            albumId: _selectedAlbumId,
          );
          await controller.updateSong(updatedSong);
        }
        if (mounted) {
          Navigator.pop(context);
        }
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
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.song != null;
    final albumsAsync = ref.watch(_albumsForPickerProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0F2027),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(isEditing ? 'Sửa Bài Hát' : 'Thêm Bài Hát Mới'),
        iconTheme: const IconThemeData(color: Colors.white),
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
                validator: (val) =>
                    val == null || val.isEmpty ? 'Vui lòng nhập tên' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _artistController,
                labelText: 'Nghệ sĩ',
                prefixIcon: Icons.person,
                validator: (val) =>
                    val == null || val.isEmpty ? 'Vui lòng nhập nghệ sĩ' : null,
              ),
              const SizedBox(height: 16),
              CustomTextField(
                controller: _audioUrlController,
                labelText: 'Link nhạc (Audio URL)',
                prefixIcon: Icons.link,
                validator: (val) => val == null || val.isEmpty
                    ? 'Vui lòng nhập link nhạc'
                    : null,
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
              const SizedBox(height: 16),
              // Album picker
              albumsAsync.when(
                loading: () => const SizedBox(
                  height: 56,
                  child: Center(
                    child: LinearProgressIndicator(color: Colors.cyanAccent),
                  ),
                ),
                error: (_, _) => const SizedBox.shrink(),
                data: (albums) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.1),
                        width: 1.5,
                      ),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String?>(
                        value: _selectedAlbumId,
                        isExpanded: true,
                        dropdownColor: const Color(0xFF1E2035),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                        ),
                        hint: Row(
                          children: [
                            const Icon(
                              Icons.album_rounded,
                              color: Colors.white70,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Chọn Album (không bắt buộc)',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                        items: [
                          const DropdownMenuItem<String?>(
                            value: null,
                            child: Text(
                              '-- Không thuộc Album --',
                              style: TextStyle(color: Colors.white54),
                            ),
                          ),
                          ...albums.map(
                            (album) => DropdownMenuItem<String?>(
                              value: album.id,
                              child: Text(
                                album.title,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => _selectedAlbumId = value);
                        },
                      ),
                    ),
                  );
                },
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
