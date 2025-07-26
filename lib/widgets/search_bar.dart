import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

class BookSearchBar extends StatefulWidget {
  final Function(List<dynamic>) onSearchResults;
  final Function(bool) onLoadingChanged;
  final String hintText;
  final EdgeInsets margin;

  const BookSearchBar({
    super.key,
    required this.onSearchResults,
    required this.onLoadingChanged,
    this.hintText = 'Search books by title or author...',
    this.margin = const EdgeInsets.all(20),
  });

  @override
  State<BookSearchBar> createState() => _BookSearchBarState();
}

class _BookSearchBarState extends State<BookSearchBar> {
  final TextEditingController _searchController = TextEditingController();
  final Dio _dio = Dio();
  bool _isLoading = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchBooks(String query) async {
    if (query.trim().isEmpty) {
      widget.onSearchResults([]);
      return;
    }

    setState(() {
      _isLoading = true;
    });
    widget.onLoadingChanged(true);

    try {
      final response = await _dio.get(
        'https://www.googleapis.com/books/v1/volumes',
        queryParameters: {
          'q': query,
          'maxResults': 20,
          'printType': 'books',
          'orderBy': 'relevance',
        },
      );

      List<dynamic> results = [];
      if (response.data['items'] != null) {
        results = response.data['items'];
      }

      widget.onSearchResults(results);
    } catch (e) {
      // Handle error - you can customize this based on your needs
      widget.onSearchResults([]);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching books: ${e.toString()}'),
            backgroundColor: Colors.red.shade300,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
      widget.onLoadingChanged(false);
    }
  }

  void _clearSearch() {
    _searchController.clear();
    widget.onSearchResults([]);
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: widget.margin,
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
      child: TextField(
        controller: _searchController,
        style: const TextStyle(
          fontSize: 16,
          color: Color(0xFF2D3436),
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
          prefixIcon: _isLoading
              ? const Padding(
            padding: EdgeInsets.all(12.0),
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C7B7F)),
              ),
            ),
          )
              : const Icon(
            Icons.search,
            color: Colors.grey,
            size: 24,
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(
              Icons.clear,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: _clearSearch,
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onChanged: (value) {
          setState(() {}); // Rebuild to show/hide clear button
        },
        onSubmitted: _searchBooks,
        textInputAction: TextInputAction.search,
      ),
    );
  }
}

// Optional: A simple book result item widget you can also reuse
class BookResultItem extends StatelessWidget {
  final dynamic book;
  final VoidCallback? onTap;

  const BookResultItem({
    super.key,
    required this.book,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final volumeInfo = book['volumeInfo'] ?? {};
    final title = volumeInfo['title'] ?? 'No title';
    final authors = volumeInfo['authors'] ?? [];
    final imageLinks = volumeInfo['imageLinks'];
    final thumbnail = imageLinks?['thumbnail'] ?? imageLinks?['smallThumbnail'];

    return GestureDetector(
      onTap: onTap,
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
          ],
        ),
      ),
    );
  }
}