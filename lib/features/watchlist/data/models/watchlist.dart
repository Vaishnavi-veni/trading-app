class Watchlist {
  final String id;
  final String name;
  final List<String> stockSymbols;

  const Watchlist({
    required this.id,
    required this.name,
    required this.stockSymbols,
  });

  Watchlist copyWith({String? name, List<String>? stockSymbols}) {
    return Watchlist(
      id: id,
      name: name ?? this.name,
      stockSymbols: stockSymbols ?? this.stockSymbols,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'stockSymbols': stockSymbols};
  }

  factory Watchlist.fromJson(Map<String, dynamic> json) {
    return Watchlist(
      id: json['id'] as String,
      name: json['name'] as String,
      stockSymbols: List<String>.from(json['stockSymbols'] as List),
    );
  }
}
