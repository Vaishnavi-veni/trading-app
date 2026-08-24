import 'package:flutter/material.dart';

import '../data/datasources/stock_data.dart';
import '../widgets/stock_price_tile.dart';

class MarketScreen extends StatelessWidget {
  const MarketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Market')),
      body: ListView.separated(
        itemCount: StockData.stocks.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final stock = StockData.stocks[index];

          return StockPriceTile(key: ValueKey(stock.symbol), stock: stock);
        },
      ),
    );
  }
}
