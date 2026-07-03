import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:poc_uber/core/error/failure.dart';
import 'package:poc_uber/core/error/result.dart';
import 'package:poc_uber/features/delivery/data/datasources/delivery_remote_datasource.dart';
import 'package:poc_uber/features/delivery/data/models/delivery_model.dart';
import 'package:poc_uber/features/delivery/domain/entities/delivery_entity.dart';
import 'package:poc_uber/features/delivery/domain/repositories/delivery_repository.dart';

class DeliveryRepositoryImpl implements DeliveryRepository {
  const DeliveryRepositoryImpl(this._remoteDataSource);

  final DeliveryRemoteDataSource _remoteDataSource;

  @override
  Future<Result<DeliveryEntity>> createDelivery(
    DeliveryEntity delivery,
  ) async {
    try {
      final DeliveryModel model = DeliveryModel.fromEntity(delivery);
      final DeliveryModel created = await _remoteDataSource.createDelivery(
        model,
      );
      return Result.success(created.toEntity());
    } on FirebaseException catch (e) {
      return Result.failure(
        Failure.server(e.message ?? 'Erreur lors de la création de la livraison.'),
      );
    } catch (e) {
      return Result.failure(Failure.unknown(e.toString()));
    }
  }

  @override
  Stream<List<DeliveryEntity>> watchUserDeliveries(String senderId) {
    return _remoteDataSource
        .watchUserDeliveries(senderId)
        .map(
          (List<DeliveryModel> models) => models
              .map((DeliveryModel model) => model.toEntity())
              .toList(),
        );
  }

  @override
  Stream<DeliveryEntity?> watchDeliveryById(String id) {
    return _remoteDataSource
        .watchDeliveryById(id)
        .map((DeliveryModel? model) => model?.toEntity());
  }
}
