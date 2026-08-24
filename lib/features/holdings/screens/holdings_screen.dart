import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trading_app/features/holdings/widgets/holdings_row.dart';
import 'package:trading_app/features/trading/data/models/holding.dart';
import 'package:trading_app/features/trading/screens/order_history_screen.dart';

import '../../market/bloc/market_bloc.dart';
import '../../market/bloc/market_state.dart';
import '../../trading/bloc/order_bloc.dart';
import '../../trading/bloc/order_state.dart';
import '../../trading/screens/order_ticket_screen.dart';

import '../bloc/holdings_bloc.dart';
import '../bloc/holdings_event.dart';
import '../bloc/holdings_state.dart';

class HoldingsScreen extends StatelessWidget {
  const HoldingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listenWhen: (previous, current) =>
          previous.status != current.status &&
          current.status == OrderStatus.success,
      listener: (context, state) {
        context.read<HoldingsBloc>().add(const LoadHoldings());
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Holdings'),
          actions: [
            IconButton(
              tooltip: 'Order History',
              icon: const Icon(Icons.receipt_long_outlined),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<HoldingsBloc, HoldingsState>(
          builder: (context, holdingsState) {
            if (holdingsState.status == HoldingsStatus.loading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (holdingsState.status == HoldingsStatus.failure) {
              return Center(
                child: Text(
                  holdingsState.errorMessage ?? 'Failed to load holdings.',
                ),
              );
            }

            if (holdingsState.holdings.isEmpty) {
              return const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.account_balance_wallet_outlined, size: 56),
                    SizedBox(height: 12),
                    Text(
                      'No holdings yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text('Your purchased stocks will appear here.'),
                  ],
                ),
              );
            }

            return BlocSelector<
              MarketBloc,
              MarketState,
              Map<String, MarketPrice>
            >(
              selector: (state) => state.prices,
              builder: (context, prices) {
                final summary = _calculateSummary(
                  holdingsState.holdings,
                  prices,
                );

                final sortedHoldings = _sortHoldings(
                  holdings: holdingsState.holdings,
                  prices: prices,
                  sort: holdingsState.sort,
                );

                return ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: sortedHoldings.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _PortfolioSummary(
                        sort: holdingsState.sort,
                        investedPaise: summary.investedPaise,
                        currentValuePaise: summary.currentValuePaise,
                        pnlPaise: summary.pnlPaise,
                        pnlPercent: summary.pnlPercent,
                      );
                    }

                    final holding = sortedHoldings[index - 1];

                    return HoldingRow(
                      holding: holding,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                OrderTicketScreen(symbol: holding.symbol),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _PortfolioSummaryData {
  final int investedPaise;
  final int currentValuePaise;
  final int pnlPaise;
  final double pnlPercent;

  const _PortfolioSummaryData({
    required this.investedPaise,
    required this.currentValuePaise,
    required this.pnlPaise,
    required this.pnlPercent,
  });
}

_PortfolioSummaryData _calculateSummary(
  List<Holding> holdings,
  Map<String, MarketPrice> prices,
) {
  var investedPaise = 0;
  var currentValuePaise = 0;

  for (final holding in holdings) {
    final ltpPaise =
        prices[holding.symbol]?.pricePaise ?? holding.averagePricePaise;

    investedPaise += holding.quantity * holding.averagePricePaise;

    currentValuePaise += holding.quantity * ltpPaise;
  }

  final pnlPaise = currentValuePaise - investedPaise;

  final pnlPercent = investedPaise == 0 ? 0.0 : pnlPaise / investedPaise * 100;

  return _PortfolioSummaryData(
    investedPaise: investedPaise,
    currentValuePaise: currentValuePaise,
    pnlPaise: pnlPaise,
    pnlPercent: pnlPercent,
  );
}

class _PortfolioSummary extends StatelessWidget {
  final HoldingsSort sort;
  final int investedPaise;
  final int currentValuePaise;
  final int pnlPaise;
  final double pnlPercent;

  const _PortfolioSummary({
    required this.sort,
    required this.investedPaise,
    required this.currentValuePaise,
    required this.pnlPaise,
    required this.pnlPercent,
  });

  @override
  Widget build(BuildContext context) {
    final isProfit = pnlPaise >= 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Portfolio',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                DropdownButtonHideUnderline(
                  child: DropdownButton<HoldingsSort>(
                    value: sort,
                    items: const [
                      DropdownMenuItem(
                        value: HoldingsSort.pnl,
                        child: Text('P&L'),
                      ),
                      DropdownMenuItem(
                        value: HoldingsSort.symbol,
                        child: Text('Symbol'),
                      ),
                      DropdownMenuItem(
                        value: HoldingsSort.currentValue,
                        child: Text('Current Value'),
                      ),
                    ],
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }

                      context.read<HoldingsBloc>().add(
                        ChangeHoldingsSort(value),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _SummaryItem(
              label: 'Total invested',
              value: '₹${(investedPaise / 100).toStringAsFixed(2)}',
            ),

            const SizedBox(height: 10),

            _SummaryItem(
              label: 'Current value',
              value: '₹${(currentValuePaise / 100).toStringAsFixed(2)}',
            ),

            const Divider(height: 24),

            _SummaryItem(
              label: 'Total P&L',
              value:
                  '${isProfit ? '+' : ''}'
                  '₹${(pnlPaise / 100).toStringAsFixed(2)} '
                  '(${isProfit ? '+' : ''}'
                  '${pnlPercent.toStringAsFixed(2)}%)',
              valueColor: isProfit ? Colors.green : Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryItem({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, color: valueColor),
        ),
      ],
    );
  }
}

List<Holding> _sortHoldings({
  required List<Holding> holdings,
  required Map<String, MarketPrice> prices,
  required HoldingsSort sort,
}) {
  final result = List<Holding>.from(holdings);

  switch (sort) {
    case HoldingsSort.symbol:
      result.sort((a, b) => a.symbol.compareTo(b.symbol));
      break;

    case HoldingsSort.currentValue:
      result.sort((a, b) {
        final aPrice = prices[a.symbol]?.pricePaise ?? a.averagePricePaise;

        final bPrice = prices[b.symbol]?.pricePaise ?? b.averagePricePaise;

        final aValue = a.quantity * aPrice;

        final bValue = b.quantity * bPrice;

        return bValue.compareTo(aValue);
      });
      break;

    case HoldingsSort.pnl:
      result.sort((a, b) {
        final aPrice = prices[a.symbol]?.pricePaise ?? a.averagePricePaise;

        final bPrice = prices[b.symbol]?.pricePaise ?? b.averagePricePaise;

        final aInvested = a.quantity * a.averagePricePaise;

        final bInvested = b.quantity * b.averagePricePaise;

        final aCurrent = a.quantity * aPrice;

        final bCurrent = b.quantity * bPrice;

        final aPnl = aCurrent - aInvested;

        final bPnl = bCurrent - bInvested;

        return bPnl.compareTo(aPnl);
      });
      break;
  }

  return result;
}
