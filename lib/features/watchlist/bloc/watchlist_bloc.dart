import 'package:flutter_bloc/flutter_bloc.dart';

import '../data/datasources/watchlist_local_datasource.dart';
import '../data/models/watchlist.dart';
import 'watchlist_event.dart';
import 'watchlist_state.dart';

class WatchlistBloc extends Bloc<WatchlistEvent, WatchlistState> {
  WatchlistBloc({required WatchlistLocalDataSource dataSource})
    : _dataSource = dataSource,
      super(const WatchlistState()) {
    on<LoadWatchlists>(_onLoadWatchlists);
    on<CreateWatchlist>(_onCreateWatchlist);
    on<RenameWatchlist>(_onRenameWatchlist);
    on<DeleteWatchlist>(_onDeleteWatchlist);
    on<AddStockToWatchlist>(_onAddStockToWatchlist);
    on<RemoveStockFromWatchlist>(_onRemoveStockFromWatchlist);
    on<ReorderWatchlistStocks>(_onReorderWatchlistStocks);
  }

  final WatchlistLocalDataSource _dataSource;

  Future<void> _onLoadWatchlists(
    LoadWatchlists event,
    Emitter<WatchlistState> emit,
  ) async {
    emit(state.copyWith(status: WatchlistStatus.loading));

    try {
      final watchlists = await _dataSource.loadWatchlists();

      emit(
        state.copyWith(status: WatchlistStatus.loaded, watchlists: watchlists),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WatchlistStatus.failure,
          errorMessage: 'Failed to load watchlists.',
        ),
      );
    }
  }

  Future<void> _onCreateWatchlist(
    CreateWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    final name = event.name.trim();

    if (name.isEmpty) {
      return;
    }

    final watchlist = Watchlist(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name,
      stockSymbols: const [],
    );

    final updatedWatchlists = [...state.watchlists, watchlist];

    await _save(updatedWatchlists, emit);
  }

  Future<void> _onRenameWatchlist(
    RenameWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    final updatedWatchlists = state.watchlists.map((watchlist) {
      if (watchlist.id != event.id) {
        return watchlist;
      }

      return watchlist.copyWith(name: event.name.trim());
    }).toList();

    await _save(updatedWatchlists, emit);
  }

  Future<void> _onDeleteWatchlist(
    DeleteWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    final updatedWatchlists = state.watchlists
        .where((watchlist) => watchlist.id != event.id)
        .toList();

    await _save(updatedWatchlists, emit);
  }

  Future<void> _onAddStockToWatchlist(
    AddStockToWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    final updatedWatchlists = state.watchlists.map((watchlist) {
      if (watchlist.id != event.watchlistId) {
        return watchlist;
      }

      if (watchlist.stockSymbols.contains(event.symbol)) {
        return watchlist;
      }

      return watchlist.copyWith(
        stockSymbols: [...watchlist.stockSymbols, event.symbol],
      );
    }).toList();

    await _save(updatedWatchlists, emit);
  }

  Future<void> _onRemoveStockFromWatchlist(
    RemoveStockFromWatchlist event,
    Emitter<WatchlistState> emit,
  ) async {
    final updatedWatchlists = state.watchlists.map((watchlist) {
      if (watchlist.id != event.watchlistId) {
        return watchlist;
      }

      return watchlist.copyWith(
        stockSymbols: watchlist.stockSymbols
            .where((symbol) => symbol != event.symbol)
            .toList(),
      );
    }).toList();

    await _save(updatedWatchlists, emit);
  }

  Future<void> _onReorderWatchlistStocks(
    ReorderWatchlistStocks event,
    Emitter<WatchlistState> emit,
  ) async {
    final updatedWatchlists = state.watchlists.map((watchlist) {
      if (watchlist.id != event.watchlistId) {
        return watchlist;
      }

      final symbols = List<String>.from(watchlist.stockSymbols);

      var newIndex = event.newIndex;

      if (newIndex > event.oldIndex) {
        newIndex -= 1;
      }

      final item = symbols.removeAt(event.oldIndex);

      symbols.insert(newIndex, item);

      return watchlist.copyWith(stockSymbols: symbols);
    }).toList();

    await _save(updatedWatchlists, emit);
  }

  Future<void> _save(
    List<Watchlist> watchlists,
    Emitter<WatchlistState> emit,
  ) async {
    try {
      await _dataSource.saveWatchlists(watchlists);

      emit(
        state.copyWith(status: WatchlistStatus.loaded, watchlists: watchlists),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: WatchlistStatus.failure,
          errorMessage: 'Failed to save watchlists.',
        ),
      );
    }
  }
}
