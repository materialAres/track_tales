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