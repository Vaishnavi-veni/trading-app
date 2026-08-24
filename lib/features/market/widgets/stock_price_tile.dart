import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trading_app/features/market/data/models/stock_model.dart';

import '../bloc/market_bloc.dart';
import '../bloc/market_state.dart';

class StockPriceTile extends StatelessWidget {
  final StockModel stock;
  final VoidCallback? onTap;

  const StockPriceTile({super.key, required this.stock, this.onTap});

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

        final tickColor = marketPrice == null
            ? Colors.transparent
            : marketPrice.tickIsUp
            ? const Color(0xFF4ADE80)
            : marketPrice.tickIsDown
            ? const Color(0xFFF87171)
            : Colors.transparent;

        final changeColor = isUp
            ? const Color(0xFF4ADE80)
            : isDown
            ? const Color(0xFFF87171)
            : const Color(0xFF8B95A3);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            color: const Color(0xFF151B23),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: tickColor.withValues(alpha: 0.18)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.12),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(16.r),
              child: Row(
                children: [
                  // Stock avatar
                  Container(
                    width: 44.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF202832),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      stock.symbol.substring(
                        0,
                        stock.symbol.length > 2 ? 2 : stock.symbol.length,
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // Stock information
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          stock.symbol,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          stock.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Color(0xFF7D8794),
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(width: 12.w),

                  // Price + change
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '₹${(pricePaise / 100).toStringAsFixed(2)}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),

                      SizedBox(height: 6.h),

                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 7.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: changeColor.withValues(alpha: 0.10),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isUp
                                  ? Icons.arrow_upward_rounded
                                  : isDown
                                  ? Icons.arrow_downward_rounded
                                  : Icons.remove_rounded,
                              size: 11,
                              color: changeColor,
                            ),
                            SizedBox(width: 2.w),
                            Text(
                              '${changePercent >= 0 ? '+' : ''}'
                              '${changePercent.toStringAsFixed(2)}%',
                              style: TextStyle(
                                color: changeColor,
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
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
