part of 'export_history_bloc.dart';

@immutable
abstract class ExportHistoryState {}

class ExportHistoryInitial extends ExportHistoryState {}

class ExportHistorySuccess extends ExportHistoryState {}

class ExportHistoryFailure extends ExportHistoryState {
  final Failure failure;

  ExportHistoryFailure({required this.failure});
}
