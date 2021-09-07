import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../../../core/error/exceptions/errors.dart';
import '../../../../core/error/failure/failure.dart';

class ConceptRepository {
  Future<Either<Failure, List<Map<String, dynamic>>>> getAllConcept({
    required DateTime firstDate,
    required DateTime lastDate,
    required int amountType,
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
            if (amountType == 3) {
              conceptsFiltered.add(item);
            } else {
              if (item["amount_type"] == amountType) {
                conceptsFiltered.add(item);
              }
            }
          }
        }
      }

      return right(conceptsFiltered);
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, String>> createConcept({
    required int effectiveDate,
    required String description,
    required double amount,
  }) async {
    try {
      final collectionReference = FirebaseFirestore.instance.collection("amounts");

      int amountType;

      if (amount > 0)
        amountType = 1;
      else
        amountType = 2;

      final amountReference = await collectionReference.add({
        "amount_type": amountType,
        "description": description,
        "amount": amount,
        "effective_date": effectiveDate,
        "created_date": DateTime.now().microsecondsSinceEpoch,
        "created_by": 1,
        "created_by_name": "User",
      });

      return right(amountReference.id);
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, int>> updateConcept({
    required String id,
    required int effectiveDate,
    required String description,
    required double amount,
  }) async {
    try {
      final collectionReference = FirebaseFirestore.instance.collection("amounts");

      int amountType;

      if (amount > 0)
        amountType = 1;
      else
        amountType = 2;

      await collectionReference.doc(id).update({
        "amount_type": amountType,
        "description": description,
        "amount": amount,
        "effective_date": effectiveDate,
        "created_by": 1,
        "created_by_name": "User",
      });

      return right(1);
    } on SystemError catch (error) {
      return left(Failure(message: error.message));
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }

  Future<Either<Failure, int>> deleteConcept({required String id}) async {
    try {
      final collectionReference = FirebaseFirestore.instance.collection("amounts");

      await collectionReference.doc(id).delete();

      return right(1);
    } on SystemError catch (error) {
      return left(Failure(message: error.message));
    } catch (error) {
      return left(Failure(message: error.toString()));
    }
  }
}
