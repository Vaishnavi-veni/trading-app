import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../bloc/order_bloc.dart';
import '../bloc/order_state.dart';
import '../data/models/order.dart';
import '../data/models/order_side.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  static const backgroundColor = Color(0xFF0B0F14);
  static const cardColor = Color(0xFF151B23);
  static const borderColor = Color(0xFF202832);
  static const secondaryTextColor = Color(0xFF7D8794);
  static const accentColor = Color(0xFF4ADE80);
  static const sellColor = Color(0xFFF87171);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Order History',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),

      body: BlocSelector<OrderBloc, OrderState, List<Order>>(
        selector: (state) => state.orders,
        builder: (context, orders) {
          if (orders.isEmpty) {
            return const _EmptyOrders();
          }

          final sortedOrders = List<Order>.from(orders)
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 32.h),
            itemCount: sortedOrders.length,
            separatorBuilder: (_, __) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              return _OrderCard(order: sortedOrders[index]);
            },
          );
        },
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;

  const _OrderCard({required this.order});

  static const cardColor = Color(0xFF151B23);
  static const borderColor = Color(0xFF202832);
  static const secondaryTextColor = Color(0xFF7D8794);
  static const accentColor = Color(0xFF4ADE80);
  static const sellColor = Color(0xFFF87171);

  @override
  Widget build(BuildContext context) {
    final isBuy = order.side == OrderSide.buy;
    final actionColor = isBuy ? accentColor : sellColor;

    final orderValuePaise = order.quantity * order.pricePaise;

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Stock icon
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: actionColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13.r),
                ),
                alignment: Alignment.center,
                child: Icon(
                  isBuy
                      ? Icons.trending_up_rounded
                      : Icons.trending_down_rounded,
                  color: actionColor,
                  size: 22.sp,
                ),
              ),

              SizedBox(width: 12.w),

              // Symbol + order type
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      order.symbol,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    SizedBox(height: 5.h),

                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 7.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: actionColor.withValues(alpha: 0.10),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(
                            isBuy ? 'BUY' : 'SELL',
                            style: TextStyle(
                              color: actionColor,
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),

                        SizedBox(width: 8.w),

                        Text(
                          _formatDate(order.createdAt),
                          style: TextStyle(
                            color: secondaryTextColor,
                            fontSize: 10.sp,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              SizedBox(width: 8.w),

              // Order value
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${(orderValuePaise / 100).toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Order value',
                    style: TextStyle(color: secondaryTextColor, fontSize: 9.sp),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 16.h),

          Divider(height: 1.h, color: borderColor),

          SizedBox(height: 14.h),

          Row(
            children: [
              Expanded(
                child: _Detail(
                  label: 'Quantity',
                  value: order.quantity.toString(),
                ),
              ),

              Expanded(
                child: _Detail(
                  label: 'Price',
                  value: '₹${(order.pricePaise / 100).toStringAsFixed(2)}',
                ),
              ),

              Expanded(
                child: _Detail(
                  label: 'Time',
                  value: _formatTime(order.createdAt),
                  alignEnd: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');

    return '$hour:$minute';
  }

  String _formatDate(DateTime dateTime) {
    final day = dateTime.day.toString().padLeft(2, '0');
    final month = dateTime.month.toString().padLeft(2, '0');
    final year = dateTime.year.toString();

    return '$day/$month/$year';
  }
}

class _Detail extends StatelessWidget {
  final String label;
  final String value;
  final bool alignEnd;

  const _Detail({
    required this.label,
    required this.value,
    this.alignEnd = false,
  });

  static const secondaryTextColor = Color(0xFF7D8794);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: alignEnd
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: secondaryTextColor, fontSize: 10.sp),
        ),

        SizedBox(height: 4.h),

        Text(
          value,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EmptyOrders extends StatelessWidget {
  const _EmptyOrders();

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
                Icons.receipt_long_outlined,
                size: 36.sp,
                color: const Color(0xFF596573),
              ),
            ),

            SizedBox(height: 20.h),

            Text(
              'No orders yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),

            SizedBox(height: 8.h),

            Text(
              'Your completed orders will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: const Color(0xFF7D8794), fontSize: 13.sp),
            ),
          ],
        ),
      ),
    );
  }
}
