class Failure {
  final String message;
  final dynamic error;

  const Failure(this.message, [this.error]);

  @override
  String toString() => 'Failure: $message ${error != null ? '($error)' : ''}';
}

class DatabaseFailure extends Failure {
  const DatabaseFailure(super.message, [super.error]);
}

class ImageProcessingFailure extends Failure {
  const ImageProcessingFailure(super.message, [super.error]);
}

class StorageFailure extends Failure {
  const StorageFailure(super.message, [super.error]);
}
