import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageUploadField extends StatefulWidget {
  final String? imageUrl;
  final String label;
  final ValueChanged<String> onUploaded;

  const ImageUploadField({
    super.key,
    this.imageUrl,
    required this.label,
    required this.onUploaded,
  });

  @override
  State<ImageUploadField> createState() => _ImageUploadFieldState();
}

class _ImageUploadFieldState extends State<ImageUploadField> {
  bool _isUploading = false;
  String? _currentUrl;
  Uint8List? _localImageBytes;

  @override
  void initState() {
    super.initState();
    _currentUrl = widget.imageUrl;
  }

  @override
  void didUpdateWidget(covariant ImageUploadField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageUrl != oldWidget.imageUrl) {
      setState(() {
        _currentUrl = widget.imageUrl;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 85,
    );

    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();

    if (kIsWeb) {
      final base64String = base64Encode(bytes);
      String mimeType = 'image/jpeg';
      final nameLower = pickedFile.name.toLowerCase();
      if (nameLower.endsWith('.png')) {
        mimeType = 'image/png';
      } else if (nameLower.endsWith('.gif')) {
        mimeType = 'image/gif';
      } else if (nameLower.endsWith('.webp')) {
        mimeType = 'image/webp';
      }
      final uploadedUrl = 'data:$mimeType;base64,$base64String';
      setState(() {
        _localImageBytes = bytes;
        _currentUrl = uploadedUrl;
        _isUploading = false;
      });
      widget.onUploaded(uploadedUrl);
      return;
    }

    setState(() {
      _localImageBytes = bytes;
      _isUploading = true;
    });

    try {
      final dio = Dio();
      final fileName = pickedFile.name;
      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: fileName),
      });

      final uploadUrl = 'https://agent.api.eternalai.org/api/users/upload';
      final response = await dio.post(uploadUrl, data: formData);

      if (response.data != null) {
        final resData = response.data;
        if (resData['error'] != null) {
          throw Exception(resData['error']['message'] ?? 'Upload failed');
        }

        final String? uploadedUrl =
            resData['data'] ?? resData['result'] ?? resData['url'];
        if (uploadedUrl == null || uploadedUrl.isEmpty) {
          throw Exception('Không lấy được URL hình ảnh từ phản hồi');
        }

        setState(() {
          _currentUrl = uploadedUrl;
          _isUploading = false;
        });

        widget.onUploaded(uploadedUrl);
      } else {
        throw Exception('Phản hồi trống từ máy chủ');
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
        _localImageBytes = null;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải ảnh lên: $e'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (_localImageBytes != null) {
      imageProvider = MemoryImage(_localImageBytes!);
    } else if (_currentUrl != null && _currentUrl!.isNotEmpty) {
      imageProvider = NetworkImage(_currentUrl!);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _isUploading ? null : _pickAndUploadImage,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 160,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
                width: 1.5,
              ),
              image: imageProvider != null
                  ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                  : null,
            ),
            child: Stack(
              children: [
                if (imageProvider != null)
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.black26,
                    ),
                  ),
                Center(
                  child: _isUploading
                      ? const CircularProgressIndicator(
                          color: Colors.cyanAccent,
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              imageProvider != null
                                  ? Icons.change_circle_rounded
                                  : Icons.add_photo_alternate_rounded,
                              color: Colors.white70,
                              size: 40,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              imageProvider != null
                                  ? 'Thay đổi hình ảnh'
                                  : 'Chọn hình ảnh tải lên',
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
