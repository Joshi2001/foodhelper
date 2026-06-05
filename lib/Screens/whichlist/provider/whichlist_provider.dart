// providers/wishlist_provider.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class WishlistProvider with ChangeNotifier {
  Set<String> _wishlistedProductIds = {};
  final Set<String> _loadingIds = {};

  Set<String> get wishlistedProductIds => _wishlistedProductIds;

  bool get isLoading => _loadingIds.isNotEmpty;

  bool isProductLoading(String productId) => _loadingIds.contains(productId);

  bool isWishlisted(String productId) =>
      _wishlistedProductIds.contains(productId);

  // Load from local storage
  Future<void> loadLocalWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final savedIds = prefs.getStringList('wishlist_ids') ?? [];
    _wishlistedProductIds = savedIds.toSet();
    notifyListeners();
    debugPrint('Local wishlist loaded: $_wishlistedProductIds');
  }

  // Save to local storage
  Future<void> _saveLocalWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('wishlist_ids', _wishlistedProductIds.toList());
  }

  Future<void> fetchWishlist() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token == null) return;

    try {
      final response = await http.get(
        Uri.parse('https://grocerrybackend.onrender.com/api/wishlist/my'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final List<dynamic> wishlist = body['wishlist'] ?? [];

        _wishlistedProductIds = wishlist
            .where((item) =>
                item['product'] != null &&
                item['product']['_id'] != null)
            .map<String>((item) => item['product']['_id'] as String)
            .toSet();

        await _saveLocalWishlist();
        debugPrint('Wishlist loaded: $_wishlistedProductIds');
        notifyListeners();
      }
    } catch (e) {
      debugPrint('fetchWishlist error: $e');
    }
  }

  Future<bool> toggleWishlist(String productId, String productType) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      debugPrint('User not logged in');
      return false;
    }

    _loadingIds.add(productId);
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('https://grocerrybackend.onrender.com/api/wishlist/toggle'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'productId': productId,
          'productType': productType,
        }),
      );

      debugPrint('Toggle status: ${response.statusCode}');
      debugPrint('Toggle body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        final bool wishlisted = body['wishlisted'] ?? false;

        if (wishlisted) {
          _wishlistedProductIds.add(productId);
        } else {
          _wishlistedProductIds.remove(productId);
        }

        await _saveLocalWishlist();
        debugPrint('Wishlisted: $wishlisted');
        notifyListeners();
        return wishlisted;
      } else {
        debugPrint('Unexpected status: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('toggleWishlist error: $e');
    } finally {
      _loadingIds.remove(productId);
      notifyListeners();
    }

    return false;
  }

  void clearWishlist() {
    _wishlistedProductIds.clear();
    _loadingIds.clear();
    notifyListeners();
  }
}