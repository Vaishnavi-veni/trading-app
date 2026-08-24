import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trading_app/features/market/bloc/market_state.dart';

class PriceCard extends StatelessWidget {
  final int ltpPaise;
  final MarketPrice? marketPrice;

  const PriceCard({required this.ltpPaise, required this.marketPrice});

  @override
  Widget build(BuildContext context) {
    final tickIsUp = marketPrice?.tickIsUp ?? false;

    final tickIsDown = marketPrice?.tickIsDown ?? false;

    final tickColor = tickIsUp
        ? const Color(0xFF4ADE80)
        : tickIsDown
        ? const Color(0xFFF87171)
        : const Color(0xFF7D8794);

    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: const Color(0xFF151B23),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFF202832)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'LTP',
                      style: TextStyle(
                        color: const Color(0xFF7D8794),
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    if (marketPrice != null) ...[
                      SizedBox(width: 6.w),
                      Container(
                        width: 6.w,
                        height: 6.w,
                        decoration: BoxDecoration(
                          color: tickColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ],
                ),

                SizedBox(height: 6.h),

                Text(
                  '₹${(ltpPaise / 100).toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25.sp,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
            decoration: BoxDecoration(
              color: tickColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Text(
              marketPrice == null
                  ? 'Market'
                  : tickIsUp
                  ? '↑ LIVE'
                  : tickIsDown
                  ? '↓ LIVE'
                  : 'LIVE',
              style: TextStyle(
                color: tickColor,
                fontSize: 10.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
