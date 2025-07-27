import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/book_storage_service.dart';
import 'package:provider/provider.dart';

class ListPage extends StatefulWidget {
  const ListPage({super.key});

  @override
  State<ListPage> createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  late BookStorageService _storageService;
  List<SavedBook> _savedBooks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _storageService = Provider.of<BookStorageService>(context, listen: false);
    _loadSavedBooks();
  }

  Future<void> _loadSavedBooks() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final books = await _storageService.getSavedBooks();
      setState(() {
        _savedBooks = books;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading books: ${e.toString()}'),
            backgroundColor: Colors.red.shade400,
          ),
        );
      }
    }
  }

  Future<void> _removeBook(SavedBook book) async {
    // Show confirmation dialog
    final shouldRemove = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: const Color(0xFFF8EDDF),
        title: const Text(
          'Remove Book',
          style: TextStyle(
            color: Color(0xFF7A7166),
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to remove "${book.title}" from your list?',
          style: const TextStyle(
            color: Color(0xFF7A7166),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF7A7166)),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade400,
            ),
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (shouldRemove == true) {
      final success = await _storageService.removeBook(book.id);
      if (success) {
        await _loadSavedBooks(); // Refresh the list
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Book removed successfully'),
              backgroundColor: Colors.green.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to remove book'),
              backgroundColor: Colors.red.shade400,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    }
  }

  Widget _buildBookItem(SavedBook book) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8EDDF),
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
            child: book.thumbnail != null
                ? ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                book.thumbnail!,
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
                  book.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (book.authors.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    'by ${book.authors.join(', ')}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  'Saved on ${_formatDate(book.savedAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          ),
          // Remove button
          IconButton(
            onPressed: () => _removeBook(book),
            icon: const Icon(
              Icons.delete_outline,
              color: Colors.red,
              size: 20,
            ),
            tooltip: 'Remove book',
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Books List'),
        backgroundColor: const Color(0xFFFBF5E9),
        foregroundColor: const Color(0xFF7A7166),
        actions: [
          IconButton(
            onPressed: _loadSavedBooks,
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
          ),
        ],
      ),
      backgroundColor: const Color(0xFFFBF5E9),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7A7166)),
        ),
      )
          : _savedBooks.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_books_outlined,
              size: 80,
              color: Color(0xFFC3BBAF),
            ),
            SizedBox(height: 16),
            Text(
              'No books saved yet',
              style: TextStyle(
                fontSize: 24,
                color: Color(0xFF7A7166),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Search and save books to see them here',
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFFC3BBAF),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      )
          : Column(
        children: [
          // Header with book count
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text(
                  '${_savedBooks.length} book${_savedBooks.length != 1 ? 's' : ''} saved',
                  style: const TextStyle(
                    fontSize: 18,
                    color: Color(0xFF7A7166),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          // Books list
          Expanded(
            child: ListView.builder(
              itemCount: _savedBooks.length,
              itemBuilder: (context, index) {
                return _buildBookItem(_savedBooks[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
}