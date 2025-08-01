import 'package:flutter/material.dart';

import '../models/saved_book.dart';
import 'adaptive_image_container.dart';

class MainContent extends StatelessWidget {
  final SavedBook? favoriteBook;
  final TextEditingController quoteController;
  final VoidCallback onBookSelectionTap;
  final Color textColor;
  final Color iconColor;
  final Color widgetBackgroundColor;

  const MainContent({
    super.key,
    required this.favoriteBook,
    required this.quoteController,
    required this.onBookSelectionTap,
    required this.textColor,
    required this.iconColor,
    required this.widgetBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        Text(
          'My best pick',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 20),

        // Image container
        GestureDetector(
          onTap: onBookSelectionTap,
          child: SizedBox(
            width: 150,
            // We check if we have a favorite book with a thumbnail
            child: favoriteBook?.thumbnail != null
            // --- IF YES: Use our new adaptive widget ---
                ? AdaptiveImageContainer(
              imageUrl: favoriteBook!.thumbnail!,
              width: 150,
            )
            // --- IF NO: Use the original placeholder logic ---
                : AspectRatio(
              aspectRatio: 2 / 3, // Default shape for placeholder
              child: Container(
                decoration: BoxDecoration(
                  color: widgetBackgroundColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: favoriteBook == null
                  // If no book is selected at all, show "add"
                      ? Image.asset(
                    'assets/icons/add.png',
                    width: 60,
                    height: 60,
                  )
                  // If book is selected but has no image, show placeholder icon
                      : Icon(
                    Icons.book_outlined,
                    color: iconColor,
                    size: 80,
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 50),

        // "My number one quote" Title
        Text(
          'My favourite quote',
          style: TextStyle(
            fontSize: 42,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        const SizedBox(height: 20),

        // Text field for the quote
        Container(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
          decoration: BoxDecoration(
            color: widgetBackgroundColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: TextField(
            controller: quoteController,
            keyboardType: TextInputType.multiline, // Allow multiple lines of text
            minLines: 1, // Start with the height of 1 line
            maxLines: 4, // Expand up to a maximum of 3 lines, then scroll
            maxLength: 110, // Character limit

            style: TextStyle(
              color: textColor,
              fontSize: 24,
            ),
            decoration: InputDecoration(
              hintText: 'Type here...',
              hintStyle: TextStyle(
                color: iconColor,
                fontSize: 24,
              ),
              border: InputBorder.none, // Removes the underline
              counterText: "", // Hides the default "0/200" counter
            ),
          ),
        ),
      ],
    );
  }
}