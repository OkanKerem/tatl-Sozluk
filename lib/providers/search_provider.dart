import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tatli_sozluk/models/entry_model.dart';

class SearchProvider extends ChangeNotifier {
  List<Entry> _searchResults = [];
  String _searchQuery = '';
  bool _isLoading = false;
  bool _hasSearched = false;

  // Getters
  List<Entry> get searchResults => _searchResults;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get hasSearched => _hasSearched;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void resetSearch() {
    _searchResults = [];
    _searchQuery = '';
    _hasSearched = false;
    notifyListeners();
  }

  // 🔍 Search entries by title (from 'posts')
  Future<void> searchEntries(String query) async {
    if (query.trim().isEmpty) {
      _searchResults = [];
      _hasSearched = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    _searchQuery = query;
    _hasSearched = true;
    notifyListeners();

    try {
      // Convert query to lowercase for case-insensitive search
      final lowercaseQuery = query.toLowerCase();
      
      // 🔍 Use title_lowercase field for case-insensitive search
      final querySnapshot = await _firestore
          .collection('posts')
          .orderBy('title_lowercase')
          .startAt([lowercaseQuery])
          .endAt(['$lowercaseQuery\uf8ff'])
          .get();

      // 🔍 Contains match using lowercase field
      final containsQuerySnapshot = await _firestore
          .collection('posts')
          .where('title_lowercase', isGreaterThanOrEqualTo: lowercaseQuery)
          .where('title_lowercase', isLessThanOrEqualTo: '$lowercaseQuery\uf8ff')
          .get();

      final Map<String, Entry> uniqueResults = {};

      for (final doc in querySnapshot.docs) {
        final entry = Entry.fromFirestore(doc);
        uniqueResults[entry.id] = entry;
      }

      for (final doc in containsQuerySnapshot.docs) {
        final entry = Entry.fromFirestore(doc);
        uniqueResults[entry.id] = entry;
      }

      _searchResults = uniqueResults.values.toList();

      // Sort results - use case-insensitive comparison
      _searchResults.sort((a, b) {
        final aExact = a.title.toLowerCase() == lowercaseQuery;
        final bExact = b.title.toLowerCase() == lowercaseQuery;

        if (aExact && !bExact) return -1;
        if (!aExact && bExact) return 1;

        final aStarts = a.title.toLowerCase().startsWith(lowercaseQuery);
        final bStarts = b.title.toLowerCase().startsWith(lowercaseQuery);

        if (aStarts && !bStarts) return -1;
        if (!aStarts && bStarts) return 1;

        return b.likedBy.length.compareTo(a.likedBy.length);
      });

    } catch (e) {
      print('Error searching entries: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 🔝 Popular search suggestions
  Future<List<String>> getPopularSearchTitles() async {
    try {
      final querySnapshot = await _firestore
          .collection('posts')
          .orderBy('likedBy', descending: true)
          .limit(10)
          .get();

      return querySnapshot.docs
          .map((doc) => (doc.data())['title'] as String)
          .toList();
    } catch (e) {
      print('Error getting popular search titles: $e');
      return [];
    }
  }

  // 👤 Search by user ID
  Future<List<Entry>> searchEntriesByUser(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final querySnapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .get();

      final results = querySnapshot.docs
          .map((doc) => Entry.fromFirestore(doc))
          .toList();

      return results;
    } catch (e) {
      print('Error searching entries by user: $e');
      return [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

