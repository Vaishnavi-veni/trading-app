import 'package:flutter/material.dart';
import 'package:trading_app/features/market/data/datasources/stock_data.dart';

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

          return ListTile(
            title: Text(
              stock.symbol,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(stock.name),
            trailing: Text(
              '₹${(stock.initialPricePaise / 100).toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
    );
  }
}
