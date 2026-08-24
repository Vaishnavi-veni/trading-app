import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:trading_app/features/market/bloc/market_bloc.dart';

import '../../market/bloc/market_state.dart';
import '../../trading/data/models/holding.dart';

class HoldingRow extends StatelessWidget {
  final Holding holding;
  final VoidCallback? onTap;

  const HoldingRow({super.key, required this.holding, this.onTap});

  static const cardColor = Color(0xFF151B23);
  static const borderColor = Color(0xFF202832);
  static const secondaryTextColor = Color(0xFF7D8794);
  static const accentColor = Color(0xFF4ADE80);
  static const lossColor = Color(0xFFF87171);

  @override
  Widget build(BuildContext context) {
    return BlocSelector<MarketBloc, MarketState, MarketPrice?>(
      selector: (state) => state.prices[holding.symbol],
      builder: (context, marketPrice) {
        final ltpPaise = marketPrice?.pricePaise ?? holding.averagePricePaise;

        final investedPaise = holding.quantity * holding.averagePricePaise;

        final currentValuePaise = holding.quantity * ltpPaise;

        final pnlPaise = currentValuePaise - investedPaise;

        final pnlPercent = investedPaise == 0
            ? 0.0
            : pnlPaise / investedPaise * 100;

        final isProfit = pnlPaise >= 0;
        final pnlColor = isProfit ? accentColor : lossColor;

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.all(14.w),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: borderColor),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Stock avatar
                  _StockAvatar(symbol: holding.symbol),

                  SizedBox(width: 12.w),

                  // Stock information
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                holding.symbol,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                            SizedBox(width: 8.w),

                            Text(
                              '₹${(ltpPaise / 100).toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 7.h),

                        Text(
                          'Qty ${holding.quantity}'
                          '  •  '
                          'Avg ₹${(holding.averagePricePaise / 100).toStringAsFixed(2)}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 11.sp,
                          ),
                        ),

                        SizedBox(height: 5.h),

                        Text(
                          'Value ₹${(currentValuePaise / 100).toStringAsFixed(2)}',
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 11.sp,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // P&L
                  Container(
                    constraints: BoxConstraints(minWidth: 72.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 7.h,
                    ),
                    decoration: BoxDecoration(
                      color: pnlColor.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(9.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isProfit
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              size: 12.sp,
                              color: pnlColor,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              '₹${(pnlPaise.abs() / 100).toStringAsFixed(2)}',
                              style: TextStyle(
                                color: pnlColor,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 2.h),

                        Text(
                          '${isProfit ? '+' : '-'}'
                          '${pnlPercent.abs().toStringAsFixed(2)}%',
                          style: TextStyle(
                            color: pnlColor,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StockAvatar extends StatelessWidget {
  final String symbol;

  const _StockAvatar({required this.symbol});

  @override
  Widget build(BuildContext context) {
    final initials = symbol.length >= 2 ? symbol.substring(0, 2) : symbol;

    return Container(
      width: 42.w,
      height: 42.w,
      decoration: BoxDecoration(
        color: const Color(0xFF1D2630),
        borderRadius: BorderRadius.circular(12.r),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: 11.sp,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}
