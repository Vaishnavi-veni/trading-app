import 'package:flutter_bloc/flutter_bloc.dart';

import '../../market/bloc/market_bloc.dart';
import '../../market/bloc/market_state.dart';
import '../data/repositories/trading_repository.dart';

import 'order_event.dart';
import 'order_state.dart';

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final TradingRepository repository;
  final MarketBloc marketBloc;

  OrderBloc({required this.repository, required this.marketBloc})
    : super(const OrderState()) {
    on<SubmitOrder>(_onSubmitOrder);
  }

  void _onSubmitOrder(SubmitOrder event, Emitter<OrderState> emit) {
    emit(state.copyWith(status: OrderStatus.submitting, errorMessage: null));

    try {
      final marketPrice = marketBloc.state.prices[event.symbol];

      if (marketPrice == null) {
        emit(
          state.copyWith(
            status: OrderStatus.failure,
            errorMessage: 'Current price is unavailable.',
          ),
        );
        return;
      }

      final executionPricePaise = marketPrice.pricePaise;

      final order = repository.executeOrder(
        symbol: event.symbol,
        side: event.side,
        quantity: event.quantity,
        executionPricePaise: executionPricePaise,
      );

      emit(
        state.copyWith(
          status: OrderStatus.success,
          wallet: repository.wallet,
          holdings: repository.holdings,
          orders: repository.orders,
          lastOrder: order,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          status: OrderStatus.failure,
          errorMessage: error.toString().replaceFirst('Exception: ', ''),
        ),
      );
    }
  }
}
