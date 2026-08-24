import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:trading_app/features/market/data/datasources/stock_data.dart';
import 'package:trading_app/features/market/widgets/stock_price_tile.dart';
import 'package:trading_app/features/trading/screens/order_ticket_screen.dart';
import 'package:trading_app/features/watchlist/bloc/watchlist_bloc.dart';
import 'package:trading_app/features/watchlist/bloc/watchlist_event.dart';
import 'package:trading_app/features/watchlist/data/models/watchlist.dart';

class WatchlistStocks extends StatelessWidget {
  final Watchlist watchlist;

  const WatchlistStocks({required this.watchlist});

  @override
  Widget build(BuildContext context) {
    if (watchlist.stockSymbols.isEmpty) {
      return const _EmptyStocksState();
    }

    return ReorderableListView.builder(
      padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 100.h),
      buildDefaultDragHandles: false,
      itemCount: watchlist.stockSymbols.length,
      onReorder: (oldIndex, newIndex) {
        context.read<WatchlistBloc>().add(
          ReorderWatchlistStocks(
            watchlistId: watchlist.id,
            oldIndex: oldIndex,
            newIndex: newIndex,
          ),
        );
      },
      itemBuilder: (context, index) {
        final symbol = watchlist.stockSymbols[index];

        final stock = StockData.stocks.firstWhere(
          (stock) => stock.symbol == symbol,
        );

        return Padding(
          key: ValueKey('${watchlist.id}-$symbol'),
          padding: const EdgeInsets.only(bottom: 10),
          child: Dismissible(
            key: ValueKey('${watchlist.id}-$symbol-dismiss'),
            direction: DismissDirection.endToStart,

            background: Container(
              alignment: Alignment.centerRight,
              padding: EdgeInsets.only(right: 24.w),
              decoration: BoxDecoration(
                color: const Color(0xFFF87171),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: const Icon(
                Icons.delete_outline_rounded,
                color: Colors.white,
              ),
            ),

            confirmDismiss: (_) async {
              context.read<WatchlistBloc>().add(
                RemoveStockFromWatchlist(
                  watchlistId: watchlist.id,
                  symbol: symbol,
                ),
              );

              return false;
            },

            child: Stack(
              children: [
                StockPriceTile(
                  stock: stock,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => OrderTicketScreen(symbol: stock.symbol),
                      ),
                    );
                  },
                ),

                Positioned(
                  left: 4.w,
                  top: 0,
                  bottom: 0,
                  child: ReorderableDragStartListener(
                    index: index,
                    child: Center(
                      child: Icon(
                        Icons.drag_indicator_rounded,
                        size: 18.sp,
                        color: Color(0xFF596573),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyStocksState extends StatelessWidget {
  const _EmptyStocksState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72.w,
              height: 72.h,
              decoration: BoxDecoration(
                color: const Color(0xFF151B23),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(
                Icons.visibility_outlined,
                size: 32.sp,
                color: Color(0xFF596573),
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              'Your watchlist is empty',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Add stocks to start tracking their prices.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF7D8794), fontSize: 13.sp),
            ),
          ],
        ),
      ),
    );
  }
}
