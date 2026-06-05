import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:e_commerce/Models/cart_item.dart';
import 'package:e_commerce/Models/category_model.dart';
import 'package:e_commerce/Models/discount_range.dart';
import 'package:e_commerce/Models/product.dart';
import 'package:e_commerce/Models/public_model.dart';
import 'package:e_commerce/Screens/AdvertisingBannerCarousel.dart' show BannerItem;
import 'package:e_commerce/Services/api/apiservice.dart';
import 'package:e_commerce/UI/Widgets/Organisms/home_screen_carousel.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class Home extends ChangeNotifier {
  final ApiService apiService;

  Home({required this.apiService});

  List<Category> categories = [];
  List<Product> products = [];
  Product? selectedProduct;
  List<SubCategory> subCategories = [];
  List<CartItem> cartItems = [];
  Map<String, int> productQuantities = {};

  bool isLoadingCategories = false;
  bool isLoadingProducts = false;
  bool isLoadingCart = false;
  bool isLoadingSubCategories = false;
List<Product> favouriteProducts = [];
  String? categoryError;
  String? errorMessage;

  // ✅ Maintenance state
  bool isMaintenance = false;
  String maintenanceMessage = 'We are under maintenance';

  // Banners
  List<BannerItem> _advertisingBanners = [];
  List<BannerItem> get advertisingBanners => _advertisingBanners;

  List<BannerItem2> _simpleBanners = [];
  List<BannerItem2> get simpleBanners => _simpleBanners;

  List<AppCategory> _allAppCategories = [];
  bool _isLoadingAllCategories = false;

  String _currentAddress = 'Fetching location...';
  bool _isLoadingLocation = false;
  String _locationError = '';

  String get currentAddress => _currentAddress;
  bool get isLoadingLocation => _isLoadingLocation;
  String get locationError => _locationError;

  List<AppCategory> get allAppCategories => _allAppCategories;
  bool get isLoadingAllCategories => _isLoadingAllCategories;
  List<AppCategory> appCategories = [];
  bool isLoadingAppCategories = false;

  String userId = 'user_123';
  Map<String, List<DiscountRange>> bulkRangesCache = {};
  Map<String, List<Product>> subcategoryProducts = {};
  bool isLoadingSubcategoryProducts = false;

  // ✅ Helper: maintenance set karo aur return
  void _setMaintenance(dynamic error) {
    if (error is MaintenanceException) {
      isMaintenance = true;
      maintenanceMessage = error.message;
    }
  }
bool isFavourite(String productId) {
  return favouriteProducts.any((e) => e.id == productId);
}

void toggleFavourite(Product product) {
  if (isFavourite(product.id)) {
    favouriteProducts.removeWhere((e) => e.id == product.id);
  } else {
    favouriteProducts.add(product);
  }

  notifyListeners();
}
  // ✅ Maintenance reset (Retry button ke liye)
  void resetMaintenance() {
    isMaintenance = false;
    maintenanceMessage = 'We are under maintenance';
    notifyListeners();
  }

  Future<void> fetchCategories() async {
    isLoadingCategories = true;
    categoryError = null;
    isMaintenance = false;
    notifyListeners();

    try {
      final response = await apiService.httpClient
          .get(Uri.parse('${apiService.baseUrl}/api/public/products?limit=200'));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;

        // ✅ Maintenance check
        if (decoded['maintenance'] == true) {
          isMaintenance = true;
          maintenanceMessage = decoded['message'] ?? 'We are under maintenance';
          categories = [];
          return;
        }

        final List products = decoded['data'] ?? [];
        final Map<String, Category> uniqueCategories = {};

        for (var product in products) {
          if (product['category'] != null && product['category'] is Map) {
            final catData = product['category'];
            final catId = catData['_id']?.toString();
            if (catId != null && catId.isNotEmpty && !uniqueCategories.containsKey(catId)) {
              uniqueCategories[catId] = Category(
                id: catId,
                name: catData['name']?.toString() ?? '',
                image: catData['image']?.toString() ?? '',
                subcategories: [],
              );
            }
          }
        }

        categories = uniqueCategories.values.toList();
        debugPrint('✅ Fetched ${categories.length} categories');
      } else {
        throw Exception('Failed to fetch');
      }
    } catch (e) {
      if (e is MaintenanceException) {
        _setMaintenance(e);
      } else {
        categories = [];
        categoryError = _handleError(e);
      }
    } finally {
      isLoadingCategories = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllProducts() async {
    isLoadingProducts = true;
    errorMessage = null;
    notifyListeners();

    try {
      final response = await apiService.httpClient
          .get(Uri.parse('${apiService.baseUrl}/api/public/products?limit=200'))
          .timeout(const Duration(seconds: 15));

      final decoded = json.decode(response.body) as Map<String, dynamic>;

      // ✅ Maintenance check
      if (decoded['maintenance'] == true) {
        isMaintenance = true;
        maintenanceMessage = decoded['message'] ?? 'We are under maintenance';
        products = [];
        return;
      }

      final List rawList = decoded['data'] ?? [];
      products = rawList.map((item) {
        try {
          return Product.fromJson(item as Map<String, dynamic>);
        } catch (e) {
          debugPrint("⚠️ Parse error: $e");
          return null;
        }
      }).whereType<Product>().toList();

      debugPrint("✅ Loaded ${products.length} products");
    } catch (e, stack) {
      if (e is MaintenanceException) {
        _setMaintenance(e);
        products = [];
      } else {
        debugPrint("❌ Error fetching all products: $e\n$stack");
        products = [];
        errorMessage = _handleError(e);
      }
    } finally {
      isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllSubcategoriesWithProducts() async {
    isLoadingSubcategoryProducts = true;
    notifyListeners();

    try {
      final response = await apiService.httpClient
          .get(Uri.parse('${apiService.baseUrl}/api/public/products?limit=200'))
          .timeout(const Duration(seconds: 15));

      final decoded = json.decode(response.body) as Map<String, dynamic>;

      // ✅ Maintenance check
      if (decoded['maintenance'] == true) {
        isMaintenance = true;
        maintenanceMessage = decoded['message'] ?? 'We are under maintenance';
        subcategoryProducts = {};
        return;
      }

      final List rawList = decoded['data'] ?? [];
      final Map<String, List<Product>> map = {};

      for (var item in rawList) {
        try {
          final product = Product.fromJson(item as Map<String, dynamic>);
          final subName = (item['subcategory'] is Map && item['subcategory']?['name'] != null)
              ? item['subcategory']['name'] as String
              : (item['category'] is Map && item['category']?['name'] != null)
                  ? item['category']['name'] as String
                  : 'Other';

          map.putIfAbsent(subName, () => []).add(product);
        } catch (e) {
          debugPrint("⚠️ $e");
        }
      }

      subcategoryProducts = map;
      debugPrint("✅ subcategoryProducts loaded: ${map.length} sections");
    } catch (e) {
      if (e is MaintenanceException) {
        _setMaintenance(e);
        subcategoryProducts = {};
      } else {
        debugPrint("❌ fetchAllSubcategoriesWithProducts: $e");
      }
    } finally {
      isLoadingSubcategoryProducts = false;
      notifyListeners();
    }
  }

  Future<void> fetchAllCategoriesFromAPI() async {
    _isLoadingAllCategories = true;
    notifyListeners();

    try {
      final response = await apiService.httpClient
          .get(Uri.parse('${apiService.baseUrl}/api/public/products?limit=200'));

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body) as Map<String, dynamic>;

        // ✅ Maintenance check
        if (decoded['maintenance'] == true) {
          isMaintenance = true;
          maintenanceMessage = decoded['message'] ?? 'We are under maintenance';
          _allAppCategories = [];
          return;
        }

        final List products = decoded['data'] ?? [];
        final Map<String, AppCategory> uniqueCategories = {};

        for (var product in products) {
          if (product['category'] != null && product['category'] is Map) {
            final catData = product['category'];
            final catId = catData['_id']?.toString();
            if (catId != null && catId.isNotEmpty && !uniqueCategories.containsKey(catId)) {
              uniqueCategories[catId] = AppCategory(
                id: catId,
                name: catData['name']?.toString() ?? '',
                image: catData['image']?.toString() ?? '',
                subcategories: [],
              );
            }
          }
        }

        _allAppCategories = uniqueCategories.values.toList();
        debugPrint("✅ Fetched ${_allAppCategories.length} total categories");
      } else {
        throw Exception('Failed to fetch');
      }
    } catch (e) {
      if (e is MaintenanceException) {
        _setMaintenance(e);
      }
      _allAppCategories = [];
    } finally {
      _isLoadingAllCategories = false;
      notifyListeners();
    }
  }

  Future<void> fetchProductsByCategory(String category) async {
    isLoadingProducts = true;
    errorMessage = null;
    notifyListeners();

    try {
      products = await apiService.getProductsByCategory(category);
    } catch (e) {
      if (e is MaintenanceException) {
        _setMaintenance(e);
      }
      products = [];
      errorMessage = _handleError(e);
    } finally {
      isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> fetchProductsBySubCategory(String subCategory) async {
    isLoadingProducts = true;
    errorMessage = null;
    notifyListeners();

    try {
      products = await apiService.getProductsBySubCategory(subCategory);
    } catch (e, stack) {
      if (e is MaintenanceException) {
        _setMaintenance(e);
      }
      debugPrint("❌ Error fetching subCategory: $e\n$stack");
      products = [];
      errorMessage = _handleError(e);
    } finally {
      isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> fetchProductById(String productId) async {
    isLoadingProducts = true;
    errorMessage = null;
    notifyListeners();

    try {
      final product = await apiService.getProductById(productId);
      selectedProduct = product;

      final index = products.indexWhere((p) => p.id == product.id);
      if (index == -1) {
        products.add(product);
      } else {
        products[index] = product;
      }
    } catch (e, stack) {
      if (e is MaintenanceException) {
        _setMaintenance(e);
      }
      debugPrint("❌ Error fetching product: $e\n$stack");
      errorMessage = _handleError(e);
    } finally {
      isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> getSubpro(String productId) async {
    isLoadingProducts = true;
    errorMessage = null;
    notifyListeners();

    try {
      final product = await apiService.getSubPro(productId);
      selectedProduct = product;

      final index = products.indexWhere((p) => p.id == product.id);
      if (index == -1) {
        products.add(product);
      } else {
        products[index] = product;
      }
    } catch (e, stack) {
      if (e is MaintenanceException) {
        _setMaintenance(e);
      }
      debugPrint("❌ Error fetching product: $e\n$stack");
      errorMessage = _handleError(e);
    } finally {
      isLoadingProducts = false;
      notifyListeners();
    }
  }

  Future<void> fetchSubCategories(String category) async {
    isLoadingSubCategories = true;
    errorMessage = null;
    notifyListeners();

    try {
      subCategories = await apiService.getSubCategories(category);
    } catch (e) {
      if (e is MaintenanceException) {
        _setMaintenance(e);
      }
      subCategories = [];
      errorMessage = _handleError(e);
    } finally {
      isLoadingSubCategories = false;
      notifyListeners();
    }
  }

  Future<void> fetchAndGroupProducts() async {
    isLoadingAppCategories = true;
    isLoadingProducts = true;
    errorMessage = null;
    notifyListeners();

    try {
      final List<Product> allProducts = [];
      int page = 1;
      bool hasMore = true;

      while (hasMore) {
        final response = await apiService.getProductsPaged(page: page, limit: 50);
        allProducts.addAll(response['products'] as List<Product>);
        final int totalPages = response['pages'] as int;
        hasMore = page < totalPages;
        page++;
      }

      products = allProducts;
      final groupedCategories = ProductGrouper.groupProducts(allProducts);

      if (_allAppCategories.isEmpty) {
        appCategories = groupedCategories;
      } else {
        final Map<String, AppCategory> mergedMap = {
          for (var cat in _allAppCategories) cat.id: cat,
        };
        for (var productCat in groupedCategories) {
          if (mergedMap.containsKey(productCat.id)) {
            final existing = mergedMap[productCat.id]!;
            mergedMap[productCat.id] = AppCategory(
              id: existing.id,
              name: existing.name,
              image: existing.image,
              subcategories: productCat.subcategories,
            );
          } else {
            mergedMap[productCat.id] = productCat;
          }
        }
        appCategories = mergedMap.values.toList();
      }

      debugPrint("✅ Total products: ${allProducts.length}");
      debugPrint("✅ Total categories: ${appCategories.length}");
    } catch (e, stack) {
      if (e is MaintenanceException) {
        _setMaintenance(e);
      }
      debugPrint("❌ fetchAndGroupProducts: $e\n$stack");
      errorMessage = _handleError(e);
    } finally {
      isLoadingAppCategories = false;
      isLoadingProducts = false;
      notifyListeners();
    }
  }

  // -------------------
  // Location Methods
  // -------------------
  Future<void> fetchCurrentLocation() async {
    _isLoadingLocation = true;
    _locationError = '';
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _locationError = 'Location services are disabled.';
        _currentAddress = 'Location services off';
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _locationError = 'Location permissions denied.';
          _currentAddress = 'Location denied';
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _locationError = 'Location permissions permanently denied.';
        _currentAddress = 'Location denied';
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        List<String> addressParts = [];
        if (place.subLocality != null && place.subLocality!.isNotEmpty)
          addressParts.add(place.subLocality!);
        if (place.locality != null && place.locality!.isNotEmpty)
          addressParts.add(place.locality!);
        if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty)
          addressParts.add(place.administrativeArea!);
        if (place.postalCode != null && place.postalCode!.isNotEmpty)
          addressParts.add(place.postalCode!);

        _currentAddress = addressParts.isNotEmpty
            ? addressParts.join(', ')
            : (place.street?.isNotEmpty == true ? place.street! : 'Current Location');

        if (_currentAddress.length > 35) {
          _currentAddress = '${_currentAddress.substring(0, 32)}...';
        }
      } else {
        _currentAddress = 'Address not found';
        _locationError = 'Could not find address';
      }
    } catch (e) {
      _locationError = e.toString();
      _currentAddress = 'Location unavailable';
    } finally {
      _isLoadingLocation = false;
      notifyListeners();
    }
  }

  void updateAddress(String newAddress) {
    _currentAddress = newAddress;
    _locationError = '';
    notifyListeners();
    _saveAddressToPrefs(newAddress);
  }

  Future<void> _saveAddressToPrefs(String address) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_address', address);
    } catch (e) {
      debugPrint("Error saving address: $e");
    }
  }

  Future<void> loadSavedAddress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedAddress = prefs.getString('user_address');
      if (savedAddress != null && savedAddress.isNotEmpty) {
        _currentAddress = savedAddress;
        notifyListeners();
      } else {
        await fetchCurrentLocation();
      }
    } catch (e) {
      await fetchCurrentLocation();
    }
  }

  // -------------------
  // Cart Methods
  // -------------------
  Future<void> loadCart() async {
    isLoadingCart = true;
    errorMessage = null;
    notifyListeners();

    try {
      cartItems = await apiService.getCartItems(userId);
      productQuantities.clear();
      for (var item in cartItems) {
        productQuantities[item.product.id] = item.quantity;
      }
    } catch (e) {
      cartItems = [];
      errorMessage = _handleError(e);
    } finally {
      isLoadingCart = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    try {
      await apiService.addToCart(userId, productId, quantity);
      await loadCart();
    } catch (e) {
      errorMessage = _handleError(e);
      notifyListeners();
    }
  }

  Future<void> updateCartItem(String cartItemId, int quantity) async {
    try {
      await apiService.updateCartItem(userId, cartItemId, quantity);
      await loadCart();
    } catch (e) {
      errorMessage = _handleError(e);
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      await apiService.removeFromCart(userId, cartItemId);
      await loadCart();
    } catch (e) {
      errorMessage = _handleError(e);
      notifyListeners();
    }
  }

  Future<void> clearCartAfterOrder() async {
    try {
      productQuantities.clear();
      cartItems.clear();
      notifyListeners();
    } catch (e) {
      errorMessage = _handleError(e);
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    try {
      await apiService.clearCart(userId);
      await loadCart();
    } catch (e) {
      errorMessage = _handleError(e);
      notifyListeners();
    }
  }

  double getFinalPrice(Product product, int quantity) {
    final cachedRanges = bulkRangesCache[product.id];
    if (cachedRanges != null && cachedRanges.isNotEmpty) {
      for (final r in cachedRanges) {
        if (r.isQuantityInRange(quantity)) return r.price;
      }
    }

    if (product.bulkPricing.isNotEmpty) {
      for (final r in product.bulkPricing) {
        if (r.isQuantityInRange(quantity)) return r.price;
      }
    }

    if (product.salePrice > 0) return product.salePrice;
    return product.basePrice;
  }

  void cacheBulkRanges(String productId, List<DiscountRange> ranges) {
    bulkRangesCache[productId] = ranges;
    notifyListeners();
  }

  List<DiscountRange>? getCachedBulkRanges(String productId) => bulkRangesCache[productId];

  DiscountRange? getActiveRange(Product product, int qty) {
    try {
      return product.bulkPricing.firstWhere((r) => r.isQuantityInRange(qty));
    } catch (e) {
      return null;
    }
  }

  double getUnitPrice(Product product, int quantity) {
    if (product.bulkPricing.isEmpty) return product.salePrice;
    for (final r in product.bulkPricing) {
      if (r.isQuantityInRange(quantity)) return r.price;
    }
    return product.salePrice;
  }

  List<DiscountRange>? getDiscountRanges(String productId) {
    final product = getProductByIdLocal(productId);
    if (product == null) return null;
    if (product.bulkPricing.isNotEmpty) return product.bulkPricing;
    return null;
  }

  // -------------------
  // Local Cart Methods
  // -------------------
  void removeFromCartLocal(String productId) {
    productQuantities.remove(productId);
    notifyListeners();
  }

  void incrementQuantity(String productId) {
    productQuantities[productId] = getQuantity(productId) + 1;
    notifyListeners();
  }

  void decrementQuantity(String productId) {
    final currentQty = getQuantity(productId);
    if (currentQty <= 1) {
      productQuantities.remove(productId);
    } else {
      productQuantities[productId] = currentQty - 1;
    }
    notifyListeners();
  }

  List<CartItem> getCartItemsLocal() {
    return productQuantities.entries
        .map((entry) {
          final product = getProductByIdLocal(entry.key);
          if (product == null) return null;
          return CartItem(id: product.id, product: product, quantity: entry.value);
        })
        .whereType<CartItem>()
        .toList();
  }

  void updateQuantity(String productId, int quantity) {
    if (quantity <= 0) {
      productQuantities.remove(productId);
    } else {
      productQuantities[productId] = quantity;
    }
    notifyListeners();
  }

  int getQuantity(String productId) => productQuantities[productId] ?? 0;

  Product? getProductByIdLocal(String id) {
    try {
      return products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<Product> getProductsByCategoryLocal(String category) {
    return products.where((p) => p.category == category).toList();
  }

  Product getProductByIndex(int index) {
    return products.isNotEmpty && index < products.length ? products[index] : products[0];
  }

  List<Product> getAllProducts() => products;

  List<Product> getProductAll() => products;

  CartItem? getCartItem(String productId) {
    try {
      return cartItems.firstWhere((item) => item.product.id == productId);
    } catch (e) {
      return null;
    }
  }

  bool isInCart(String productId) => cartItems.any((item) => item.product.id == productId);

  int getProductQuantity(String productId) {
    try {
      return cartItems.firstWhere((item) => item.product.id == productId).quantity;
    } catch (e) {
      return 0;
    }
  }

  String getCurrentTierInfo(String productId) {
    try {
      final item = cartItems.firstWhere((item) => item.product.id == productId);
      int quantity = item.quantity;
      for (var tier in item.product.bulkPricing.reversed) {
        if (tier.isQuantityInRange(quantity)) {
          if (tier.discount == 0) return "Regular";
          if (tier.discount < 10) return "Bulk";
          return "Wholesale";
        }
      }
      return "Regular";
    } catch (e) {
      return "Regular";
    }
  }

  int get totalCartItems =>
      productQuantities.values.fold(0, (sum, qty) => sum + qty);

  double get totalCartPrice {
    final items = getCartItemsLocal();
    return items.fold(0.0, (sum, item) {
      final unitPrice = getFinalPrice(item.product, item.quantity);
      return sum + (unitPrice * item.quantity);
    });
  }

  bool get hasItems => productQuantities.isNotEmpty;

  double get baseCartPrice {
    double total = 0;
    for (var item in cartItems) {
      total += item.product.basePrice * item.quantity;
    }
    return total;
  }

  // -------------------
  // Banner Methods
  // -------------------
  Future<void> fetchAdvertisingBanners() async {
    try {
      final response = await http.get(
        Uri.parse('https://grocerrybackend.onrender.com/api/advertising-banner'),
      );

      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        _advertisingBanners = (data['data'] as List)
            .where((item) => item['status'] == 'active')
            .map((item) => BannerItem(
                  image: item['image'] ?? '',
                  title: item['title'] ?? '',
                  redirectUrl: item['redirectUrl'] ?? '',
                  bannerType: item['bannerType'] ?? '',
                  referenceId: item['referenceId']?.toString() ?? '',
                ))
            .toList();

        notifyListeners();
      }
    } catch (e) {
      debugPrint("❌ Advertising banner fetch error: $e");
    }
  }

  Future<void> fetchSimpleBanners() async {
    try {
      final response = await http.get(
        Uri.parse('https://grocerrybackend.onrender.com/api/banners'),
      );
      final data = jsonDecode(response.body);
      if (data['success'] == true) {
        _simpleBanners = (data['data'] as List)
            .where((item) => item['status'] == 'active')
            .map((item) => BannerItem2(
                  imageUrl: item['image'] ?? '',
                  isNetwork: true,
                ))
            .toList();
        debugPrint("✅ Loaded ${_simpleBanners.length} simple banners");
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Simple banner fetch error: $e');
    }
  }

  // -------------------
  // Helpers
  // -------------------
  String _handleError(dynamic error) {
    if (error is MaintenanceException) return error.message;
    if (error is SocketException) return 'No internet connection.';
    if (error is TimeoutException) return 'Request timeout.';
    if (error is FormatException) return 'Invalid response format.';
    return error.toString().replaceFirst('Exception: ', '');
  }

  void operator [](Widget? other) {}
}
