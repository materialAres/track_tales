import 'package:flutter/material.dart';

import '../models/saved_book.dart';
import '../services/book_storage_service.dart';
import 'book_result_item.dart';

class BookSelectionList extends StatelessWidget {
  final ScrollController scrollController;
  final Function(SavedBook) onBookSelected;
  final BookStorageService storageService;
  final Color textColor;
  final Color iconColor;

  const BookSelectionList({
    super.key,
    required this.scrollController,
    required this.onBookSelected,
    required this.storageService,
    required this.textColor,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<SavedBook>>(
      future: storageService.getSavedBooks(),
      builder: (context, snapshot) {
        // 1. Loading state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(textColor),
              ),
            ),
          );
        }

        // 2. Error or Empty state
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(20),
            child: Center(
              child: Text(
                'You have no saved books to choose from.',
                style: TextStyle(
                  color: iconColor,
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        // 3. Success state: Build the list
        final savedBooks = snapshot.data!;
        return ListView.builder(
          controller: scrollController,
          itemCount: savedBooks.length,
          itemBuilder: (context, index) {
            final book = savedBooks[index];
            return BookResultItem(
              book: book,
              onTap: () => onBookSelected(book),
              storageService: storageService,
            );
          },
        );
      },
    );
  }
}