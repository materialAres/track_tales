import 'package:flutter/material.dart';

import '../models/saved_book.dart';
import '../themes/custom_text_theme.dart';
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
    final customTheme = Theme.of(context).extension<CustomTextTheme>()!;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Column(
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
              // NEW: Wrap the content in a Container that will render the shadow.
              child: Container(
                decoration: BoxDecoration(
                  // The borderRadius here ensures the shadow follows the rounded shape.
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 10,
                      spreadRadius: 0.1,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: favoriteBook?.thumbnail != null
                // --- IF YES: Use our new adaptive widget ---
                // AdaptiveImageContainer should already handle clipping its own image to a rounded shape.
                    ? AdaptiveImageContainer(
                  imageUrl: favoriteBook!.thumbnail!,
                  width: 150,
                )
                // --- IF NO: Use the original placeholder logic ---
                // This widget needs to be clipped to the same rounded shape as the shadow.
                    : AspectRatio(
                  aspectRatio: 2 / 3,
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
                      // If a book is selected but has no image, show placeholder icon
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
          ),
          const SizedBox(height: 50),

          // "My favourite quote" Title
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
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.15),
                  blurRadius: 5,
                  spreadRadius: 0.1,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: TextField(
              onEditingComplete: () {
                FocusScope.of(context).unfocus();
              },
              controller: quoteController,
              keyboardType: TextInputType.multiline,
              minLines: 1,
              maxLines: 4,
              maxLength: 110,

              style: customTheme.bodyText.copyWith(color: textColor),
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
      ),
    );
  }
}