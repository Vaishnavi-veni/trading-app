import 'package:equatable/equatable.dart';

class MarketPrice {
  final String symbol;
  final int pricePaise;
  final int previousPricePaise;

  const MarketPrice({
    required this.symbol,
    required this.pricePaise,
    required this.previousPricePaise,
  });

  int get changePaise => pricePaise - previousPricePaise;

  double get changePercent {
    if (previousPricePaise == 0) {
      return 0;
    }

    return (changePaise / previousPricePaise) * 100;
  }

  bool get isUp => changePaise > 0;

  bool get isDown => changePaise < 0;
}

class MarketState extends Equatable {
  final Map<String, MarketPrice> prices;
  final bool isLive;

  const MarketState({this.prices = const {}, this.isLive = false});

  MarketState copyWith({Map<String, MarketPrice>? prices, bool? isLive}) {
    return MarketState(
      prices: prices ?? this.prices,
      isLive: isLive ?? this.isLive,
    );
  }

  @override
  List<Object?> get props => [prices, isLive];
}
