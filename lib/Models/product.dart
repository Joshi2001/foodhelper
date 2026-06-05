import 'package:e_commerce/Models/discount_range.dart';

class Product {
  final String id;
  final String? brand;
  final String name;
  final String source; 
  final String? adminId;
  final String? vendorId;
  final VendorInfo? vendorInfo;
  final Weight? weight;
  final String imagePath;
  final List<String> galleryImages;
  final double basePrice;
  final double salePrice;
  final double mrp; // Added MRP field
  final double lockedPrice;
  final double yesterdayLock;
  final int brokerDisplay;
  final double profitLoss;
  final double gstPercent;
  final double cessPercent;
  final double cgstPercent;
  final double sgstPercent;
  final double igstPercent;
  final double gstAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double cessAmount;
  final double totalTaxAmount;
  final double priceExcludingGst;
  final String hsnCode;
  final String taxType;
  final String description;
  final String status;
  final String createdAt;
  final String? updatedAt;
  final String? validTill; // vendor-only field
  final double discount;   // vendor-only field
  final ProductCategory? category;
  final ProductSubcategory? subcategory;
  final ProductSubcategory? subSubcategory;
  final List<DiscountRange> bulkPricing;

  // Convenience getters to keep existing UI code working
  double get originalPrice => basePrice;
  double get currentPrice => salePrice;
  String get category_name => category?.name ?? '';

  // Get discount percentage from MRP
  double get discountPercentage {
    if (mrp <= 0 || salePrice <= 0) return 0;
    final discountAmount = mrp - salePrice;
    if (discountAmount <= 0) return 0;
    return (discountAmount / mrp) * 100;
  }

  // Check if product has MRP discount
  bool get hasMrpDiscount => mrp > 0 && mrp > salePrice;

  Product({
    required this.id,
    required this.name,
    required this.source,
    this.brand,
    this.adminId,
    this.vendorId,
    this.vendorInfo,
    this.weight,
    required this.imagePath,
    required this.galleryImages,
    required this.basePrice,
    required this.salePrice,
    required this.mrp, // Added
    required this.lockedPrice,
    required this.yesterdayLock,
    required this.brokerDisplay,
    required this.profitLoss,
    required this.gstPercent,
    required this.cessPercent,
    required this.cgstPercent,
    required this.sgstPercent,
    required this.igstPercent,
    required this.gstAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.cessAmount,
    required this.totalTaxAmount,
    required this.priceExcludingGst,
    required this.hsnCode,
    required this.taxType,
    required this.description,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.validTill,
    required this.discount,
    this.category,
    this.subcategory,
    this.subSubcategory,
    required this.bulkPricing,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    try {
      // Weight
      Weight? weight;
      final weightData = json['weight'];
      if (weightData is Map<String, dynamic>) {
        weight = Weight.fromJson(weightData);
      }

      // Gallery images
      final List<String> gallery = [];
      if (json['galleryImages'] is List) {
        for (final img in json['galleryImages']) {
          if (img is String && img.isNotEmpty) gallery.add(img);
        }
      }

      // Category
      ProductCategory? category;
      if (json['category'] is Map<String, dynamic>) {
        category = ProductCategory.fromJson(json['category']);
      }

      // Subcategory — API uses both 'subcategory' and 'subSubcategory'/'subSubCategory'
      ProductSubcategory? subcategory;
      final subRaw = json['subcategory'];
      if (subRaw is Map<String, dynamic> && subRaw['name'] != null) {
        subcategory = ProductSubcategory.fromJson(subRaw);
      }

      ProductSubcategory? subSubcategory;
      final subSubRaw = json['subSubcategory'] ?? json['subSubCategory'];
      if (subSubRaw is Map<String, dynamic> && subSubRaw['name'] != null) {
        subSubcategory = ProductSubcategory.fromJson(subSubRaw);
      }

      // 'profitLoss' is used by admin products, 'profit' by vendor products
      final double profitLoss = _toDouble(json['profitLoss'] ?? json['profit']);

      // Vendor-only fields
      final double discount = _toDouble(json['discount']);
      final String? validTill = json['validTill']?.toString();

      // VendorInfo
      VendorInfo? vendorInfo;
      if (json['vendorInfo'] is Map<String, dynamic>) {
        vendorInfo = VendorInfo.fromJson(json['vendorInfo']);
      }

      // Handle brand - could be String or Object (ID reference)
      String? brandName;
      final brandData = json['brand'];
      if (brandData is String) {
        brandName = brandData;
      } else if (brandData is Map<String, dynamic>) {
        brandName = brandData['name']?.toString();
      }

      return Product(
        id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
        name: (json['name'] ?? '').toString().trim(),
        source: (json['source'] ?? 'admin').toString(),
        adminId: json['adminId']?.toString(),
        vendorId: json['vendorId']?.toString(),
        vendorInfo: vendorInfo,
        weight: weight,
        brand: brandName,
        imagePath: (json['image'] ?? json['imagePath'] ?? '').toString().trim(),
        galleryImages: gallery,
        basePrice: _toDouble(json['basePrice'] ?? json['originalPrice']),
        salePrice: _toDouble(json['salePrice'] ?? json['currentPrice']),
        mrp: _toDouble(json['mrp']), // Parse MRP field
        lockedPrice: _toDouble(json['lockedPrice']),
        yesterdayLock: _toDouble(json['yesterdayLock']),
        brokerDisplay: _toInt(json['brokerDisplay']),
        profitLoss: profitLoss,
        gstPercent: _toDouble(json['gstPercent']),
        cessPercent: _toDouble(json['cessPercent']),
        cgstPercent: _toDouble(json['cgstPercent']),
        sgstPercent: _toDouble(json['sgstPercent']),
        igstPercent: _toDouble(json['igstPercent']),
        gstAmount: _toDouble(json['gstAmount']),
        cgstAmount: _toDouble(json['cgstAmount']),
        sgstAmount: _toDouble(json['sgstAmount']),
        igstAmount: _toDouble(json['igstAmount']),
        cessAmount: _toDouble(json['cessAmount']),
        totalTaxAmount: _toDouble(json['totalTaxAmount']),
        priceExcludingGst: _toDouble(json['priceExcludingGst']),
        hsnCode: (json['hsnCode'] ?? '').toString().trim(),
        taxType: (json['taxType'] ?? 'cgst_sgst').toString().trim(),
        description: (json['description'] ?? '').toString().trim(),
        status: (json['status'] ?? 'inactive').toString().trim(),
        createdAt: (json['createdAt'] ?? '').toString().trim(),
        updatedAt: json['updatedAt']?.toString(),
        validTill: validTill,
        discount: discount,
        category: category,
        subcategory: subcategory,
        subSubcategory: subSubcategory,
        bulkPricing: json['bulkPricing'] is List
            ? (json['bulkPricing'] as List)
                .map((e) => DiscountRange.fromJson(e as Map<String, dynamic>))
                .toList()
            : [],
      );
    } catch (e, stack) {
      print('❌ Error parsing Product: $e');
      print('📌 Stack: $stack');
      print('📋 JSON: $json');
      rethrow;
    }
  }

  // ── Bulk pricing helpers ──────────────────────────────────────────────────

  double getPriceForQuantity(int quantity) {
    for (int i = bulkPricing.length - 1; i >= 0; i--) {
      if (bulkPricing[i].isQuantityInRange(quantity)) {
        return bulkPricing[i].price;
      }
    }
    return salePrice;
  }

  double getDiscountForQuantity(int quantity) {
    for (int i = bulkPricing.length - 1; i >= 0; i--) {
      if (bulkPricing[i].isQuantityInRange(quantity)) {
        return bulkPricing[i].discount;
      }
    }
    return 0;
  }

  DiscountRange? getDiscountRangeForQuantity(int quantity) {
    for (int i = bulkPricing.length - 1; i >= 0; i--) {
      if (bulkPricing[i].isQuantityInRange(quantity)) return bulkPricing[i];
    }
    return null;
  }

  DiscountRange? getNextDiscountTier(int currentQuantity) {
    for (final tier in bulkPricing) {
      if (currentQuantity < tier.min) return tier;
    }
    return null;
  }

  int? unitsNeededForNextTier(int currentQuantity) {
    final next = getNextDiscountTier(currentQuantity);
    return next == null ? null : next.min - currentQuantity;
  }

  double get maxDiscount {
    if (bulkPricing.isEmpty) return 0;
    return bulkPricing.map((e) => e.discount).reduce((a, b) => a > b ? a : b);
  }

  // ── Tax helpers ───────────────────────────────────────────────────────────

  /// True when the product has any tax applied
  bool get hasTax => totalTaxAmount > 0;

  /// True for IGST (interstate), false for CGST+SGST (intrastate)
  bool get isIgst => igstPercent > 0;


  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'source': source,
        'adminId': adminId,
        'vendorId': vendorId,
        'vendorInfo': vendorInfo?.toJson(),
        'weight': weight?.toJson(),
        'image': imagePath,
        'brand': brand,
        'galleryImages': galleryImages,
        'basePrice': basePrice,
        'salePrice': salePrice,
        'mrp': mrp,
        'lockedPrice': lockedPrice,
        'yesterdayLock': yesterdayLock,
        'brokerDisplay': brokerDisplay,
        'profitLoss': profitLoss,
        'gstPercent': gstPercent,
        'cessPercent': cessPercent,
        'cgstPercent': cgstPercent,
        'sgstPercent': sgstPercent,
        'igstPercent': igstPercent,
        'gstAmount': gstAmount,
        'cgstAmount': cgstAmount,
        'sgstAmount': sgstAmount,
        'igstAmount': igstAmount,
        'cessAmount': cessAmount,
        'totalTaxAmount': totalTaxAmount,
        'priceExcludingGst': priceExcludingGst,
        'hsnCode': hsnCode,
        'taxType': taxType,
        'description': description,
        'status': status,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
        'validTill': validTill,
        'discount': discount,
        'category': category?.toJson(),
        'subcategory': subcategory?.toJson(),
        'subSubcategory': subSubcategory?.toJson(),
        'bulkPricing': bulkPricing.map((e) => e.toJson()).toList(),
      };

  // ── Private helpers ───────────────────────────────────────────────────────

  static double _toDouble(dynamic v) {
    if (v == null) return 0.0;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v) ?? 0.0;
    return 0.0;
  }

  static int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  @override
  String toString() => 'Product(id: $id, name: $name, source: $source, salePrice: $salePrice, mrp: $mrp)';
}

// ── Supporting models ─────────────────────────────────────────────────────────

class Weight {
  final dynamic value; // int or double — API sends both
  final String unit;
  final String id;

  Weight({required this.value, required this.unit, required this.id});

  factory Weight.fromJson(Map<String, dynamic> json) {
    return Weight(
      value: json['value'] ?? 0,
      unit: (json['unit'] ?? 'kg').toString().trim(),
      id: (json['_id'] ?? json['id'] ?? '').toString().trim(),
    );
  }

  Map<String, dynamic> toJson() => {'value': value, 'unit': unit, '_id': id};

  @override
  String toString() => '$value$unit';
}

class ProductCategory {
  final String id;
  final String name;
  final String image;

  ProductCategory({required this.id, required this.name, required this.image});

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      image: (json['image'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {'_id': id, 'name': name, 'image': image};
}

class ProductSubcategory {
  final String? id;
  final String? name;
  final String? image;

  ProductSubcategory({this.id, this.name, this.image});

  factory ProductSubcategory.fromJson(Map<String, dynamic> json) {
    return ProductSubcategory(
      id: json['id']?.toString() ?? json['_id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
    );
  }
  
  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'image': image};
}

class VendorInfo {
  final String id;
  final String name;
  final String email;
  final String phone;

  VendorInfo({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
  });

  factory VendorInfo.fromJson(Map<String, dynamic> json) {
    return VendorInfo(
      id: (json['_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      phone: (json['phone'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'name': name,
        'email': email,
        'phone': phone,
      };
}