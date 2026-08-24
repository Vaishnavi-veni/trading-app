import '../data/models/holding.dart';
import '../data/models/order.dart';
import '../data/models/wallet.dart';

enum OrderStatus { initial, submitting, success, failure }

class OrderState {
  final OrderStatus status;
  final Wallet wallet;
  final List<Holding> holdings;
  final List<Order> orders;
  final Order? lastOrder;
  final String? errorMessage;

  const OrderState({
    this.status = OrderStatus.initial,
    this.wallet = const Wallet(balancePaise: 10000000),
    this.holdings = const [],
    this.orders = const [],
    this.lastOrder,
    this.errorMessage,
  });

  OrderState copyWith({
    OrderStatus? status,
    Wallet? wallet,
    List<Holding>? holdings,
    List<Order>? orders,
    Order? lastOrder,
    String? errorMessage,
  }) {
    return OrderState(
      status: status ?? this.status,
      wallet: wallet ?? this.wallet,
      holdings: holdings ?? this.holdings,
      orders: orders ?? this.orders,
      lastOrder: lastOrder ?? this.lastOrder,
      errorMessage: errorMessage,
    );
  }
}
