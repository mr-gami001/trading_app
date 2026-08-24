abstract class AppException implements Exception {
  final String message;
  final dynamic details;

  const AppException(this.message, [this.details]);

  @override
  String toString() => 'AppException: $message ${details != null ? "($details)" : ""}';
}

class StorageException extends AppException {
  const StorageException([super.message = 'Storage operation failed', super.details]);
}

class MarketFeedException extends AppException {
  const MarketFeedException([super.message = 'Market data feed error', super.details]);
}

class ValidationException extends AppException {
  const ValidationException(super.message, [super.details]);
}

class OrderExecutionException extends AppException {
  const OrderExecutionException(super.message, [super.details]);
}
