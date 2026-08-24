import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../data/datasources/stock_data.dart';
import '../widgets/stock_price_tile.dart';

class MarketScreen extends StatefulWidget {
  const MarketScreen({super.key});

  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stocks = StockData.stocks.where((stock) {
      if (_searchQuery.isEmpty) {
        return true;
      }

      return stock.symbol.toLowerCase().contains(_searchQuery) ||
          stock.name.toLowerCase().contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF0B0F14),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B0F14),
        elevation: 0,
        title: Text(
          'Market',
          style: TextStyle(
            color: Colors.white,
            fontSize: 24.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.notifications_none_rounded,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
          children: [
            // Search
            Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: const Color(0xFF151B23),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF242C37)),
              ),
              child: TextField(
                controller: _searchController,
                style: TextStyle(color: Colors.white, fontSize: 14.sp),
                cursorColor: const Color(0xFF4ADE80),
                decoration: InputDecoration(
                  hintText: 'Search stocks',
                  hintStyle: const TextStyle(color: Color(0xFF7D8794)),
                  prefixIcon: const Icon(
                    Icons.search_rounded,
                    color: Color(0xFF7D8794),
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: _searchController.clear,
                          icon: const Icon(
                            Icons.close_rounded,
                            color: Color(0xFF7D8794),
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 14.h,
                  ),
                ),
              ),
            ),

            SizedBox(height: 24.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Stocks',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${stocks.length} stocks',
                  style: TextStyle(color: Color(0xFF7D8794), fontSize: 13.sp),
                ),
              ],
            ),

            SizedBox(height: 12.h),

            if (stocks.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 48.h),
                child: Column(
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 44,
                      color: Color(0xFF5E6875),
                    ),
                    SizedBox(height: 12.h),
                    Text(
                      'No stocks found',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Try searching with another name or symbol',
                      style: TextStyle(
                        color: Color(0xFF7D8794),
                        fontSize: 13.sp,
                      ),
                    ),
                  ],
                ),
              )
            else
              ...stocks.map(
                (stock) => Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: StockPriceTile(
                    key: ValueKey(stock.symbol),
                    stock: stock,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _MarketSummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String change;
  final bool isPositive;

  const _MarketSummaryCard({
    required this.title,
    required this.value,
    required this.change,
    required this.isPositive,
  });

  @override
  Widget build(BuildContext context) {
    final changeColor = isPositive
        ? const Color(0xFF4ADE80)
        : const Color(0xFFF87171);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151B23),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF202832)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Color(0xFF8B95A3),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.4,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                isPositive
                    ? Icons.trending_up_rounded
                    : Icons.trending_down_rounded,
                size: 16,
                color: changeColor,
              ),
              const SizedBox(width: 4),
              Text(
                change,
                style: TextStyle(
                  color: changeColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
