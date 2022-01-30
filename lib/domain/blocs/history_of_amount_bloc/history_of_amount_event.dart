part of 'history_of_amount_bloc.dart';

@immutable
abstract class HistoryOfAmountEvent {}

class GetAllHistoryButtonPressed extends HistoryOfAmountEvent {}

class GetAllHistoryFilteredButtonPressed extends HistoryOfAmountEvent {
  final DateTime firstDate;
  final DateTime lastDate;
  final List<int> amountType;

  GetAllHistoryFilteredButtonPressed({
    required this.firstDate,
    required this.lastDate,
    required this.amountType,
  });
}

class AddRecordToHistoryButtonPressed extends HistoryOfAmountEvent {
  final int effectiveDate;
  final String description;
  final double amount;

  AddRecordToHistoryButtonPressed({
    required this.effectiveDate,
    required this.description,
    required this.amount,
  });
}

class UpdateRecordToHistoryButtonPressed extends HistoryOfAmountEvent {
  final String id;
  final int effectiveDate;
  final String description;
  final double amount;

  UpdateRecordToHistoryButtonPressed({
    required this.id,
    required this.effectiveDate,
    required this.description,
    required this.amount,
  });
}

class DeleteRecordToHistoryButtonPressed extends HistoryOfAmountEvent {
  final String id;

  DeleteRecordToHistoryButtonPressed({
    required this.id,
  });
}
