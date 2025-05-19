import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tatli_sozluk/models/entry_model.dart';
import 'package:tatli_sozluk/providers/entry_provider.dart';

class SearchProvider with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Entry> _searchResults = [];
  bool _isLoading = false;
  bool _hasSearched = false;
  String _searchQuery = '';

  // Getters
  List<Entry> get searchResults => _searchResults;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  bool get hasSearched => _hasSearched;

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
    if (query.isEmpty) {
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
      
      // Get all entries
      final querySnapshot = await _firestore
          .collection('posts')
          .get();

      // Filter entries that contain the query in their title
      _searchResults = querySnapshot.docs
          .map((doc) => Entry.fromFirestore(doc))
          .where((entry) => entry.title.toLowerCase().contains(lowercaseQuery))
          .toList();

      // Sort results by relevance (exact matches first)
      _searchResults.sort((a, b) {
        final aTitle = a.title.toLowerCase();
        final bTitle = b.title.toLowerCase();
        
        // Exact match
        final aExact = aTitle == lowercaseQuery;
        final bExact = bTitle == lowercaseQuery;
        if (aExact && !bExact) return -1;
        if (!aExact && bExact) return 1;
        
        // Starts with
        final aStarts = aTitle.startsWith(lowercaseQuery);
        final bStarts = bTitle.startsWith(lowercaseQuery);
        if (aStarts && !bStarts) return -1;
        if (!aStarts && bStarts) return 1;
        
        return 0;
      });
    } catch (e) {
      print('Error searching entries: $e');
      _searchResults = [];
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

