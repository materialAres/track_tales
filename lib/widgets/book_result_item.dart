import 'package:flutter/material.dart';

import '../services/book_storage_service.dart';

class BookResultItem extends StatefulWidget {
  final dynamic book;
  final VoidCallback? onTap;
  final BookStorageService? storageService;

  const BookResultItem({
    Key? key,
    required this.book,
    this.onTap,
    this.storageService,
  }) : super(key: key);

  @override
  State<BookResultItem> createState() => _BookResultItemState();
}

// Optional: A simple book result item widget you can also reuse
class _BookResultItemState extends State<BookResultItem> {
  bool _isBookSaved = false;
  bool _isChecking = true;

  @override
  void initState() {
    super.initState();
    _checkIfBookIsSaved();
  }

  Future<void> _checkIfBookIsSaved() async {
    if (widget.book == null) {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
      return;
    }

    final bookId = widget.book['id'] ?? '';
    if (bookId.isNotEmpty) {
      try {
        final isSaved = await widget.storageService!.isBookSaved(bookId);
        if (mounted) {
          setState(() {
            _isBookSaved = isSaved;
          });
        }
      } catch (e) {
        // Optionally, handle the error, e.g., show a snackbar.
        debugPrint('Error checking if book is saved: $e');
        if (mounted) {
          setState(() {
            // Decide what the state should be on error.
            // For example, you might want to set _isBookSaved to false.
            _isBookSaved = false;
          });
        }
      } finally {
        // This block will always execute after the try/catch,
        // even if the widget is unmounted in the middle of the await.
        if (mounted) {
          setState(() {
            _isChecking = false;
          });
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isChecking = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final volumeInfo = widget.book['volumeInfo'] ?? {};
    final title = volumeInfo['title'] ?? 'No title';
    final authors = volumeInfo['authors'] ?? [];
    final imageLinks = volumeInfo['imageLinks'];
    final thumbnail = imageLinks?['thumbnail'] ?? imageLinks?['smallThumbnail'];

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F0),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book cover
            Container(
              width: 60,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[300],
              ),
              child: thumbnail != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  thumbnail,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.book, color: Colors.grey);
                  },
                ),
              )
                  : const Icon(Icons.book, color: Colors.grey),
            ),
            const SizedBox(width: 16),
            // Book info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2D3436),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (authors.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'by ${authors.join(', ')}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            if (_isChecking)
              const SizedBox(
                width: 30,
                height: 30,
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
                  ),
                ),
              )
            else if (_isBookSaved)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Image.asset(
                  'assets/icons/done.png',
                  width: 20,
                  height: 20,
                ),
              ),
          ],
        ),
      ),
    );
  }
}