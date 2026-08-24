class Holding {
  final String symbol;
  final int quantity;
  final int averagePricePaise;

  const Holding({
    required this.symbol,
    required this.quantity,
    required this.averagePricePaise,
  });

  Holding copyWith({int? quantity, int? averagePricePaise}) {
    return Holding(
      symbol: symbol,
      quantity: quantity ?? this.quantity,
      averagePricePaise: averagePricePaise ?? this.averagePricePaise,
    );
  }

  int get investedValuePaise {
    return quantity * averagePricePaise;
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
      quantity: json['quantity'] as int,
      averagePricePaise: json['averagePricePaise'] as int,
    );
  }
}
