import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trading_app/features/trading/data/models/order_side.dart';

class OrderSideSelector extends StatelessWidget {
  final OrderSide side;
  final ValueChanged<OrderSide> onChanged;

  const OrderSideSelector({required this.side, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: const Color(0xFF151B23),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFF202832)),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SideButton(
              label: 'BUY',
              icon: Icons.trending_up_rounded,
              selected: side == OrderSide.buy,
              color: const Color(0xFF4ADE80),
              onTap: () => onChanged(OrderSide.buy),
            ),
          ),

          SizedBox(width: 4.w),

          Expanded(
            child: _SideButton(
              label: 'SELL',
              icon: Icons.trending_down_rounded,
              selected: side == OrderSide.sell,
              color: const Color(0xFFF87171),
              onTap: () => onChanged(OrderSide.sell),
            ),
          ),
        ],
      ),
    );
  }
}

class _SideButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const _SideButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: 46.h,
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.transparent,
          borderRadius: BorderRadius.circular(10.r),
          border: selected
              ? Border.all(color: color.withValues(alpha: 0.35))
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17.sp,
              color: selected ? color : const Color(0xFF7D8794),
            ),

            SizedBox(width: 7.w),

            Text(
              label,
              style: TextStyle(
                color: selected ? color : const Color(0xFF7D8794),
                fontSize: 12.sp,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
