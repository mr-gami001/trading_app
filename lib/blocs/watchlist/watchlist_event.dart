import 'package:equatable/equatable.dart';

abstract class WatchlistEvent extends Equatable {
  const WatchlistEvent();

  @override
  List<Object?> get props => [];
}

class InitWatchlistsEvent extends WatchlistEvent {}

class SetActiveWatchlistIndexEvent extends WatchlistEvent {
  final int index;

  const SetActiveWatchlistIndexEvent(this.index);

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
  final String id;
  final String newName;

  const RenameWatchlistEvent(this.id, this.newName);

  @override
  List<Object?> get props => [id, newName];
}

class DeleteWatchlistEvent extends WatchlistEvent {
  final String id;

  const DeleteWatchlistEvent(this.id);

  @override
  List<Object?> get props => [id];
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

class ReorderStockEvent extends WatchlistEvent {
  final String watchlistId;
  final int oldIndex;
  final int newIndex;

  const ReorderStockEvent(this.watchlistId, this.oldIndex, this.newIndex);

  @override
  List<Object?> get props => [watchlistId, oldIndex, newIndex];
}
