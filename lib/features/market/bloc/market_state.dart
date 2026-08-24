import 'package:equatable/equatable.dart';

class MarketPrice {
  final String symbol;
  final int pricePaise;
  final int previousPricePaise;
  final int referencePricePaise;

  const MarketPrice({
    required this.symbol,
    required this.pricePaise,
    required this.previousPricePaise,
    required this.referencePricePaise,
  });

  int get changePaise {
    return pricePaise - referencePricePaise;
  }

  double get changePercent {
    if (referencePricePaise == 0) {
      return 0;
    }

    return (changePaise / referencePricePaise) * 100;
  }

  bool get tickIsUp {
    return pricePaise > previousPricePaise;
  }

  bool get tickIsDown {
    return pricePaise < previousPricePaise;
  }

  bool get tickIsUnchanged {
    return pricePaise == previousPricePaise;
  }

  bool get isPositive {
    return changePaise > 0;
  }

  bool get isNegative {
    return changePaise < 0;
  }
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
