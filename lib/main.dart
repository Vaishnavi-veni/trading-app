import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_app/features/market/bloc/market_bloc.dart';
import 'package:trading_app/features/market/bloc/market_event.dart';
import 'package:trading_app/features/market/data/datasources/mock_market_feed.dart';

import 'features/market/screens/market_screen.dart';

void main() {
  runApp(const TradingApp());
}

class TradingApp extends StatelessWidget {
  const TradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          MarketBloc(marketFeed: MockMarketFeed())
            ..add(const StartMarketFeed()),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Trading App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const MarketScreen(),
      ),
    );
  }
}
