import 'package:equatable/equatable.dart';

abstract class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object?> get props => [];
}

class LoadWatchlistsEvent extends WatchlistEvent {}

class SelectWatchlistEvent extends WatchlistEvent {
  final int index;

  const SelectWatchlistEvent(this.index);

  @override
  List<Object?> get props => [index];
}

class CreateWatchlistEvent extends WatchlistEvent {
  final String name;

  const CreateWatchlistEvent(this.name);

  @override
  List<Object?> get props => [name];
}

class RenameWatchlistEvent extends WatchlistEvent {
  final String watchlistId;
  final String newName;

  const RenameWatchlistEvent(this.watchlistId, this.newName);

  @override
  List<Object?> get props => [watchlistId, newName];
}

class DeleteWatchlistEvent extends WatchlistEvent {
  final String watchlistId;

  const DeleteWatchlistEvent(this.watchlistId);

  @override
  List<Object?> get props => [watchlistId];
}

class AddStockToWatchlistEvent extends WatchlistEvent {
  final String watchlistId;
  final String symbol;

  const AddStockToWatchlistEvent(this.watchlistId, this.symbol);

  @override
  List<Object?> get props => [watchlistId, symbol];
}

class RemoveStockFromWatchlistEvent extends WatchlistEvent {
  final String watchlistId;
  final String symbol;

  const RemoveStockFromWatchlistEvent(this.watchlistId, this.symbol);

  @override
  List<Object?> get props => [watchlistId, symbol];
}

class ReorderWatchlistEvent extends WatchlistEvent {
  final String watchlistId;
  final int oldIndex;
  final int newIndex;

  const ReorderWatchlistEvent(this.watchlistId, this.oldIndex, this.newIndex);

  @override
  List<Object?> get props => [watchlistId, oldIndex, newIndex];
}
