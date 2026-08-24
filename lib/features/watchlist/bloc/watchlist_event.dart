import 'package:equatable/equatable.dart';

abstract class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object?> get props => [];
}

class LoadWatchlists extends WatchlistEvent {
  const LoadWatchlists();
}

class CreateWatchlist extends WatchlistEvent {
  final String name;

  const CreateWatchlist(this.name);

  @override
  List<Object?> get props => [name];
}

class RenameWatchlist extends WatchlistEvent {
  final String id;
  final String name;

  const RenameWatchlist({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class DeleteWatchlist extends WatchlistEvent {
  final String id;

  const DeleteWatchlist(this.id);

  @override
  List<Object?> get props => [id];
}

class AddStockToWatchlist extends WatchlistEvent {
  final String watchlistId;
  final String symbol;

  const AddStockToWatchlist({required this.watchlistId, required this.symbol});

  @override
  List<Object?> get props => [watchlistId, symbol];
}

class RemoveStockFromWatchlist extends WatchlistEvent {
  final String watchlistId;
  final String symbol;

  const RemoveStockFromWatchlist({
    required this.watchlistId,
    required this.symbol,
  });

  @override
  List<Object?> get props => [watchlistId, symbol];
}

class ReorderWatchlistStocks extends WatchlistEvent {
  final String watchlistId;
  final int oldIndex;
  final int newIndex;

  const ReorderWatchlistStocks({
    required this.watchlistId,
    required this.oldIndex,
    required this.newIndex,
  });

  @override
  List<Object?> get props => [watchlistId, oldIndex, newIndex];
}
