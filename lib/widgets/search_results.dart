import 'package:flutter/material.dart';

import '../models/saved_book.dart';
import '../services/book_storage_service.dart';
import 'book_result_item.dart';

class SearchResults extends StatelessWidget {
  final bool isSearching;
  final List<dynamic> searchResults;
  final Function(dynamic) onBookSelected;
  final BookStorageService storageService;
  final Color textColor;
  final Color iconColor;

  const SearchResults({
    super.key,
    required this.isSearching,
    required this.searchResults,
    required this.onBookSelected,
    required this.storageService,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    if (isSearching) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
          ),
        ),
      );
    }

    if (searchResults.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(20),
        child: Center(
          child: Text(
            'No books found. Try a different search term.',
            style: TextStyle(
              color: iconColor,
              fontSize: 18,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        final rawBookData = searchResults[index];
        final bookToDisplay = SavedBook.fromGoogleBooksApi(rawBookData);

        return BookResultItem(
          book: bookToDisplay,
          onTap: () => onBookSelected(rawBookData),
          storageService: storageService,
        );
      },
    );
  }
}