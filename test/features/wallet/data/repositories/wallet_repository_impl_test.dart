import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:poc_uber/core/error/failure.dart';
import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/features/wallet/data/datasources/wallet_remote_datasource.dart';
import 'package:poc_uber/features/wallet/data/models/transaction_model.dart';
import 'package:poc_uber/features/wallet/data/models/wallet_model.dart';
import 'package:poc_uber/features/wallet/data/repositories/wallet_repository_impl.dart';
import 'package:poc_uber/features/wallet/domain/entities/transaction_entity.dart';
import 'package:poc_uber/features/wallet/domain/entities/wallet_entity.dart';

class _MockWalletRemoteDataSource extends Mock implements WalletRemoteDataSource {}

void main() {
  late _MockWalletRemoteDataSource dataSource;
  late WalletRepositoryImpl repository;

  setUp(() {
    dataSource = _MockWalletRemoteDataSource();
    repository = WalletRepositoryImpl(dataSource);
  });

  group('createTransaction', () {
    test('renvoie un succès mappé en TransactionEntity', () async {
      const TransactionModel model = TransactionModel(
        id: 'tx-1',
        uid: 'uid-1',
        type: TransactionType.debit,
        amount: 10,
        description: 'Livraison',
      );

      when(
        () => dataSource.createTransaction(
          uid: 'uid-1',
          type: TransactionType.debit,
          amount: 10,
          description: 'Livraison',
          relatedDeliveryId: null,
        ),
      ).thenAnswer((_) async => model);

      final Result<TransactionEntity> result = await repository.createTransaction(
        uid: 'uid-1',
        type: TransactionType.debit,
        amount: 10,
        description: 'Livraison',
      );

      expect(
        result,
        isA<ResultSuccess<TransactionEntity>>().having(
          (ResultSuccess<TransactionEntity> r) => r.value.id,
          'id',
          'tx-1',
        ),
      );
    });

    test('mappe InsufficientBalanceException en Failure.server', () async {
      when(
        () => dataSource.createTransaction(
          uid: any(named: 'uid'),
          type: any(named: 'type'),
          amount: any(named: 'amount'),
          description: any(named: 'description'),
          relatedDeliveryId: any(named: 'relatedDeliveryId'),
        ),
      ).thenThrow(const InsufficientBalanceException());

      final Result<TransactionEntity> result = await repository.createTransaction(
        uid: 'uid-1',
        type: TransactionType.debit,
        amount: 1000,
        description: 'Livraison',
      );

      expect(
        result,
        isA<ResultFailure<TransactionEntity>>().having(
          (ResultFailure<TransactionEntity> r) => r.failure,
          'failure',
          isA<ServerFailure>(),
        ),
      );
    });
  });

  test('watchWallet mappe WalletModel en WalletEntity', () {
    when(() => dataSource.watchWallet('uid-1')).thenAnswer(
      (_) => Stream<WalletModel?>.value(
        const WalletModel(uid: 'uid-1', balance: 50),
      ),
    );

    expect(
      repository.watchWallet('uid-1'),
      emits(const WalletEntity(uid: 'uid-1', balance: 50)),
    );
  });

  test('ensureWalletExists renvoie un succès quand le datasource réussit', () async {
    when(() => dataSource.ensureWalletExists('uid-1')).thenAnswer((_) async {});

    final Result<void> result = await repository.ensureWalletExists('uid-1');

    expect(result, const Result<void>.success(null));
  });
}
