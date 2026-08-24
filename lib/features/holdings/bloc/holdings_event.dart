import 'package:equatable/equatable.dart';

import 'holdings_state.dart';

abstract class HoldingsEvent extends Equatable {
  const HoldingsEvent();

  @override
  List<Object?> get props => [];
}

class LoadHoldings extends HoldingsEvent {
  const LoadHoldings();
}

class ChangeHoldingsSort extends HoldingsEvent {
  final HoldingsSort sort;

  const ChangeHoldingsSort(this.sort);

  @override
  List<Object?> get props => [sort];
}
