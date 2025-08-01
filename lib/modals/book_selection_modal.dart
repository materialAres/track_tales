import 'package:flutter/material.dart';

import '../models/saved_book.dart';
import '../services/book_storage_service.dart';
import '../widgets/book_selection_list.dart';

class BookSelectionModal {
  static void show({
    required BuildContext context,
    required Function(SavedBook) onBookSelected,
    required BookStorageService storageService,
    required Color textColor,
    required Color iconColor,
  }) {
    showModalBottomSheet(
      context: context,
      // Allow the modal to take up more screen space if needed
      isScrollControlled: true,
      // Give it a nice shape
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        // Constrain the height to avoid covering the whole screen
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.6, // Start at 60% of the screen
          minChildSize: 0.3,     // Allow shrinking to 30%
          maxChildSize: 0.9,     // Allow expanding to 90%
          builder: (context, scrollController) {
            return BookSelectionList(
              scrollController: scrollController,
              onBookSelected: onBookSelected,
              storageService: storageService,
              textColor: textColor,
              iconColor: iconColor,
            );
          },
        );
      },
    );
  }
}