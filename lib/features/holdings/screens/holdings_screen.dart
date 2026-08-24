import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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

  static const backgroundColor = Color(0xFF0B0F14);
  static const cardColor = Color(0xFF151B23);
  static const borderColor = Color(0xFF202832);
  static const secondaryTextColor = Color(0xFF7D8794);
  static const accentColor = Color(0xFF4ADE80);
  static const lossColor = Color(0xFFF87171);

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
        backgroundColor: backgroundColor,

        appBar: AppBar(
          backgroundColor: backgroundColor,
          elevation: 0,
          title: Text(
            'Holdings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          actions: [
            IconButton(
              tooltip: 'Order History',
              icon: Icon(
                Icons.receipt_long_outlined,
                color: Colors.white,
                size: 22.sp,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
                );
              },
            ),
            SizedBox(width: 8.w),
          ],
        ),

        body: BlocBuilder<HoldingsBloc, HoldingsState>(
          builder: (context, holdingsState) {
            if (holdingsState.status == HoldingsStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(color: accentColor),
              );
            }

            if (holdingsState.status == HoldingsStatus.failure) {
              return _ErrorState(
                message:
                    holdingsState.errorMessage ?? 'Failed to load holdings.',
              );
            }

            if (holdingsState.holdings.isEmpty) {
              return const _EmptyHoldings();
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
                  padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 100.h),
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

                    return Padding(
                      padding: EdgeInsets.only(bottom: 10.h),
                      child: HoldingRow(
                        holding: holding,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  OrderTicketScreen(symbol: holding.symbol),
                            ),
                          );
                        },
                      ),
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

  static const cardColor = Color(0xFF151B23);
  static const borderColor = Color(0xFF202832);
  static const secondaryTextColor = Color(0xFF7D8794);
  static const accentColor = Color(0xFF4ADE80);
  static const lossColor = Color(0xFFF87171);

  @override
  Widget build(BuildContext context) {
    final isProfit = pnlPaise >= 0;
    final pnlColor = isProfit ? accentColor : lossColor;

    return Container(
      margin: EdgeInsets.only(bottom: 18.h),
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  'Portfolio',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 19.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              Container(
                height: 40.h,
                padding: EdgeInsets.symmetric(horizontal: 10.w),
                decoration: BoxDecoration(
                  color: const Color(0xFF1B222C),
                  borderRadius: BorderRadius.circular(11.r),
                  border: Border.all(color: borderColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<HoldingsSort>(
                    value: sort,
                    dropdownColor: const Color(0xFF1B222C),
                    icon: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: secondaryTextColor,
                      size: 18.sp,
                    ),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
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
                        child: Text('Value'),
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
              ),
            ],
          ),

          SizedBox(height: 20.h),

          // Current value
          Text(
            'Current value',
            style: TextStyle(color: secondaryTextColor, fontSize: 12.sp),
          ),

          SizedBox(height: 5.h),

          Text(
            '₹${(currentValuePaise / 100).toStringAsFixed(2)}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),

          SizedBox(height: 10.h),

          // P&L badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: pnlColor.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isProfit
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  size: 16.sp,
                  color: pnlColor,
                ),
                SizedBox(width: 5.w),
                Text(
                  '${isProfit ? '+' : ''}'
                  '₹${(pnlPaise / 100).toStringAsFixed(2)}',
                  style: TextStyle(
                    color: pnlColor,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(width: 5.w),
                Text(
                  '(${isProfit ? '+' : ''}'
                  '${pnlPercent.toStringAsFixed(2)}%)',
                  style: TextStyle(
                    color: pnlColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 20.h),

          Divider(height: 1.h, color: borderColor),

          SizedBox(height: 16.h),

          Row(
            children: [
              Expanded(
                child: _SummaryItem(
                  label: 'Total invested',
                  value: '₹${(investedPaise / 100).toStringAsFixed(2)}',
                ),
              ),

              Container(width: 1.w, height: 38.h, color: borderColor),

              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(left: 16.w),
                  child: _SummaryItem(
                    label: 'Current value',
                    value: '₹${(currentValuePaise / 100).toStringAsFixed(2)}',
                  ),
                ),
              ),
            ],
          ),
        ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: const Color(0xFF7D8794), fontSize: 11.sp),
        ),
        SizedBox(height: 5.h),
        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: valueColor ?? Colors.white,
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _EmptyHoldings extends StatelessWidget {
  const _EmptyHoldings();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: const Color(0xFF151B23),
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Icon(
                Icons.account_balance_wallet_outlined,
                size: 36.sp,
                color: const Color(0xFF596573),
              ),
            ),

            SizedBox(height: 20.h),

            Text(
              'No holdings yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              'Your purchased stocks will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: const Color(0xFF7D8794), fontSize: 13.sp),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 48.sp,
              color: const Color(0xFFF87171),
            ),
            SizedBox(height: 12.h),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: const Color(0xFF7D8794), fontSize: 13.sp),
            ),
          ],
        ),
      ),
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
