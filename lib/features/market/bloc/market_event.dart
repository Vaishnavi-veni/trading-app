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
  final int referencePricePaise;

  const MarketPriceUpdated({
    required this.symbol,
    required this.pricePaise,
    required this.previousPricePaise,
    required this.referencePricePaise,
  });

  @override
  List<Object?> get props => [
    symbol,
    pricePaise,
    previousPricePaise,
    referencePricePaise,
  ];
}
