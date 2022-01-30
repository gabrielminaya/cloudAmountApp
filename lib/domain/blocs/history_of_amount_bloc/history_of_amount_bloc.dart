import 'package:bloc/bloc.dart';
import 'package:cloudamountapp/core/failure.dart';
import 'package:cloudamountapp/data/repositories/history_repository.dart';
import 'package:meta/meta.dart';

part 'history_of_amount_event.dart';
part 'history_of_amount_state.dart';

class HistoryOfAmountBloc extends Bloc<HistoryOfAmountEvent, HistoryOfAmountState> {
  final HistoryRepository _historyRepository;
  List<Map<String, dynamic>> historyFiltered = [];

  HistoryOfAmountBloc(this._historyRepository) : super(HistoryOfAmountInitial()) {
    on<GetAllHistoryButtonPressed>((event, emit) async {
      emit(HistoryOfAmountLoadInProgress());

      final historyOrFailure = await _historyRepository.getAllConcept(
        firstDate: DateTime.now().subtract(const Duration(days: 30)),
        lastDate: DateTime.now(),
        amountType: [1, 2],
      );

      return historyOrFailure.when(
        (failure) => emit(HistoryOfAmountLoadFailure(failure: failure)),
        (history) {
          historyFiltered.clear();
          history.sort((a, b) => b['date'].compareTo(a['date']));
          historyFiltered.addAll(history);
          emit(HistoryOfAmountLoaded(history: history));
        },
      );
    });

    on<GetAllHistoryFilteredButtonPressed>((event, emit) async {
      emit(HistoryOfAmountLoadInProgress());

      final conceptsOrFailure = await _historyRepository.getAllConcept(
        firstDate: event.firstDate,
        lastDate: event.lastDate,
        amountType: event.amountType,
      );

      return conceptsOrFailure.when(
        (failure) => emit(HistoryOfAmountLoadFailure(failure: failure)),
        (history) {
          historyFiltered.clear();
          history.sort((a, b) => b['effective_date'].compareTo(a['effective_date']));
          historyFiltered.addAll(history);
          emit(HistoryOfAmountLoaded(history: history));
        },
      );
    });

    on<AddRecordToHistoryButtonPressed>((event, emit) async {
      final successOrFailure = await _historyRepository.createConcept(
        effectiveDate: event.effectiveDate,
        description: event.description,
        amount: event.amount,
      );

      return successOrFailure.when(
        (failure) async {
          emit(HistoryOfAmountLoadFailure(failure: failure));
          add(GetAllHistoryButtonPressed());
        },
        (_) => add(GetAllHistoryButtonPressed()),
      );
    });

    on<UpdateRecordToHistoryButtonPressed>((event, emit) async {
      final successOrFailure = await _historyRepository.updateConcept(
        id: event.id,
        effectiveDate: event.effectiveDate,
        description: event.description,
        amount: event.amount,
      );

      return successOrFailure.when(
        (failure) async {
          emit(HistoryOfAmountLoadFailure(failure: failure));
          add(GetAllHistoryButtonPressed());
        },
        (_) => add(GetAllHistoryButtonPressed()),
      );
    });

    on<DeleteRecordToHistoryButtonPressed>((event, emit) async {
      final successOrFailure = await _historyRepository.deleteConcept(id: event.id);

      return successOrFailure.when(
        (failure) async {
          emit(HistoryOfAmountLoadFailure(failure: failure));
          add(GetAllHistoryButtonPressed());
        },
        (_) => add(GetAllHistoryButtonPressed()),
      );
    });
  }
}
