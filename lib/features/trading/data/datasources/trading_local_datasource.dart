import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/holding.dart';
import '../models/order.dart';
import '../models/wallet.dart';

class TradingLocalDataSource {
  static const _walletKey = 'trading_wallet';
  static const _holdingsKey = 'trading_holdings';
  static const _ordersKey = 'trading_orders';

  Future<void> saveWallet(Wallet wallet) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_walletKey, jsonEncode(wallet.toJson()));
  }

  Future<Wallet?> loadWallet() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(_walletKey);

    if (data == null) {
      return null;
    }

    return Wallet.fromJson(jsonDecode(data) as Map<String, dynamic>);
  }

  Future<void> saveHoldings(List<Holding> holdings) async {
    final prefs = await SharedPreferences.getInstance();

    final data = holdings.map((holding) => holding.toJson()).toList();

    await prefs.setString(_holdingsKey, jsonEncode(data));
  }

  Future<List<Holding>> loadHoldings() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(_holdingsKey);

    if (data == null) {
      return [];
    }

    final decoded = jsonDecode(data) as List;

    return decoded
        .map((item) => Holding.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<void> saveOrders(List<Order> orders) async {
    final prefs = await SharedPreferences.getInstance();

    final data = orders.map((order) => order.toJson()).toList();

    await prefs.setString(_ordersKey, jsonEncode(data));
  }

  Future<List<Order>> loadOrders() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString(_ordersKey);

    if (data == null) {
      return [];
    }

    final decoded = jsonDecode(data) as List;

    return decoded
        .map((item) => Order.fromJson(Map<String, dynamic>.from(item as Map)))
        .toList();
  }
}
