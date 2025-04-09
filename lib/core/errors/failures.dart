
abstract class Failure {
  final String message;

  const Failure(this.message);
}

class ServerFailure extends Failure {
  const ServerFailure(String message) : super(message);
}


class NetworkFailure extends Failure {
  const NetworkFailure(String message) : super(message);
}

class InvalidInputFailure extends Failure {
  const InvalidInputFailure(String message) : super(message);
}