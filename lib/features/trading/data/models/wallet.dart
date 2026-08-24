class Wallet {
  final int balancePaise;

  const Wallet({required this.balancePaise});

  Wallet copyWith({int? balancePaise}) {
    return Wallet(balancePaise: balancePaise ?? this.balancePaise);
  }

  Map<String, dynamic> toJson() {
    return {'balancePaise': balancePaise};
  }

  factory Wallet.fromJson(Map<String, dynamic> json) {
    return Wallet(balancePaise: json['balancePaise'] as int);
  }
}
