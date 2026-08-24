class MarketFeedConfig {
  const MarketFeedConfig._();

  /// Normal UI testing.
  static const normalTickInterval = Duration(milliseconds: 500);

  /// Faster realtime testing.
  static const fastTickInterval = Duration(milliseconds: 100);

  /// Stress testing.
  ///
  /// 20ms = approximately 50 ticks/sec overall.
  static const stressTickInterval = Duration(milliseconds: 20);
}
