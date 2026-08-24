import 'order_side.dart';

class Order {
  final String id;
  final String symbol;
  final OrderSide side;
  final int quantity;
  final int pricePaise;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.pricePaise,
    required this.createdAt,
  });

  int get valuePaise {
    return quantity * pricePaise;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'symbol': symbol,
      'side': side.name,
      'quantity': quantity,
      'pricePaise': pricePaise,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      symbol: json['symbol'] as String,
      side: OrderSide.values.byName(json['side'] as String),
      quantity: json['quantity'] as int,
      pricePaise: json['pricePaise'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
