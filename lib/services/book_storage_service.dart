// lib/services/book_storage_service.dart
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// Book model for easier data handling
class SavedBook {
  final String id;
  final String title;
  final List<String> authors;
  final String? thumbnail;
  final String? description;
  final DateTime savedAt;

  SavedBook({
    required this.id,
    required this.title,
    required this.authors,
    this.thumbnail,
    this.description,
    required this.savedAt,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'authors': authors,
      'thumbnail': thumbnail,
      'description': description,
      'savedAt': savedAt.toIso8601String(),
    };
  }

  // Create from JSON
  factory SavedBook.fromJson(Map<String, dynamic> json) {
    return SavedBook(
      id: json['id'],
      title: json['title'],
      authors: List<String>.from(json['authors']),
      thumbnail: json['thumbnail'],
      description: json['description'],
      savedAt: DateTime.parse(json['savedAt']),
    );
  }

  // Create from Google Books API response
  factory SavedBook.fromGoogleBooksApi(dynamic bookData) {
    final volumeInfo = bookData['volumeInfo'] ?? {};
    final imageLinks = volumeInfo['imageLinks'];

    return SavedBook(
      id: bookData['id'] ?? '',
      title: volumeInfo['title'] ?? 'No title',
      authors: List<String>.from(volumeInfo['authors'] ?? []),
      thumbnail: imageLinks?['thumbnail'] ?? imageLinks?['smallThumbnail'],
      description: volumeInfo['description'],
      savedAt: DateTime.now(),
    );
  }
}

// Storage service interface - makes Firebase migration easier
abstract class BookStorageService {
  Future<List<SavedBook>> getSavedBooks();
  Future<bool> saveBook(SavedBook book);
  Future<bool> removeBook(String bookId);
  Future<bool> isBookSaved(String bookId);
}

// Local storage implementation using SharedPreferences
class LocalBookStorageService implements BookStorageService {
  static const String _savedBooksKey = 'saved_books';

  @override
  Future<List<SavedBook>> getSavedBooks() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final booksJson = prefs.getStringList(_savedBooksKey) ?? [];

      return booksJson
          .map((bookString) => SavedBook.fromJson(jsonDecode(bookString)))
          .toList();
    } catch (e) {
      print('Error getting saved books: $e');
      return [];
    }
  }

  @override
  Future<bool> saveBook(SavedBook book) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedBooks = await getSavedBooks();
      print(savedBooks);

      // Check if book is already saved
      if (savedBooks.any((savedBook) => savedBook.id == book.id)) {
        return false; // Book already exists
      }

      savedBooks.add(book);
      final booksJson = savedBooks
          .map((book) => jsonEncode(book.toJson()))
          .toList();

      return await prefs.setStringList(_savedBooksKey, booksJson);
    } catch (e) {
      print('Error saving book: $e');
      return false;
    }
  }

  @override
  Future<bool> removeBook(String bookId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedBooks = await getSavedBooks();

      savedBooks.removeWhere((book) => book.id == bookId);
      final booksJson = savedBooks
          .map((book) => jsonEncode(book.toJson()))
          .toList();

      return await prefs.setStringList(_savedBooksKey, booksJson);
    } catch (e) {
      print('Error removing book: $e');
      return false;
    }
  }

  @override
  Future<bool> isBookSaved(String bookId) async {
    try {
      final savedBooks = await getSavedBooks();
      return savedBooks.any((book) => book.id == bookId);
    } catch (e) {
      print('Error checking if book is saved: $e');
      return false;
    }
  }
}