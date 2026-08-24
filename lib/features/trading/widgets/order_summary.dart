import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OrderSummary extends StatelessWidget {
  final int balancePaise;
  final int quantity;
  final int ltpPaise;
  final int orderValuePaise;

  const OrderSummary({
    required this.balancePaise,
    required this.quantity,
    required this.ltpPaise,
    required this.orderValuePaise,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: const Color(0xFF151B23),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: const Color(0xFF202832)),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: 'Available Balance',
            value: '₹${(balancePaise / 100).toStringAsFixed(2)}',
            bold: true,
          ),

          SizedBox(height: 15.h),

          _SummaryRow(label: 'Quantity', value: quantity.toString()),

          SizedBox(height: 12.h),

          _SummaryRow(
            label: 'Price',
            value: '₹${(ltpPaise / 100).toStringAsFixed(2)}',
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: const Divider(height: 1, color: Color(0xFF202832)),
          ),

          _SummaryRow(
            label: 'Order Value',
            value: '₹${(orderValuePaise / 100).toStringAsFixed(2)}',
            bold: true,
            valueSize: 15,
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final double valueSize;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueSize = 13,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(color: const Color(0xFF7D8794), fontSize: 12.sp),
        ),

        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: valueSize.sp,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
