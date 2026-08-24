import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../market/bloc/market_bloc.dart';
import '../../market/bloc/market_state.dart';
import '../../market/data/datasources/stock_data.dart';
import '../data/models/order_side.dart';

class OrderTicketScreen extends StatefulWidget {
  final String symbol;

  const OrderTicketScreen({super.key, required this.symbol});

  @override
  State<OrderTicketScreen> createState() => _OrderTicketScreenState();
}

class _OrderTicketScreenState extends State<OrderTicketScreen> {
  OrderSide _side = OrderSide.buy;

  final TextEditingController _quantityController = TextEditingController();

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stock = StockData.stocks.firstWhere(
      (stock) => stock.symbol == widget.symbol,
    );

    return Scaffold(
      appBar: AppBar(title: Text('${stock.symbol} Order')),
      body: BlocSelector<MarketBloc, MarketState, MarketPrice?>(
        selector: (state) => state.prices[widget.symbol],
        builder: (context, marketPrice) {
          final ltpPaise = marketPrice?.pricePaise ?? stock.initialPricePaise;

          final quantity = int.tryParse(_quantityController.text) ?? 0;

          final orderValuePaise = quantity * ltpPaise;

          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Text(
                stock.symbol,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(stock.name),

              const SizedBox(height: 24),

              _PriceCard(ltpPaise: ltpPaise),

              const SizedBox(height: 24),

              SegmentedButton<OrderSide>(
                segments: const [
                  ButtonSegment(
                    value: OrderSide.buy,
                    label: Text('Buy'),
                    icon: Icon(Icons.trending_up),
                  ),
                  ButtonSegment(
                    value: OrderSide.sell,
                    label: Text('Sell'),
                    icon: Icon(Icons.trending_down),
                  ),
                ],
                selected: {_side},
                onSelectionChanged: (selection) {
                  setState(() {
                    _side = selection.first;
                  });
                },
              ),

              const SizedBox(height: 24),

              TextField(
                controller: _quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity',
                  hintText: 'Enter quantity',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) {
                  setState(() {});
                },
              ),

              const SizedBox(height: 24),

              _OrderSummary(
                quantity: quantity,
                ltpPaise: ltpPaise,
                orderValuePaise: orderValuePaise,
              ),

              const SizedBox(height: 32),

              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: quantity > 0
                      ? () {
                          _submitOrder(context, stock.symbol, quantity);
                        }
                      : null,
                  child: Text(
                    _side == OrderSide.buy
                        ? 'Buy ${stock.symbol}'
                        : 'Sell ${stock.symbol}',
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _submitOrder(BuildContext context, String symbol, int quantity) {
    // OrderBloc will be added next.
    //
    // For now this confirms that the ticket
    // has the correct stock and quantity.
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${_side.name.toUpperCase()} '
          '$quantity $symbol',
        ),
      ),
    );
  }
}

class _PriceCard extends StatelessWidget {
  final int ltpPaise;

  const _PriceCard({required this.ltpPaise});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('LTP', style: TextStyle(fontWeight: FontWeight.w600)),
            Text(
              '₹${(ltpPaise / 100).toStringAsFixed(2)}',
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderSummary extends StatelessWidget {
  final int quantity;
  final int ltpPaise;
  final int orderValuePaise;

  const _OrderSummary({
    required this.quantity,
    required this.ltpPaise,
    required this.orderValuePaise,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SummaryRow(label: 'Quantity', value: quantity.toString()),
            const SizedBox(height: 12),
            _SummaryRow(
              label: 'Price',
              value: '₹${(ltpPaise / 100).toStringAsFixed(2)}',
            ),
            const Divider(height: 24),
            _SummaryRow(
              label: 'Order value',
              value: '₹${(orderValuePaise / 100).toStringAsFixed(2)}',
              bold: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(
            fontWeight: bold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}
