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
  Future<String> getQuote();
  Future<void> saveQuote(String quote);
}

// Local storage implementation using SharedPreferences
class LocalBookStorageService implements BookStorageService {
  static const String _savedBooksKey = 'saved_books';
  static const _quoteKey = 'user_favourite_quote';

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

  @override
  Future<String> getQuote() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final quote = prefs.getString(_quoteKey) ?? '';

      return jsonDecode(quote);
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

      final quoteJson = jsonEncode(quote);

      return await prefs.setString(_quoteKey, quoteJson);
    } catch (e) {
      debugPrint('Error saving quote: $e');
      return false;
    }
  }
}