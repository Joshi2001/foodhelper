class DiscountRange {
  final int min;
  final int max;
  final double price;
  final double discount;

  double get discountPercent => discount;

  DiscountRange({
    required this.min,
    required this.max,
    required this.price,
    required this.discount,
  });

  bool isQuantityInRange(int quantity) {
    if (max == -1) {
      return quantity >= min;
    }
    return quantity >= min && quantity <= max;
  }

  bool get isUnlimitedTier => max == -1;

  String get rangeText {
    if (max == -1) {
      return "$min+ units";
    }
    if (min == max) {
      return "$min unit${min > 1 ? 's' : ''}";
    }
    return "$min - $max units";
  }

  String get priceText => "₹$price";

  String get discountText {
    if (discount == 0) {
      return "-";
    }
    return "-₹$discount";
  }

  double getTotalDiscount(int quantity) {
    if (isQuantityInRange(quantity)) {
      return discount * quantity;
    }
    return 0.0;
  }

  double getTotalPrice(int quantity) {
    if (isQuantityInRange(quantity)) {
      return price * quantity;
    }
    return 0.0;
  }

  Map<String, dynamic> toJson() {
    return {
      'min': min,
      'max': max,
      'price': price,
      'discount': discount,
    };
  }

 factory DiscountRange.fromJson(Map<String, dynamic> json) {
  return DiscountRange(
    min: (json['minQty'] ?? 0).toInt(),
    max: (json['maxQty'] ?? -1).toInt(),
    price: (json['unitPrice'] ?? 0).toDouble(),
    discount: (json['profit'] ?? 0).toDouble(),
  );
}
}
