part of 'export_history_bloc.dart';

@immutable
abstract class ExportHistoryEvent {}

class ExportToExcelButtonPressed extends ExportHistoryEvent {
  final List<Map<String, dynamic>> history;

  ExportToExcelButtonPressed({required this.history});
}

class ExportToPdfButtonPressed extends ExportHistoryEvent {
  final List<Map<String, dynamic>> history;

  ExportToPdfButtonPressed({required this.history});
}
