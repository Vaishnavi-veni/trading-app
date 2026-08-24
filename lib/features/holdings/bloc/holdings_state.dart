import 'package:equatable/equatable.dart';

import '../../trading/data/models/holding.dart';
import 'holdings_event.dart';

enum HoldingsStatus { initial, loading, loaded, failure }

class HoldingsState extends Equatable {
  final HoldingsStatus status;
  final List<Holding> holdings;
  final HoldingsSort sort;
  final String? errorMessage;

  const HoldingsState({
    this.status = HoldingsStatus.initial,
    this.holdings = const [],
    this.sort = HoldingsSort.pnl,
    this.errorMessage,
  });

  HoldingsState copyWith({
    HoldingsStatus? status,
    List<Holding>? holdings,
    HoldingsSort? sort,
    String? errorMessage,
  }) {
    return HoldingsState(
      status: status ?? this.status,
      holdings: holdings ?? this.holdings,
      sort: sort ?? this.sort,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, holdings, sort, errorMessage];
}
