import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:trading_app/features/market/bloc/market_bloc.dart';
import 'package:trading_app/features/market/bloc/market_event.dart';
import 'package:trading_app/features/market/data/datasources/market_config_feed.dart';
import 'package:trading_app/features/market/data/datasources/mock_market_feed.dart';

import 'package:trading_app/features/trading/bloc/order_bloc.dart';
import 'package:trading_app/features/trading/data/repositories/trading_repository.dart';

import 'package:trading_app/features/watchlist/bloc/watchlist_bloc.dart';
import 'package:trading_app/features/watchlist/bloc/watchlist_event.dart';
import 'package:trading_app/features/watchlist/data/datasources/watchlist_local_datasource.dart';

import 'package:trading_app/home_screen.dart';

void main() {
  final marketBloc = MarketBloc(
    marketFeed: MockMarketFeed(
      tickInterval: MarketFeedConfig.normalTickInterval,
    ),
  )..add(const StartMarketFeed());

  final tradingRepository = TradingRepository();

  runApp(
    TradingApp(marketBloc: marketBloc, tradingRepository: tradingRepository),
  );
}

class TradingApp extends StatelessWidget {
  final MarketBloc marketBloc;
  final TradingRepository tradingRepository;

  const TradingApp({
    super.key,
    required this.marketBloc,
    required this.tradingRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: marketBloc),

        BlocProvider(
          create: (_) =>
              WatchlistBloc(dataSource: WatchlistLocalDataSource())
                ..add(const LoadWatchlists()),
        ),

        BlocProvider(
          create: (_) =>
              OrderBloc(repository: tradingRepository, marketBloc: marketBloc),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Trading App',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
