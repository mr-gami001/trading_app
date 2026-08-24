import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class StorageFailure extends Failure {
  const StorageFailure([super.message = 'Unable to read or write local data']);
}

class MarketFeedFailure extends Failure {
  const MarketFeedFailure([super.message = 'Failed to connect to market feed']);
}

class ValidationFailure extends Failure {
  const ValidationFailure(super.message);
}

class InsufficientBalanceFailure extends Failure {
  const InsufficientBalanceFailure(super.message);
}

class InsufficientQuantityFailure extends Failure {
  const InsufficientQuantityFailure(super.message);
}
