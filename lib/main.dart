import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/saved_book.dart';
import 'package:flutter_application_1/pages/list_page.dart';
import 'package:flutter_application_1/services/book_storage_service.dart';
import 'package:flutter_application_1/themes/custom_text_theme.dart';
import 'package:flutter_application_1/widgets/book_search_bar.dart';
import 'package:flutter_application_1/widgets/bottom_navigation_icon.dart';
import 'package:flutter_application_1/widgets/isbn_scanner_screen.dart';
import 'package:flutter_application_1/widgets/main_content.dart';
import 'package:flutter_application_1/widgets/save_book_modal.dart';
import 'package:flutter_application_1/widgets/search_results.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'modals/book_selection_modal.dart';

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
        // Set Caveat as the default font family
        textTheme: GoogleFonts.caveatTextTheme(
          Theme.of(context).textTheme,
        ),
        // You can also define custom text styles here
        extensions: <ThemeExtension<dynamic>>[
          CustomTextTheme(
            boldText: GoogleFonts.comicNeue(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            bodyText: GoogleFonts.comicNeue(
              fontSize: 20,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
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

  static const Color widgetBackgroundColor = Color(0xFFf2dbb6);
  static const Color textColor = Color(0xFF7A7166);
  static const Color iconColor = Color(0xFFC3BBAF);
  static const Color iconTextColor = Color(0xFF6F655B);

  final TextEditingController _searchController = TextEditingController();

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
        _showSearchResults = true;
      }
    });
  }

  void _onBookSelected(dynamic book) async {
    await showDialog<bool>(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf5ead3),
      body: Column(
        children: [
          // Safe area for status bar
          Container(
            height: MediaQuery.of(context).padding.top,
            color: const Color(0xFFf5ead3),
          ),

          // Search bar at the top
          BookSearchBar(
            onSearchResults: _handleSearchResults,
            onLoadingChanged: _handleLoadingChanged,
            searchController: _searchController,
            hintText: 'Search books by title or author...',
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          ),

          Expanded(
            child: _showSearchResults
                ? SingleChildScrollView(
              child: Column(
                children: [
                  SearchResults(
                    isSearching: _isSearching,
                    searchResults: _searchResults,
                    onBookSelected: _onBookSelected,
                    storageService: _storageService,
                    iconColor: iconColor,
                    textColor: textColor,
                  ),
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
                    MainContent(
                      favoriteBook: _favoriteBook,
                      quoteController: _quoteController,
                      onBookSelectionTap: () => BookSelectionModal.show(
                        context: context,
                        onBookSelected: _onFavoriteBookSelected,
                        storageService: _storageService,
                        textColor: textColor,
                        iconColor: iconColor,
                      ),
                      textColor: textColor,
                      iconColor: iconColor,
                      widgetBackgroundColor: widgetBackgroundColor,
                    ),
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
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const ListPage()),
                    );

                    if (mounted) {
                      setState(() {
                        _showSearchResults = false;
                        _searchResults = [];
                        _searchController.clear();
                      });
                    }
                  },
                ),
                BottomNavigationIcon(
                  imagePath: 'assets/icons/camera.png',
                  label: 'Scan ISBN',
                  iconColor: iconTextColor,
                  isAddButton: true,
                  onTap: () async {
                    // Navigate to ISBN scanner
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => ISBNScannerScreen(
                          onBookFound: (bookData) async {
                            try {
                              // Convert Google Books API data to SavedBook
                              final savedBook = SavedBook.fromGoogleBooksApi(bookData);

                              // Save the book
                              final success = await _storageService.saveBook(savedBook);

                              if (success) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Book "${savedBook.title}" added successfully!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Book is already in your library'),
                                    backgroundColor: Colors.orange,
                                  ),
                                );
                              }
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Error adding book: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                    );

                    if (mounted) {
                      setState(() {
                        _showSearchResults = false;
                        _searchResults = [];
                        _searchController.clear();
                      });
                    }
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