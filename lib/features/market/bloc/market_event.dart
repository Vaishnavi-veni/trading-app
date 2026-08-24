import 'package:equatable/equatable.dart';

abstract class MarketEvent extends Equatable {
  const MarketEvent();

  @override
  List<Object?> get props => [];
}

class StartMarketFeed extends MarketEvent {
  const StartMarketFeed();
}

class StopMarketFeed extends MarketEvent {
  const StopMarketFeed();
}

class MarketPriceUpdated extends MarketEvent {
  final String symbol;
  final int pricePaise;
  final int previousPricePaise;

  const MarketPriceUpdated({
    required this.symbol,
    required this.pricePaise,
    required this.previousPricePaise,
  });

  @override
  List<Object?> get props => [symbol, pricePaise, previousPricePaise];
}
