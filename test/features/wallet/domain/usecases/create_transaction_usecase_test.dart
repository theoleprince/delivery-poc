import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poc_uber/core/error/failure.dart';
import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/features/wallet/domain/entities/transaction_entity.dart';
import 'package:poc_uber/features/wallet/domain/repositories/wallet_repository.dart';
import 'package:poc_uber/features/wallet/domain/usecases/create_transaction_usecase.dart';

class _MockWalletRepository extends Mock implements WalletRepository {}

void main() {
  late _MockWalletRepository repository;
  late CreateTransactionUseCase useCase;

  setUp(() {
    repository = _MockWalletRepository();
    useCase = CreateTransactionUseCase(repository);
  });

  const CreateTransactionParams params = CreateTransactionParams(
    uid: 'uid-1',
    type: TransactionType.debit,
    amount: 12.5,
    description: 'Livraison vers Lyon',
    relatedDeliveryId: 'delivery-1',
  );

  test('délègue au repository avec les bons paramètres', () async {
    const TransactionEntity created = TransactionEntity(
      id: 'tx-1',
      uid: 'uid-1',
      type: TransactionType.debit,
      amount: 12.5,
      description: 'Livraison vers Lyon',
      relatedDeliveryId: 'delivery-1',
    );

    when(
      () => repository.createTransaction(
        uid: 'uid-1',
        type: TransactionType.debit,
        amount: 12.5,
        description: 'Livraison vers Lyon',
        relatedDeliveryId: 'delivery-1',
      ),
    ).thenAnswer((_) async => const Result<TransactionEntity>.success(created));

    final Result<TransactionEntity> result = await useCase(params);

    expect(result, const Result<TransactionEntity>.success(created));
  });

  test('propage un Failure.server en cas de solde insuffisant', () async {
    when(
      () => repository.createTransaction(
        uid: any(named: 'uid'),
        type: any(named: 'type'),
        amount: any(named: 'amount'),
        description: any(named: 'description'),
        relatedDeliveryId: any(named: 'relatedDeliveryId'),
      ),
    ).thenAnswer(
      (_) async =>
          const Result<TransactionEntity>.failure(Failure.server('Solde insuffisant.')),
    );

    final Result<TransactionEntity> result = await useCase(params);

    expect(
      result,
      isA<ResultFailure<TransactionEntity>>().having(
        (ResultFailure<TransactionEntity> r) => r.failure,
        'failure',
        isA<ServerFailure>(),
      ),
    );
  });
}
