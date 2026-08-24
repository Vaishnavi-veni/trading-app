import 'package:flutter/material.dart';

import '../../market/bloc/market_state.dart';
import '../../trading/data/models/holding.dart';

class HoldingRow extends StatelessWidget {
  final Holding holding;
  final MarketPrice? marketPrice;
  final VoidCallback? onTap;

  const HoldingRow({
    super.key,
    required this.holding,
    required this.marketPrice,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final ltpPaise = marketPrice?.pricePaise ?? holding.averagePricePaise;

    final investedPaise = holding.quantity * holding.averagePricePaise;

    final currentValuePaise = holding.quantity * ltpPaise;

    final pnlPaise = currentValuePaise - investedPaise;

    final pnlPercent = investedPaise == 0
        ? 0.0
        : (pnlPaise / investedPaise) * 100;

    final isProfit = pnlPaise >= 0;

    return ListTile(
      onTap: onTap,
      title: Row(
        children: [
          Expanded(
            child: Text(
              holding.symbol,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            '₹${(ltpPaise / 100).toStringAsFixed(2)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Qty: ${holding.quantity}  •  '
              'Avg: ₹${(holding.averagePricePaise / 100).toStringAsFixed(2)}',
            ),
            const SizedBox(height: 4),
            Text('Value: ₹${(currentValuePaise / 100).toStringAsFixed(2)}'),
          ],
        ),
      ),
      trailing: Text(
        '${isProfit ? '+' : ''}'
        '₹${(pnlPaise / 100).toStringAsFixed(2)}\n'
        '(${isProfit ? '+' : ''}${pnlPercent.toStringAsFixed(2)}%)',
        textAlign: TextAlign.end,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: isProfit ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
