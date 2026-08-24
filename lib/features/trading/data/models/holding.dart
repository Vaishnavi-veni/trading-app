class Holding {
  final String symbol;
  final int quantity;
  final int averagePricePaise;

  const Holding({
    required this.symbol,
    required this.quantity,
    required this.averagePricePaise,
  });

  Holding copyWith({String? symbol, int? quantity, int? averagePricePaise}) {
    return Holding(
      symbol: symbol ?? this.symbol,
      quantity: quantity ?? this.quantity,
      averagePricePaise: averagePricePaise ?? this.averagePricePaise,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'quantity': quantity,
      'averagePricePaise': averagePricePaise,
    };
  }

  factory Holding.fromJson(Map<String, dynamic> json) {
    return Holding(
      symbol: json['symbol'] as String,
      quantity: (json['quantity'] as num).toInt(),
      averagePricePaise: (json['averagePricePaise'] as num).toInt(),
    );
  }
}
