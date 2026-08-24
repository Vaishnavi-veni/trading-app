import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:trading_app/features/market/bloc/market_bloc.dart';
import 'package:trading_app/features/market/bloc/market_event.dart';
import 'package:trading_app/features/market/data/datasources/market_config_feed.dart';
import 'package:trading_app/features/market/data/datasources/mock_market_feed.dart';
import 'package:trading_app/features/watchlist/bloc/watchlist_bloc.dart';
import 'package:trading_app/features/watchlist/bloc/watchlist_event.dart';
import 'package:trading_app/features/watchlist/data/datasources/watchlist_local_datasource.dart';
import 'package:trading_app/home_screen.dart';

import 'features/market/screens/market_screen.dart';

void main() {
  runApp(const TradingApp());
}

class TradingApp extends StatelessWidget {
  const TradingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => MarketBloc(
            marketFeed: MockMarketFeed(
              tickInterval: MarketFeedConfig.normalTickInterval,
            ),
          )..add(const StartMarketFeed()),
        ),

        BlocProvider(
          create: (_) =>
              WatchlistBloc(dataSource: WatchlistLocalDataSource())
                ..add(const LoadWatchlists()),
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
