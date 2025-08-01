import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/saved_book.dart';

// Storage service interface - makes Firebase migration easier
abstract class BookStorageService {
  Future<List<SavedBook>> getSavedBooks();
  Future<bool> saveBook(SavedBook book);
  Future<bool> removeBook(String bookId);
  Future<bool> isBookSaved(String bookId);
  Future<void> saveFavoriteBook(SavedBook book);
  Future<SavedBook?> getFavoriteBook();
  Future<String> getQuote();
  Future<void> saveQuote(String quote);
}

// Local storage implementation using SharedPreferences
class LocalBookStorageService implements BookStorageService {
  static const String _savedBooksKey = 'saved_books';
  static const _quoteKey = 'user_favourite_quote';
  static const _favoriteBookIdKey = 'favorite_book_id';

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
  Future<void> saveFavoriteBook(SavedBook book) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_favoriteBookIdKey, book.id);
    } catch (e) {
      debugPrint('Error saving favorite book: $e');
    }
  }

  @override
  Future<SavedBook?> getFavoriteBook() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoriteBookId = prefs.getString(_favoriteBookIdKey);

      if (favoriteBookId == null) {
        return null; // No favorite book saved
      }

      // Find the book with the matching ID from all saved books
      final allBooks = await getSavedBooks();
      try {
        return allBooks.firstWhere((book) => book.id == favoriteBookId);
      } catch (e) {
        // The favorite book ID exists but the book is not in the saved list anymore
        return null;
      }
    } catch (e) {
      debugPrint('Error getting favorite book: $e');
      return null;
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

  @override
  Future<String> getQuote() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final quote = prefs.getString(_quoteKey) ?? '';

      return quote;
    } catch (e) {
      debugPrint('Error getting saved quote: $e');
      return '';
    }
  }

  @override
  Future<bool> saveQuote(String quote) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final storedQuote = await getQuote();

      if (storedQuote == quote) {
        return false;
      }

      final quoteToSave = await prefs.setString(_quoteKey, quote);

      return quoteToSave;
    } catch (e) {
      debugPrint('Error saving quote: $e');
      return false;
    }
  }
}