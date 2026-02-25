import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/constants/cells_config.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;
  const RegisterUseCase(this.repository);

  Future<Either<Failure, void>> call({
    required String name,
    required String email,
    required String password,
    required MinaCell cell,
  }) =>
      repository.register(
        name: name,
        email: email,
        password: password,
        cell: cell,
      );
}