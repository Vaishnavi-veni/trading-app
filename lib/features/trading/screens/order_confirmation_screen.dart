import 'package:flutter/material.dart';

import '../data/models/order.dart';
import '../data/models/order_side.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final Order order;

  const OrderConfirmationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final isBuy = order.side == OrderSide.buy;
    final orderValuePaise = order.quantity * order.pricePaise;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Confirmation'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const SizedBox(height: 40),

            const CircleAvatar(radius: 36, child: Icon(Icons.check, size: 40)),

            const SizedBox(height: 20),

            Text(
              'Order Successful',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 8),

            Text(
              isBuy
                  ? 'Your buy order was executed successfully.'
                  : 'Your sell order was executed successfully.',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _InfoRow(label: 'Stock', value: order.symbol),
                    _InfoRow(label: 'Side', value: isBuy ? 'BUY' : 'SELL'),
                    _InfoRow(
                      label: 'Quantity',
                      value: order.quantity.toString(),
                    ),
                    _InfoRow(
                      label: 'Execution Price',
                      value: '₹${(order.pricePaise / 100).toStringAsFixed(2)}',
                    ),
                    const Divider(height: 24),
                    _InfoRow(
                      label: 'Order Value',
                      value: '₹${(orderValuePaise / 100).toStringAsFixed(2)}',
                      bold: true,
                    ),
                    _InfoRow(label: 'Order ID', value: order.id),
                  ],
                ),
              ),
            ),

            const Spacer(),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Done'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _InfoRow({required this.label, required this.value, this.bold = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
