import 'dart:async';
import 'dart:math';

import '../models/market_tick.dart';
import 'stock_data.dart';

class MockMarketFeed {
  MockMarketFeed({this.tickInterval = const Duration(milliseconds: 500)});

  /// How frequently the feed emits a tick.
  ///
  /// Example:
  /// 500ms  -> ~2 ticks/sec overall
  /// 100ms  -> ~10 ticks/sec overall
  /// 20ms   -> ~50 ticks/sec overall
  final Duration tickInterval;

  final Random _random = Random();

  final Map<String, int> _prices = {
    for (final stock in StockData.stocks) stock.symbol: stock.initialPricePaise,
  };

  final Map<String, int> _referencePrices = {
    for (final stock in StockData.stocks) stock.symbol: stock.initialPricePaise,
  };

  final StreamController<MarketTick> _controller =
      StreamController<MarketTick>.broadcast();

  Timer? _timer;

  Stream<MarketTick> get ticks => _controller.stream;

  void start() {
    if (_timer != null) {
      return;
    }

    _timer = Timer.periodic(tickInterval, (_) => _emitTick());
  }

  void _emitTick() {
    if (_controller.isClosed) {
      return;
    }

    final stock = StockData.stocks[_random.nextInt(StockData.stocks.length)];

    final previousPrice = _prices[stock.symbol]!;

    // Random movement between -0.10% and +0.10%.
    final movementPercent = (_random.nextDouble() * 0.2) - 0.1;

    var newPrice = (previousPrice * (1 + movementPercent / 100)).round();

    // Never allow the price to become zero or negative.
    newPrice = max(1, newPrice);

    // Don't emit an unnecessary update.
    if (newPrice == previousPrice) {
      return;
    }

    _prices[stock.symbol] = newPrice;

    _controller.add(
      MarketTick(
        symbol: stock.symbol,
        pricePaise: newPrice,
        previousPricePaise: previousPrice,
      ),
    );
  }

  int getPrice(String symbol) {
    return _prices[symbol] ?? 0;
  }

  int getReferencePrice(String symbol) {
    return _referencePrices[symbol] ?? 0;
  }

  Map<String, int> get currentPrices {
    return Map.unmodifiable(_prices);
  }

  Future<void> dispose() async {
    _timer?.cancel();
    _timer = null;

    await _controller.close();
  }
}
