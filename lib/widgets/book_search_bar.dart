import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../themes/custom_text_theme.dart';

class BookSearchBar extends StatefulWidget {
  final Function(List<dynamic>) onSearchResults;
  final Function(bool) onLoadingChanged;
  final TextEditingController searchController;
  final String hintText;
  final EdgeInsets margin;

  const BookSearchBar({
    Key? key,
    required this.onSearchResults,
    required this.onLoadingChanged,
    required this.searchController,
    this.hintText = 'Search books by title or author...',
    this.margin = const EdgeInsets.all(20),
  }) : super(key: key);

  @override
  State<BookSearchBar> createState() => _BookSearchBarState();
}

class _BookSearchBarState extends State<BookSearchBar> {
  final FocusNode _focusNode = FocusNode();
  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });

    widget.searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    widget.searchController.clear();
    widget.searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _searchBooks(String query) async {
    if (query.trim().isEmpty) {
      widget.onSearchResults([]);
      return;
    }

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
      widget.onLoadingChanged(false);
    }
  }

  void _clearSearch() {
    widget.searchController.clear();
    widget.onSearchResults([]);
    _focusNode.unfocus();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final bool showClearButton = _focusNode.hasFocus && widget.searchController.text.isNotEmpty;
    final bool showBackButton = _focusNode.hasFocus;
    final customTheme = Theme.of(context).extension<CustomTextTheme>()!;

    return Container(
      margin: widget.margin,
      decoration: BoxDecoration(
        color: const Color(0xFFf0f3f5),
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
        controller: widget.searchController,
        focusNode: _focusNode,
        style: customTheme.bodyText.copyWith(
          color: Colors.grey[600],
              fontSize: 16
        ),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: const TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: Colors.grey,
            size: 24,
          ),
          suffixIcon: showClearButton
              ? IconButton(
            icon: const Icon(
              Icons.clear,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: _clearSearch,
          ) : showBackButton ? IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: _clearSearch,
          ) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        onSubmitted: _searchBooks,
        textInputAction: TextInputAction.search,
      ),
    );
  }
}
