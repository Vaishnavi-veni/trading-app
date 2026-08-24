import '../data/models/order_side.dart';

sealed class OrderEvent {
  const OrderEvent();
}

class SubmitOrder extends OrderEvent {
  final String symbol;
  final OrderSide side;
  final int quantity;
  final int executionPricePaise;

  const SubmitOrder({
    required this.symbol,
    required this.side,
    required this.quantity,
    required this.executionPricePaise,
  });
}
