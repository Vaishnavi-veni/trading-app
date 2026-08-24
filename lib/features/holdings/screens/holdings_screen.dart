import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_app/features/holdings/widgets/holdings_row.dart';

import '../../market/bloc/market_bloc.dart';
import '../../market/bloc/market_state.dart';
import '../../trading/screens/order_ticket_screen.dart';

import '../bloc/holdings_bloc.dart';
import '../bloc/holdings_event.dart';
import '../bloc/holdings_state.dart';

class HoldingsScreen extends StatelessWidget {
  const HoldingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Holdings')),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              return ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: holdingsState.holdings.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final holding = holdingsState.holdings[index];

                  return HoldingRow(
                    holding: holding,
                    marketPrice: prices[holding.symbol],
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
    );
  }
}
