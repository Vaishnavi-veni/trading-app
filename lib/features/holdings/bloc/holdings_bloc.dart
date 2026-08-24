import 'package:flutter_bloc/flutter_bloc.dart';

import '../../trading/data/models/holding.dart';
import '../../trading/data/repositories/trading_repository.dart';
import 'holdings_event.dart';
import 'holdings_state.dart';

class HoldingsBloc extends Bloc<HoldingsEvent, HoldingsState> {
  final TradingRepository repository;

  HoldingsBloc({required this.repository}) : super(const HoldingsState()) {
    on<LoadHoldings>(_onLoadHoldings);
    on<ChangeHoldingsSort>(_onChangeHoldingsSort);
  }

  void _onLoadHoldings(LoadHoldings event, Emitter<HoldingsState> emit) {
    try {
      final holdings = repository.holdings;

      emit(
        state.copyWith(
          status: HoldingsStatus.loaded,
          holdings: _sortHoldings(holdings, state.sort),
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: HoldingsStatus.failure,
          errorMessage: error.toString(),
        ),
      );
    }
  }

  void _onChangeHoldingsSort(
    ChangeHoldingsSort event,
    Emitter<HoldingsState> emit,
  ) {
    emit(
      state.copyWith(
        sort: event.sort,
        holdings: _sortHoldings(state.holdings, event.sort),
      ),
    );
  }

  List<Holding> _sortHoldings(List<Holding> holdings, HoldingsSort sort) {
    final result = List<Holding>.of(holdings);

    switch (sort) {
      case HoldingsSort.symbol:
        result.sort((a, b) => a.symbol.compareTo(b.symbol));
        break;

      case HoldingsSort.currentValue:
        result.sort((a, b) => a.symbol.compareTo(b.symbol));
        break;

      case HoldingsSort.pnl:
        result.sort((a, b) => a.symbol.compareTo(b.symbol));
        break;
    }

    return result;
  }
}
