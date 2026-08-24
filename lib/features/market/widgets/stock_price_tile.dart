import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_app/features/market/data/datasources/stock_data.dart';
import 'package:trading_app/features/market/data/models/stock_model.dart';

import '../bloc/market_bloc.dart';
import '../bloc/market_state.dart';

class StockPriceTile extends StatelessWidget {
  final StockModel stock;

  const StockPriceTile({super.key, required this.stock});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MarketBloc, MarketState, MarketPrice?>(
      selector: (state) => state.prices[stock.symbol],
      builder: (context, marketPrice) {
        final pricePaise = marketPrice?.pricePaise ?? stock.initialPricePaise;

        final changePaise = marketPrice?.changePaise ?? 0;

        final changePercent = marketPrice?.changePercent ?? 0;

        final isUp = changePaise > 0;
        final isDown = changePaise < 0;

        return ListTile(
          title: Text(
            stock.symbol,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(stock.name),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${(pricePaise / 100).toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 4),
              Text(
                '${isUp ? '+' : ''}'
                '₹${(changePaise / 100).toStringAsFixed(2)} '
                '(${changePercent.toStringAsFixed(2)}%)',
                style: TextStyle(
                  color: isUp
                      ? Colors.green
                      : isDown
                      ? Colors.red
                      : Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
