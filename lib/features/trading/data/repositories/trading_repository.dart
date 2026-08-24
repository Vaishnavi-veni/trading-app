import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/holding.dart';
import '../models/order.dart';
import '../models/order_side.dart';
import '../models/wallet.dart';

class TradingRepository {
  static const _walletKey = 'trading_wallet';
  static const _holdingsKey = 'trading_holdings';
  static const _ordersKey = 'trading_orders';

  Wallet _wallet = const Wallet(
    balancePaise: 10000000, // ₹1,00,000
  );

  final Map<String, Holding> _holdings = {};

  final List<Order> _orders = [];

  SharedPreferences? _preferences;

  Wallet get wallet => _wallet;

  List<Holding> get holdings => List.unmodifiable(_holdings.values);

  List<Order> get orders => List.unmodifiable(_orders);

  Future<void> load() async {
    _preferences = await SharedPreferences.getInstance();

    final walletJson = _preferences!.getString(_walletKey);

    print('WALLET SAVED DATA: $walletJson');

    if (walletJson != null) {
      final decoded = jsonDecode(walletJson) as Map<String, dynamic>;

      _wallet = Wallet.fromJson(decoded);
    }

    print('WALLET AFTER LOAD: ${_wallet.balancePaise}');
    final holdingsJson = _preferences!.getString(_holdingsKey);

    if (holdingsJson != null) {
      final decoded = jsonDecode(holdingsJson) as List<dynamic>;

      _holdings.clear();

      for (final item in decoded) {
        final holding = Holding.fromJson(item as Map<String, dynamic>);

        _holdings[holding.symbol] = holding;
      }
    }

    final ordersJson = _preferences!.getString(_ordersKey);

    if (ordersJson != null) {
      final decoded = jsonDecode(ordersJson) as List<dynamic>;

      _orders.clear();

      for (final item in decoded) {
        _orders.add(Order.fromJson(item as Map<String, dynamic>));
      }
    }
  }

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

    await _save();

    return order;
  }

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

    // First purchase
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

  Future<void> _save() async {
    final preferences = _preferences;

    if (preferences == null) {
      throw StateError(
        'TradingRepository has not been initialized. '
        'Call load() before trading.',
      );
    }

    await preferences.setString(_walletKey, jsonEncode(_wallet.toJson()));

    await preferences.setString(
      _holdingsKey,
      jsonEncode(_holdings.values.map((holding) => holding.toJson()).toList()),
    );

    await preferences.setString(
      _ordersKey,
      jsonEncode(_orders.map((order) => order.toJson()).toList()),
    );

    print('WALLET SAVED: ${_wallet.balancePaise}');
  }
}
