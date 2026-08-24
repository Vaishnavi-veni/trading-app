import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyWatchlist extends StatelessWidget {
  final VoidCallback onCreate;

  const EmptyWatchlist({required this.onCreate});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: const Color(0xFF151B23),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(
                Icons.visibility_outlined,
                size: 36.sp,
                color: Color(0xFF596573),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'No watchlists yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Create a watchlist to start tracking your favorite stocks.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF7D8794),
                fontSize: 13.sp,
                height: 1.4.h,
              ),
            ),
            SizedBox(height: 24.h),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF4ADE80),
                foregroundColor: const Color(0xFF0B0F14),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 13.h),
              ),
              onPressed: onCreate,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Create watchlist',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
