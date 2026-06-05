import 'product.dart';
import 'discount_range.dart';

class CartItem {
  final String id; 
  final Product product;
  int quantity;

  CartItem({
     required this.id,
    required this.product,
    this.quantity = 1,
  });

  
  double get currentPrice => product.getPriceForQuantity(quantity);

  double get totalPrice => currentPrice * quantity;

  double get totalDiscount =>
      product.getDiscountForQuantity(quantity) * quantity;

  double get savings =>
      (product.currentPrice - currentPrice) * quantity;

 
  DiscountRange? get currentTier =>
      product.getDiscountRangeForQuantity(quantity);

  DiscountRange? get nextTier =>
      product.getNextDiscountTier(quantity);

  int? get unitsNeededForNextTier =>
      product.unitsNeededForNextTier(quantity);

  Map<String, dynamic> toJson() {
    return {
      'product': product.toJson(), 
      'quantity': quantity,
    };
  }

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['_id'],
      product: Product.fromJson(json['product']),
      quantity: json['quantity'] as int,
    );
  }

  CartItem copyWith({
    Product? product,
    int? quantity,
  }) {
    return CartItem(
      id:id,
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
