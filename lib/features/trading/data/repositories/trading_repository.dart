import '../datasources/trading_local_datasource.dart';
import '../models/holding.dart';
import '../models/order.dart';
import '../models/order_side.dart';
import '../models/wallet.dart';

class TradingRepository {
  final TradingLocalDataSource localDataSource;

  Wallet _wallet = const Wallet(
    balancePaise: 10000000, // ₹1,00,000
  );

  final Map<String, Holding> _holdings = {};

  final List<Order> _orders = [];

  TradingRepository({required this.localDataSource});

  Wallet get wallet => _wallet;

  List<Holding> get holdings => List.unmodifiable(_holdings.values);

  List<Order> get orders => List.unmodifiable(_orders);

  // ============================================================
  // LOAD PERSISTED DATA
  // ============================================================

  Future<void> load() async {
    final savedWallet = await localDataSource.loadWallet();

    if (savedWallet != null) {
      _wallet = savedWallet;
    }

    final savedHoldings = await localDataSource.loadHoldings();

    _holdings
      ..clear()
      ..addEntries(
        savedHoldings.map((holding) => MapEntry(holding.symbol, holding)),
      );

    final savedOrders = await localDataSource.loadOrders();

    _orders
      ..clear()
      ..addAll(savedOrders);
  }

  // ============================================================
  // BUY / SELL VALIDATION
  // ============================================================

  bool canBuy(int orderValuePaise) {
    return orderValuePaise <= _wallet.balancePaise;
  }

  bool canSell(String symbol, int quantity) {
    final holding = _holdings[symbol];

    if (holding == null) {
      return false;
    }

    return holding.quantity >= quantity;
  }

  // ============================================================
  // EXECUTE ORDER
  // ============================================================

  Future<Order> executeOrder({
    required String symbol,
    required OrderSide side,
    required int quantity,
    required int executionPricePaise,
  }) async {
    if (quantity <= 0) {
      throw Exception('Quantity must be greater than zero.');
    }

    if (executionPricePaise <= 0) {
      throw Exception('Invalid execution price.');
    }

    final orderValuePaise = quantity * executionPricePaise;

    if (side == OrderSide.buy) {
      if (!canBuy(orderValuePaise)) {
        throw Exception('Insufficient balance.');
      }

      _executeBuy(
        symbol: symbol,
        quantity: quantity,
        pricePaise: executionPricePaise,
      );
    } else {
      if (!canSell(symbol, quantity)) {
        throw Exception('Insufficient quantity available to sell.');
      }

      _executeSell(symbol: symbol, quantity: quantity);

      _wallet = _wallet.copyWith(
        balancePaise: _wallet.balancePaise + orderValuePaise,
      );
    }

    final order = Order(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      symbol: symbol,
      side: side,
      quantity: quantity,
      pricePaise: executionPricePaise,
      createdAt: DateTime.now(),
    );

    _orders.add(order);

    // Persist everything after successful transaction.
    await _persist();

    return order;
  }

  // ============================================================
  // BUY
  // ============================================================

  void _executeBuy({
    required String symbol,
    required int quantity,
    required int pricePaise,
  }) {
    final orderValuePaise = quantity * pricePaise;

    _wallet = _wallet.copyWith(
      balancePaise: _wallet.balancePaise - orderValuePaise,
    );

    final existing = _holdings[symbol];

    if (existing == null) {
      _holdings[symbol] = Holding(
        symbol: symbol,
        quantity: quantity,
        averagePricePaise: pricePaise,
      );

      return;
    }

    final oldInvested = existing.quantity * existing.averagePricePaise;

    final newInvested = quantity * pricePaise;

    final totalQuantity = existing.quantity + quantity;

    final newAveragePrice = (oldInvested + newInvested) ~/ totalQuantity;

    _holdings[symbol] = existing.copyWith(
      quantity: totalQuantity,
      averagePricePaise: newAveragePrice,
    );
  }

  // ============================================================
  // SELL
  // ============================================================

  void _executeSell({required String symbol, required int quantity}) {
    final existing = _holdings[symbol];

    if (existing == null) {
      throw Exception('Holding not found.');
    }

    final remainingQuantity = existing.quantity - quantity;

    if (remainingQuantity == 0) {
      _holdings.remove(symbol);
    } else {
      _holdings[symbol] = existing.copyWith(quantity: remainingQuantity);
    }
  }

  // ============================================================
  // PERSIST EVERYTHING
  // ============================================================

  Future<void> _persist() async {
    await localDataSource.saveWallet(_wallet);

    await localDataSource.saveHoldings(_holdings.values.toList());

    await localDataSource.saveOrders(_orders);
  }
}
