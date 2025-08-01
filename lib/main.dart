import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/saved_book.dart';
import 'package:flutter_application_1/pages/list_page.dart';
import 'package:flutter_application_1/services/book_storage_service.dart';
import 'package:flutter_application_1/widgets/adaptive_image_container.dart';
import 'package:flutter_application_1/widgets/book_result_item.dart';
import 'package:flutter_application_1/widgets/book_search_bar.dart';
import 'package:flutter_application_1/widgets/bottom_navigation_icon.dart';
import 'package:flutter_application_1/widgets/save_book_modal.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    // The Provider creates a single instance of your service.
    Provider<BookStorageService>(
      create: (_) => LocalBookStorageService(),
      child: const BookTrackerApp(),
    ),
  );
}

// Main application widget
class BookTrackerApp extends StatelessWidget {
  const BookTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Track Tales',
      theme: ThemeData(
        textTheme: GoogleFonts.caveatTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      home: const HomePage(),
    );
  }
}

// The main screen of the application - StatefulWidget
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late BookStorageService _storageService;
  late final TextEditingController _quoteController;
  Timer? _debounce;
  SavedBook? _favoriteBook;

  static const Color widgetBackgroundColor = Color(0xFFF8EDDF);
  static const Color textColor = Color(0xFF7A7166);
  static const Color iconColor = Color(0xFFC3BBAF);
  static const Color iconTextColor = Color(0xFF6F655B);

  List<dynamic> _searchResults = [];
  bool _isSearching = false;
  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    // GET the shared service instance from Provider here
    _storageService = Provider.of<BookStorageService>(context, listen: false);
    _quoteController = TextEditingController();
    _quoteController.addListener(_onQuoteChanged);

    // By calling _loadSavedQuote here, we ensure that the widget has been
    // fully initialized and built at least once before we update the controller.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedQuote();
      _loadFavoriteBook();
    });
  }

  void _handleSearchResults(List<dynamic> results) {
    setState(() {
      _searchResults = results;
      _showSearchResults = results.isNotEmpty;
    });
  }

  void _handleLoadingChanged(bool isLoading) {
    setState(() {
      _isSearching = isLoading;
      if (isLoading) {
        _showSearchResults = true; // Show search area when loading
      }
    });
  }

  void _onBookSelected(dynamic book) async {
    // Handle book selection - you can navigate to book details or add to list
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => SaveBookModal(
        book: book,
        storageService: _storageService,
      ),
    );
  }

  Future<void> _loadSavedQuote() async {
    final savedQuote = await _storageService.getQuote();
    debugPrint('Stored quote: $savedQuote');

    // Good practice: check if the widget is still in the widget tree
    // before updating its state after an async operation.
    if (mounted && savedQuote.isNotEmpty) {
      _quoteController.text = savedQuote;
    }
  }

  void _onQuoteChanged() {
    // If a timer is already active, cancel it
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      // Perform the actual save operation here
      debugPrint('Saving quote: ${_quoteController.text}'); // For debugging
      _storageService.saveQuote(_quoteController.text);
    });
  }

  Future<void> _loadFavoriteBook() async {
    final book = await _storageService.getFavoriteBook();
    if (mounted && book != null) {
      setState(() {
        _favoriteBook = book;
      });
    }
  }

  void _onFavoriteBookSelected(SavedBook book) {
    // Save the new favorite
    _storageService.saveFavoriteBook(book);

    // Update the UI
    setState(() {
      _favoriteBook = book;
    });

    // Close the modal
    Navigator.pop(context);
  }

  @override
  void dispose() {
    _quoteController.removeListener(_onQuoteChanged);
    _quoteController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Widget _buildSearchResults() {
    if (_isSearching) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(textColor),
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
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
      itemCount: _searchResults.length,
      itemBuilder: (context, index) {
        final rawBookData = _searchResults[index];
        final bookToDisplay = SavedBook.fromGoogleBooksApi(rawBookData);

        return BookResultItem(
          book: bookToDisplay,
          onTap: () => _onBookSelected(rawBookData),
          storageService: _storageService,
        );
      },
    );
  }

  void _showBookSelectionModal() {
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
            // We pass the scrollController to the list view
            return _buildBookSelectionList(scrollController);
          },
        );
      },
    );
  }

  /// Builds the list of saved books inside the modal, reusing your search logic.
  Widget _buildBookSelectionList(ScrollController scrollController) {
    return FutureBuilder<List<SavedBook>>(
      future: _storageService.getSavedBooks(),
      builder: (context, snapshot) {
        // 1. Loading state (like _isSearching)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white), // Or your textColor
              ),
            ),
          );
        }

        // 2. Error or Empty state (like _searchResults.isEmpty)
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(20),
            child: Center(
              child: Text(
                'You have no saved books to choose from.',
                style: TextStyle(
                  color: Colors.grey, // Or your iconColor
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
          controller: scrollController, // Use the controller from DraggableScrollableSheet
          itemCount: savedBooks.length,
          itemBuilder: (context, index) {
            final book = savedBooks[index];
            return BookResultItem(
              book: book,
              // IMPORTANT: The onTap now calls our new selection handler
              onTap: () => _onFavoriteBookSelected(book),
              storageService: _storageService,
            );
          },
        );
      },
    );
  }

  Widget _buildMainContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        const Text(
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
          onTap: _showBookSelectionModal,
          child: SizedBox(
            width: 150,
            // We check if we have a favorite book with a thumbnail
            child: _favoriteBook?.thumbnail != null
            // --- IF YES: Use our new adaptive widget ---
                ? AdaptiveImageContainer(
              imageUrl: _favoriteBook!.thumbnail!,
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
                  child: _favoriteBook == null
                  // If no book is selected at all, show "add"
                      ? Image.asset(
                    'assets/icons/add.png',
                    width: 60,
                    height: 60,
                  )
                  // If book is selected but has no image, show placeholder icon
                      : const Icon(
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
        const Text(
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
            controller: _quoteController,
            keyboardType: TextInputType.multiline, // Allow multiple lines of text
            minLines: 1, // Start with the height of 1 line
            maxLines: 4, // Expand up to a maximum of 3 lines, then scroll
            maxLength: 110, // Character limit

            style: const TextStyle(
              color: textColor,
              fontSize: 24,
            ),
            decoration: const InputDecoration(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF5E9),
      body: Column(
        children: [
          // Safe area for status bar
          Container(
            height: MediaQuery.of(context).padding.top,
            color: const Color(0xFFFBF5E9),
          ),

          // Search bar at the top
          BookSearchBar(
            onSearchResults: _handleSearchResults,
            onLoadingChanged: _handleLoadingChanged,
            hintText: 'Search books by title or author...',
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),

          // Main content area
          Expanded(
            child: _showSearchResults
                ? SingleChildScrollView(
              child: Column(
                children: [
                  _buildSearchResults(),
                  const SizedBox(height: 20),
                  // Add a button to go back to main content
                  if (!_isSearching)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: TextButton(
                        onPressed: () {
                          setState(() {
                            _showSearchResults = false;
                            _searchResults = [];
                          });
                        },
                        child: const Text(
                          'Back to home',
                          style: TextStyle(
                            color: textColor,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            )
                : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: [
                    _buildMainContent(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),

          // Bottom navigation icons - always visible
          Padding(
            padding: EdgeInsets.only(
              left: 40.0,
              right: 40.0,
              top: 20.0,
              bottom: MediaQuery.of(context).padding.bottom + 20.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                BottomNavigationIcon(
                  imagePath: 'assets/icons/list.png',
                  label: 'List',
                  iconColor: iconTextColor,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ListPage()),
                    );
                  },
                ),
                BottomNavigationIcon(
                  imagePath: 'assets/icons/camera.png',
                  label: 'Scan ISBN',
                  iconColor: iconTextColor,
                  isAddButton: true,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Add Book tapped')),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}