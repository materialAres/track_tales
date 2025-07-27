import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../services/book_storage_service.dart';

class BookSearchBar extends StatefulWidget {
  final Function(List<dynamic>) onSearchResults;
  final Function(bool) onLoadingChanged;
  final String hintText;
  final EdgeInsets margin;

  const BookSearchBar({
    Key? key,
    required this.onSearchResults,
    required this.onLoadingChanged,
    this.hintText = 'Search books by title or author...',
    this.margin = const EdgeInsets.all(20),
  }) : super(key: key);

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
