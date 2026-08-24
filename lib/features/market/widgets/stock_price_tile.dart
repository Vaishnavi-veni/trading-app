import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

        final tickColor = marketPrice == null
            ? Colors.transparent
            : marketPrice.tickIsUp
            ? Colors.green
            : marketPrice.tickIsDown
            ? Colors.red
            : Colors.transparent;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(color: tickColor.withValues(alpha: 0.08)),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
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
                  '${changePaise >= 0 ? '+' : ''}'
                  '₹${(changePaise / 100).toStringAsFixed(2)} '
                  '(${changePercent.toStringAsFixed(2)}%)',
                  style: TextStyle(
                    color: changePaise > 0
                        ? Colors.green
                        : changePaise < 0
                        ? Colors.red
                        : Colors.grey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
