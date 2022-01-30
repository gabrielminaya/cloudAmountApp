import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudamountapp/core/failure.dart';
import 'package:multiple_result/multiple_result.dart';

class HistoryRepository {
  Future<Result<Failure, List<Map<String, dynamic>>>> getAllConcept({
    required DateTime firstDate,
    required DateTime lastDate,
    required List<int> amountType,
  }) async {
    try {
      final collectionReference = FirebaseFirestore.instance.collection("amounts");
      final amountCollection = await collectionReference.get();

      final amounts = amountCollection.docs
          .map(
            (item) => {
              "id": item.id,
              "description": item.data()["description"],
              "amount": item.data()["amount"],
              "amount_type": item.data()["amount_type"],
              "effective_date": item.data()["effective_date"],
            },
          )
          .toList();

      final conceptsFiltered = <Map<String, dynamic>>[];

      for (final item in amounts) {
        final date = DateTime.fromMicrosecondsSinceEpoch(
          int.parse(item["effective_date"].toString()),
        );

        if (date.isAfter(firstDate)) {
          if (date.isBefore(lastDate)) {
            if (amountType.length == 2) {
              conceptsFiltered.add(item);
            } else {
              if (item["amount_type"] == amountType.first) {
                conceptsFiltered.add(item);
              }
            }
          }
        }
      }

      return Success(conceptsFiltered);
    } catch (error) {
      return Error(Failure(message: error.toString()));
    }
  }

  Future<Result<Failure, String>> createConcept({
    required int effectiveDate,
    required String description,
    required double amount,
  }) async {
    try {
      final collectionReference = FirebaseFirestore.instance.collection("amounts");

      final amountReference = await collectionReference.add({
        "amount_type": amount > 0 ? 1 : 2,
        "description": description,
        "amount": amount,
        "effective_date": effectiveDate,
        "created_date": DateTime.now().microsecondsSinceEpoch,
        "created_by": 1,
        "created_by_name": "User",
      });

      return Success(amountReference.id);
    } catch (error) {
      return Error(Failure(message: error.toString()));
    }
  }

  Future<Result<Failure, SuccessResult>> updateConcept({
    required String id,
    required int effectiveDate,
    required String description,
    required double amount,
  }) async {
    try {
      final collectionReference = FirebaseFirestore.instance.collection("amounts");

      await collectionReference.doc(id).update({
        "amount_type": amount > 0 ? 1 : 2,
        "description": description,
        "amount": amount,
        "effective_date": effectiveDate,
        "created_by": 1,
        "created_by_name": "User",
      });

      return const Success(success);
    } catch (error) {
      return Error(Failure(message: error.toString()));
    }
  }

  Future<Result<Failure, SuccessResult>> deleteConcept({required String id}) async {
    try {
      final collectionReference = FirebaseFirestore.instance.collection("amounts");

      await collectionReference.doc(id).delete();

      return const Success(success);
    } catch (error) {
      return Error(Failure(message: error.toString()));
    }
  }
}
