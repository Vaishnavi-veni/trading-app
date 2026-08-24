class MarketTick {
  final String symbol;
  final int pricePaise;
  final int previousPricePaise;

  const MarketTick({
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

  bool get isUnchanged => changePaise == 0;
}
