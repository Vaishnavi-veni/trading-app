import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/datasources/mock_market_feed.dart';
import 'market_event.dart';
import 'market_state.dart';

class MarketBloc extends Bloc<MarketEvent, MarketState> {
  MarketBloc({required MockMarketFeed marketFeed})
    : _marketFeed = marketFeed,
      super(const MarketState()) {
    on<StartMarketFeed>(_onStartMarketFeed);
    on<StopMarketFeed>(_onStopMarketFeed);
    on<MarketPriceUpdated>(_onMarketPriceUpdated);
  }

  final MockMarketFeed _marketFeed;

  StreamSubscription? _priceSubscription;

  void _onStartMarketFeed(StartMarketFeed event, Emitter<MarketState> emit) {
    if (_priceSubscription != null) {
      return;
    }

    _marketFeed.start();

    _priceSubscription = _marketFeed.ticks.listen((tick) {
      add(
        MarketPriceUpdated(
          symbol: tick.symbol,
          pricePaise: tick.pricePaise,
          previousPricePaise: tick.previousPricePaise,
          referencePricePaise: _marketFeed.getReferencePrice(tick.symbol),
        ),
      );
    });

    emit(state.copyWith(isLive: true));
  }

  Future<void> _onStopMarketFeed(
    StopMarketFeed event,
    Emitter<MarketState> emit,
  ) async {
    await _priceSubscription?.cancel();
    _priceSubscription = null;

    emit(state.copyWith(isLive: false));
  }

  void _onMarketPriceUpdated(
    MarketPriceUpdated event,
    Emitter<MarketState> emit,
  ) {
    final updatedPrices = Map<String, MarketPrice>.from(state.prices);

    updatedPrices[event.symbol] = MarketPrice(
      symbol: event.symbol,
      pricePaise: event.pricePaise,
      previousPricePaise: event.previousPricePaise,
      referencePricePaise: event.referencePricePaise,
    );

    emit(state.copyWith(prices: updatedPrices));
  }

  @override
  Future<void> close() async {
    await _priceSubscription?.cancel();
    await _marketFeed.dispose();

    return super.close();
  }
}
