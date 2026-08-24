import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trading_app/features/trading/bloc/order_bloc.dart';
import 'package:trading_app/features/trading/bloc/order_event.dart';
import 'package:trading_app/features/trading/bloc/order_state.dart';
import 'package:trading_app/features/trading/screens/order_confirmation_screen.dart';

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

  String? _validateQuantity(String value) {
    if (value.trim().isEmpty) {
      return 'Quantity is required';
    }

    final quantity = int.tryParse(value);

    if (quantity == null) {
      return 'Enter a whole number';
    }

    if (quantity <= 0) {
      return 'Quantity must be greater than zero';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final stock = StockData.stocks.firstWhere(
      (stock) => stock.symbol == widget.symbol,
    );

    return Scaffold(
      appBar: AppBar(title: Text('${stock.symbol} Order')),
      body: BlocListener<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state.status == OrderStatus.failure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage ?? 'Order failed.')),
            );
          }

          if (state.status == OrderStatus.success) {
            final order = state.lastOrder;

            if (order == null) {
              return;
            }

            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => OrderConfirmationScreen(order: order),
              ),
            );
          }
        },
        child: BlocSelector<MarketBloc, MarketState, MarketPrice?>(
          selector: (state) => state.prices[widget.symbol],
          builder: (context, marketPrice) {
            final ltpPaise = marketPrice?.pricePaise ?? stock.initialPricePaise;

            final quantity = int.tryParse(_quantityController.text) ?? 0;

            final orderValuePaise = quantity * ltpPaise;

            return BlocSelector<OrderBloc, OrderState, int>(
              selector: (state) => state.wallet.balancePaise,
              builder: (context, balancePaise) {
                final insufficientBalance =
                    _side == OrderSide.buy && orderValuePaise > balancePaise;

                final canSubmit = quantity > 0 && !insufficientBalance;

                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    // -------------------------
                    // STOCK
                    // -------------------------
                    Text(
                      stock.symbol,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 4),

                    Text(stock.name),

                    const SizedBox(height: 24),

                    // -------------------------
                    // LIVE PRICE
                    // -------------------------
                    _PriceCard(ltpPaise: ltpPaise),

                    const SizedBox(height: 24),

                    // -------------------------
                    // BUY / SELL
                    // -------------------------
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

                    // -------------------------
                    // QUANTITY
                    // -------------------------
                    TextField(
                      controller: _quantityController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantity',
                        hintText: 'Enter quantity',
                        border: const OutlineInputBorder(),
                        errorText: _validateQuantity(_quantityController.text),
                      ),
                      onChanged: (_) {
                        setState(() {});
                      },
                    ),

                    const SizedBox(height: 24),

                    // -------------------------
                    // ORDER SUMMARY
                    // -------------------------
                    _OrderSummary(
                      balancePaise: balancePaise,
                      quantity: quantity,
                      ltpPaise: ltpPaise,
                      orderValuePaise: orderValuePaise,
                    ),

                    // -------------------------
                    // BALANCE ERROR
                    // -------------------------
                    if (insufficientBalance)
                      const Padding(
                        padding: EdgeInsets.only(top: 12),
                        child: Text(
                          'Insufficient balance for this order',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),

                    const SizedBox(height: 32),

                    // -------------------------
                    // SUBMIT
                    // -------------------------
                    SizedBox(
                      height: 52,
                      child: FilledButton(
                        onPressed: canSubmit
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
            );
          },
        ),
      ),
    );
  }

  void _submitOrder(BuildContext context, String symbol, int quantity) {
    context.read<OrderBloc>().add(
      SubmitOrder(symbol: symbol, side: _side, quantity: quantity),
    );
  }
}

// ======================================================
// PRICE CARD
// ======================================================

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

// ======================================================
// ORDER SUMMARY
// ======================================================

class _OrderSummary extends StatelessWidget {
  final int balancePaise;
  final int quantity;
  final int ltpPaise;
  final int orderValuePaise;

  const _OrderSummary({
    required this.balancePaise,
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
            // Available balance
            _SummaryRow(
              label: 'Available Balance',
              value: '₹${(balancePaise / 100).toStringAsFixed(2)}',
              bold: true,
            ),

            const SizedBox(height: 16),

            // Quantity
            _SummaryRow(label: 'Quantity', value: quantity.toString()),

            const SizedBox(height: 12),

            // Current price
            _SummaryRow(
              label: 'Price',
              value: '₹${(ltpPaise / 100).toStringAsFixed(2)}',
            ),

            const Divider(height: 24),

            // Order value
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

// ======================================================
// SUMMARY ROW
// ======================================================

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
