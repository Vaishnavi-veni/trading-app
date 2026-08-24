import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../data/models/order.dart';
import '../data/models/order_side.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final Order order;

  const OrderConfirmationScreen({super.key, required this.order});

  static const backgroundColor = Color(0xFF0B0F14);
  static const cardColor = Color(0xFF151B23);
  static const borderColor = Color(0xFF202832);
  static const secondaryTextColor = Color(0xFF7D8794);
  static const accentColor = Color(0xFF4ADE80);
  static const sellColor = Color(0xFFF87171);

  @override
  Widget build(BuildContext context) {
    final isBuy = order.side == OrderSide.buy;
    final orderValuePaise = order.quantity * order.pricePaise;

    final actionColor = isBuy ? accentColor : sellColor;

    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          'Order Confirmation',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 20.h),
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),

                      // Success icon
                      Container(
                        width: 82.w,
                        height: 82.w,
                        decoration: BoxDecoration(
                          color: accentColor.withValues(alpha: 0.10),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: accentColor.withValues(alpha: 0.20),
                            width: 1.w,
                          ),
                        ),
                        child: Icon(
                          Icons.check_rounded,
                          size: 44.sp,
                          color: accentColor,
                        ),
                      ),

                      SizedBox(height: 22.h),

                      Text(
                        'Order Successful',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 25.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                        ),
                      ),

                      SizedBox(height: 8.h),

                      Text(
                        isBuy
                            ? 'Your buy order was executed successfully.'
                            : 'Your sell order was executed successfully.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: secondaryTextColor,
                          fontSize: 13.sp,
                          height: 1.4,
                        ),
                      ),

                      SizedBox(height: 28.h),

                      // Order summary
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(18.w),
                        decoration: BoxDecoration(
                          color: cardColor,
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 44.w,
                                  height: 44.w,
                                  decoration: BoxDecoration(
                                    color: actionColor.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(12.r),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    order.symbol.length >= 2
                                        ? order.symbol.substring(0, 2)
                                        : order.symbol,
                                    style: TextStyle(
                                      color: actionColor,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),

                                SizedBox(width: 12.w),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        order.symbol,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16.sp,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      SizedBox(height: 3.h),
                                      Text(
                                        '${isBuy ? 'Buy' : 'Sell'} order',
                                        style: TextStyle(
                                          color: secondaryTextColor,
                                          fontSize: 11.sp,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                Container(
                                  padding: EdgeInsets.symmetric(
                                    horizontal: 10.w,
                                    vertical: 6.h,
                                  ),
                                  decoration: BoxDecoration(
                                    color: actionColor.withValues(alpha: 0.10),
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Text(
                                    isBuy ? 'BUY' : 'SELL',
                                    style: TextStyle(
                                      color: actionColor,
                                      fontSize: 11.sp,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            SizedBox(height: 20.h),

                            Divider(height: 1.h, color: borderColor),

                            SizedBox(height: 8.h),

                            _InfoRow(
                              label: 'Quantity',
                              value: order.quantity.toString(),
                            ),

                            _InfoRow(
                              label: 'Execution Price',
                              value:
                                  '₹${(order.pricePaise / 100).toStringAsFixed(2)}',
                            ),

                            SizedBox(height: 6.h),

                            Divider(height: 1.h, color: borderColor),

                            SizedBox(height: 14.h),

                            _InfoRow(
                              label: 'Order Value',
                              value:
                                  '₹${(orderValuePaise / 100).toStringAsFixed(2)}',
                              bold: true,
                              valueColor: Colors.white,
                            ),

                            SizedBox(height: 12.h),

                            _InfoRow(label: 'Order ID', value: order.id),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // Status message
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(14.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10161D),
                          borderRadius: BorderRadius.circular(14.r),
                          border: Border.all(color: borderColor),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.verified_rounded,
                              color: accentColor,
                              size: 18.sp,
                            ),
                            SizedBox(width: 10.w),
                            Expanded(
                              child: Text(
                                'The order has been added to your portfolio.',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 11.sp,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              // Done button
              SizedBox(
                width: double.infinity,
                height: 52.h,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: accentColor,
                    foregroundColor: const Color(0xFF0B0F14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Done',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  const _InfoRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  static const secondaryTextColor = Color(0xFF7D8794);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: secondaryTextColor, fontSize: 12.sp),
            ),
          ),

          SizedBox(width: 16.w),

          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: TextStyle(
                color: valueColor ?? Colors.white,
                fontSize: bold ? 14.sp : 12.sp,
                fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
