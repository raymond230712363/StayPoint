import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../api_service.dart';
import '../constants/themes.dart';

class ReviewFormScreen extends StatefulWidget {
  final Map<String, dynamic> booking;
  final String email;
  final Map<String, dynamic>? review;

  const ReviewFormScreen({
    super.key,
    required this.booking,
    required this.email,
    this.review,
  });

  @override
  State<ReviewFormScreen> createState() => _ReviewFormScreenState();
}

class _ReviewFormScreenState extends State<ReviewFormScreen> {
  final _commentController = TextEditingController();
  final _picker = ImagePicker();
  int _rating = 5;
  XFile? _photo;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    if (widget.review != null) {
      _rating = widget.review!['rating'] ?? 5;
      _commentController.text = widget.review!['comment'] ?? '';
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
    );
    if (image != null) {
      setState(() => _photo = image);
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    final Map<String, dynamic> result;
    if (widget.review != null) {
      result = await ApiService.updateReview(
        email: widget.email,
        reviewId: widget.review!['id'],
        rating: _rating,
        comment: _commentController.text,
        photoPath: _photo?.path,
      );
    } else {
      result = await ApiService.createReview(
        email: widget.email,
        bookingId: widget.booking['id'],
        rating: _rating,
        comment: _commentController.text,
        photoPath: _photo?.path,
      );
    }
    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.review != null ? 'Review updated!' : 'Review submitted!'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message'] ?? 'Gagal submit review'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final room = Map<String, dynamic>.from(widget.booking['room'] ?? widget.review?['room'] ?? {});
    return Scaffold(
      backgroundColor: AppColors.primaryBg,
      appBar: AppBar(
        backgroundColor: AppColors.primaryBg,
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(widget.review != null ? 'Edit Review' : 'Write Review'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      _image(room),
                      height: 64,
                      width: 64,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 64,
                        width: 64,
                        color: Colors.white12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          room['room_name'] ?? '-',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          room['hotel']?['name'] ?? '-',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.62),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Rate your experience',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(5, (index) {
                final star = index + 1;
                return IconButton(
                  onPressed: () => setState(() => _rating = star),
                  icon: Icon(
                    star <= _rating
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: Colors.amber,
                    size: 30,
                  ),
                );
              }),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              minLines: 4,
              maxLines: 7,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Write your experience here...',
                hintStyle: TextStyle(color: Colors.white.withOpacity(0.45)),
                filled: true,
                fillColor: Colors.white.withOpacity(0.1),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            if (_photo == null && widget.review?['photo'] != null) ...[
              const SizedBox(height: 16),
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _getPhotoUrl(widget.review!['photo']),
                    height: 100,
                    width: 100,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const SizedBox(),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.white,
                side: BorderSide(color: Colors.white.withOpacity(0.25)),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _pickPhoto,
              icon: const Icon(Icons.add_photo_alternate_rounded),
              label: Text(_photo == null
                  ? (widget.review?['photo'] != null ? 'Change Photo' : 'Add Photo')
                  : 'Photo Selected'),
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 54,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.buttonBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _isSubmitting ? null : _submit,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        widget.review != null ? 'Update Review' : 'Submit Review',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _image(Map<String, dynamic> room) {
    final images = List<Map<String, dynamic>>.from(room['images'] ?? []);
    if (images.isNotEmpty) return images.first['image_url'];
    return room['hotel']?['thumbnail'] ??
        'https://images.unsplash.com/photo-1566073771259-6a8506099945?w=400&q=80';
  }

  String _getPhotoUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    if (path.startsWith('http://') || path.startsWith('https://')) {
      return path;
    }
    final uri = Uri.parse(ApiService.baseUrl);
    final host = '${uri.scheme}://${uri.host}:${uri.port}';
    return '$host$path';
  }
}
