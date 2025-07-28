// lib/widgets/save_book_modal.dart
import 'package:flutter/material.dart';
import '../models/saved_book.dart';
import '../services/book_storage_service.dart';

class SaveBookModal extends StatelessWidget {
  final dynamic book;
  final BookStorageService storageService;

  const SaveBookModal({
    Key? key,
    required this.book,
    required this.storageService,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final volumeInfo = book['volumeInfo'] ?? {};
    final title = volumeInfo['title'] ?? 'No title';
    final authors = volumeInfo['authors'] ?? [];
    final imageLinks = volumeInfo['imageLinks'];
    final thumbnail = imageLinks?['thumbnail'] ?? imageLinks?['smallThumbnail'];

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFFF8EDDF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Book preview
            Row(
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
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Question text
            const Text(
              'Do you want to save this book to your list?',
              style: TextStyle(
                fontSize: 18,
                color: Color(0xFF7A7166),
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                // No button
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                        side: const BorderSide(color: Color(0xFFC3BBAF)),
                      ),
                    ),
                    child: const Text(
                      'No',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF7A7166),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Yes button
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      try {
                        final savedBook = SavedBook.fromGoogleBooksApi(book);
                        final success = await storageService.saveBook(savedBook);

                        if (context.mounted) {
                          Navigator.of(context).pop(true);

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success
                                    ? 'Book saved successfully!'
                                    : 'Book is already in your list or failed to save',
                              ),
                              backgroundColor: success
                                  ? Colors.green.shade400
                                  : Colors.orange.shade400,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          Navigator.of(context).pop(false);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error saving book: ${e.toString()}'),
                              backgroundColor: Colors.red.shade400,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7A7166),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Yes',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}