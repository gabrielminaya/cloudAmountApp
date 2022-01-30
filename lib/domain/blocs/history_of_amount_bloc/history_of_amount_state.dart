part of 'history_of_amount_bloc.dart';

@immutable
abstract class HistoryOfAmountState {}

class HistoryOfAmountInitial extends HistoryOfAmountState {}

class HistoryOfAmountLoadInProgress extends HistoryOfAmountState {}

class HistoryOfAmountLoaded extends HistoryOfAmountState {
  final List<Map<String, dynamic>> history;

  HistoryOfAmountLoaded({required this.history});
}

class HistoryOfAmountLoadFailure extends HistoryOfAmountState {
  final Failure failure;

  HistoryOfAmountLoadFailure({required this.failure});
}
