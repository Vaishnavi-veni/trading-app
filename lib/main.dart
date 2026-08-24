import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trading_app/features/holdings/bloc/holdings_bloc.dart';
import 'package:trading_app/features/holdings/bloc/holdings_event.dart';
import 'package:trading_app/features/trading/data/datasources/trading_local_datasource.dart';

import 'features/market/bloc/market_bloc.dart';
import 'features/market/bloc/market_event.dart';
import 'features/market/data/datasources/market_config_feed.dart';
import 'features/market/data/datasources/mock_market_feed.dart';

import 'features/trading/bloc/order_bloc.dart';
import 'features/trading/data/repositories/trading_repository.dart';

import 'features/watchlist/bloc/watchlist_bloc.dart';
import 'features/watchlist/bloc/watchlist_event.dart';
import 'features/watchlist/data/datasources/watchlist_local_datasource.dart';

import 'home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tradingRepository = TradingRepository(
    localDataSource: TradingLocalDataSource(),
  );

  await tradingRepository.load();

  runApp(
    ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return TradingApp(tradingRepository: tradingRepository);
      },
    ),
  );
}

class TradingApp extends StatelessWidget {
  final TradingRepository tradingRepository;

  const TradingApp({super.key, required this.tradingRepository});

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

        BlocProvider(
          create: (context) => OrderBloc(
            repository: tradingRepository,
            marketBloc: context.read<MarketBloc>(),
          ),
        ),

        BlocProvider(
          create: (context) =>
              HoldingsBloc(repository: tradingRepository)
                ..add(const LoadHoldings()),
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
