import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trading_app/features/watchlist/data/models/watchlist.dart';

class WatchlistHeader extends StatelessWidget {
  final List<Watchlist> watchlists;
  final Watchlist selectedWatchlist;
  final ValueChanged<Watchlist> onChanged;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const WatchlistHeader({
    required this.watchlists,
    required this.selectedWatchlist,
    required this.onChanged,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 16.h),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 52.h,
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: const Color(0xFF151B23),
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: const Color(0xFF202832)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<Watchlist>(
                  value: selectedWatchlist,
                  isExpanded: true,
                  dropdownColor: const Color(0xFF1B222C),
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Color(0xFF7D8794),
                  ),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  items: watchlists.map((watchlist) {
                    return DropdownMenuItem(
                      value: watchlist,
                      child: Text(
                        watchlist.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (watchlist) {
                    if (watchlist != null) {
                      onChanged(watchlist);
                    }
                  },
                ),
              ),
            ),
          ),

          SizedBox(width: 8.w),

          Container(
            height: 52,
            width: 52,
            decoration: BoxDecoration(
              color: const Color(0xFF151B23),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF202832)),
            ),
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz_rounded, color: Colors.white),
              color: const Color(0xFF1B222C),
              onSelected: (value) {
                if (value == 'rename') {
                  onRename();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'rename',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined, size: 18, color: Colors.white),
                      SizedBox(width: 10),
                      Text('Rename'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline_rounded,
                        size: 18,
                        color: Color(0xFFF87171),
                      ),
                      SizedBox(width: 10),
                      Text('Delete'),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
