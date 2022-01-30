import 'package:animations/animations.dart';
import 'package:cloudamountapp/core/utils.dart';
import 'package:cloudamountapp/domain/blocs/export_history_bloc/export_history_bloc.dart';
import 'package:cloudamountapp/domain/blocs/history_of_amount_bloc/history_of_amount_bloc.dart';
import 'package:cloudamountapp/domain/blocs/theme_mode_bloc/theme_mode_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class HomeView extends StatelessWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Historial"),
        actions: [
          IconButton(
            onPressed: () => context.read<ThemeModeBloc>().add(ChangeThemeModeButtonPressed()),
            icon: BlocBuilder<ThemeModeBloc, ThemeModeState>(
              builder: (context, state) {
                if (state is ThemeModeDark) {
                  return const Icon(Icons.brightness_3);
                } else {
                  return const Icon(Icons.brightness_7);
                }
              },
            ),
          ),
          IconButton(
            icon: const Icon(Icons.file_upload_outlined),
            onPressed: () => exportDialog(context: context),
          ),
          IconButton(
            onPressed: () => context.read<HistoryOfAmountBloc>().add(GetAllHistoryButtonPressed()),
            icon: const Icon(Icons.autorenew_rounded),
          ),
          IconButton(
            onPressed: () => filterConcept(mainContext: context),
            icon: const Icon(Icons.filter_list_rounded),
          ),
          IconButton(
            onPressed: () => createOrUpdateConcept(mainContext: context),
            icon: const Icon(Icons.post_add_sharp),
          ),
        ],
      ),
      body: BlocConsumer<HistoryOfAmountBloc, HistoryOfAmountState>(
        listener: (context, state) {
          if (state is HistoryOfAmountLoadFailure) {
            Utils.showSnackBack(
              context: context,
              message: state.failure.message,
              isFloating: true,
            );
          }
        },
        builder: (context, state) {
          if (state is HistoryOfAmountInitial) {
            context.read<HistoryOfAmountBloc>().add(GetAllHistoryButtonPressed());
          }

          if (state is HistoryOfAmountLoadInProgress) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is HistoryOfAmountLoaded) {
            var totalNegativeAmount = 0.0;
            var totalPositiveAmount = 0.0;
            var totalAmount = 0.0;

            for (final item in state.history) {
              if (double.parse(item["amount"].toString()) > 0) {
                totalPositiveAmount += double.parse(item["amount"].toString());
              }
              if (double.parse(item["amount"].toString()) < 0) {
                totalNegativeAmount += double.parse(item["amount"].toString());
              }
              totalAmount += double.parse(item["amount"].toString());
            }

            return SingleChildScrollView(
              child: Column(
                children: [
                  PaginatedDataTable(
                    columns: const [
                      DataColumn(label: Text("FECHA")),
                      DataColumn(label: Text("CONCEPTO")),
                      DataColumn(label: Text("MONTO (DOP)")),
                      DataColumn(label: Text("ACCIONES")),
                    ],
                    source: HistoryDataSource(context: context, history: state.history),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Card(
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        width: MediaQuery.of(context).size.width,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              "TOTAL DE ENTRADA:    ${Utils.formatNumberToCurrency(value: totalPositiveAmount)}",
                            ),
                            Text(
                              "TOTAL DE SALIDA:    ${Utils.formatNumberToCurrency(value: totalNegativeAmount)}",
                            ),
                            Text(
                              "TOTAL NETO:    ${Utils.formatNumberToCurrency(value: totalAmount)}",
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return Container();
          }
        },
      ),
    );
  }

  Future<void> exportDialog({required BuildContext context}) {
    return showModal(
      context: context,
      builder: (innerContext) {
        var optionSelected = 1;

        return AlertDialog(
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Divider(),
              Text("SELECCIONA FORMATO"),
              Divider(),
            ],
          ),
          content: StatefulBuilder(builder: (statefulContext, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  width: double.infinity,
                  child: FormBuilderRadioGroup<int>(
                    name: "format",
                    decoration: const InputDecoration(
                      helperText: "El formato en el cual se exportará el historial",
                      helperMaxLines: 3,
                    ),
                    options: const [
                      FormBuilderFieldOption(value: 1, child: Text("PDF")),
                      FormBuilderFieldOption(value: 2, child: Text("EXCEL")),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        optionSelected = value;
                      }
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(innerContext).pop(),
                      child: const Text("Cancelar"),
                    ),
                    const VerticalDivider(),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).errorColor,
                        ),
                        onPressed: () {
                          final historyFiltered = context.read<HistoryOfAmountBloc>().historyFiltered;

                          if (optionSelected == 1) {
                            context.read<ExportHistoryBloc>().add(ExportToPdfButtonPressed(history: historyFiltered));
                          } else {
                            context.read<ExportHistoryBloc>().add(ExportToExcelButtonPressed(history: historyFiltered));
                          }

                          Navigator.of(innerContext).pop();
                        },
                        child: const Text("Exportar"),
                      ),
                    ),
                  ],
                ),
              ],
            );
          }),
        );
      },
    );
  }

  Future<void> filterConcept({required BuildContext mainContext}) {
    final formKey = GlobalKey<FormBuilderState>();

    return showModal(
      context: mainContext,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            "FILTRAR HISTORIAL",
            textAlign: TextAlign.center,
          ),
          content: FormBuilder(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormBuilderDateRangePicker(
                  name: "dateRange",
                  initialEntryMode: DatePickerEntryMode.calendarOnly,
                  decoration: const InputDecoration(
                    labelText: "Rango de fecha",
                    helperText: "Elija el rango de fecha en el cual se filtrará el historial",
                    helperMaxLines: 3,
                  ),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  validator: FormBuilderValidators.required(context),
                ),
                const SizedBox(height: 20),
                FormBuilderCheckboxGroup<int>(
                  name: "amountType",
                  decoration: const InputDecoration(
                    labelText: "Tipe de monto",
                    helperText: "El tipo de monto a filtrar",
                  ),
                  options: const [
                    FormBuilderFieldOption(value: 1, child: Text("Entradas")),
                    FormBuilderFieldOption(value: 2, child: Text("Salidas")),
                  ],
                  validator: FormBuilderValidators.required(context),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancelar"),
                    ),
                    const VerticalDivider(),
                    Expanded(
                      child: ElevatedButton(
                        child: const Text("Filtrar"),
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).colorScheme.error,
                        ),
                        onPressed: () {
                          final formResult = formKey.currentState?.validate();
                          if (formResult == null) return;
                          if (formResult == false) return;

                          formKey.currentState?.save();

                          final firstDate = formKey.currentState!.value["dateRange"]?.start as DateTime;
                          final lastDate = formKey.currentState!.value["dateRange"]?.end as DateTime;
                          final amountType = formKey.currentState!.value["amountType"];

                          mainContext.read<HistoryOfAmountBloc>().add(
                                GetAllHistoryFilteredButtonPressed(
                                  firstDate: firstDate,
                                  lastDate: lastDate,
                                  amountType: amountType,
                                ),
                              );

                          Navigator.of(context).pop();
                        },
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

class HistoryDataSource extends DataTableSource {
  final List<Map<String, dynamic>> history;
  final BuildContext context;

  HistoryDataSource({required this.context, required this.history});

  @override
  DataRow? getRow(int index) {
    final record = history.elementAt(index);

    final date = DateTime.fromMicrosecondsSinceEpoch(
      int.parse(record["effective_date"].toString()),
    );

    return DataRow(cells: [
      DataCell(Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(Utils.formatDate(date)),
          Text(Utils.dateToTimeAge(date: date), style: Theme.of(context).textTheme.caption),
        ],
      )),
      DataCell(
        Text(
          record["description"].toString(),
          style: Theme.of(context).textTheme.bodyText2,
          maxLines: 3,
        ),
      ),
      DataCell(
        Text(
          Utils.formatNumberToCurrency(value: record["amount"]),
          textAlign: TextAlign.right,
          style: TextStyle(
            color: record["amount_type"] == 1 ? Colors.green : Theme.of(context).colorScheme.error,
          ),
        ),
      ),
      DataCell(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: () => createOrUpdateConcept(
                mainContext: context,
                record: record,
              ),
              icon: Icon(
                Icons.edit,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            IconButton(
              onPressed: () {
                context
                    .read<HistoryOfAmountBloc>()
                    .add(DeleteRecordToHistoryButtonPressed(id: record["id"].toString()));
              },
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
            ),
          ],
        ),
      ),
    ]);
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => history.length;

  @override
  int get selectedRowCount => 0;
}

Future<void> createOrUpdateConcept({
  required BuildContext mainContext,
  Map<String, dynamic>? record,
}) {
  final formKey = GlobalKey<FormBuilderState>();

  final effectiveDate = record != null
      ? DateTime.fromMicrosecondsSinceEpoch(
          int.parse(record["effective_date"].toString()),
        )
      : null;

  final decription = record != null ? record["description"].toString() : null;

  final amount = record != null ? record["amount"].toString() : null;

  return showModal(
    context: mainContext,
    builder: (context) {
      return AlertDialog(
        title: Text(
          "${record == null ? "AGREGAR" : "EDITAR"} RECORD",
          textAlign: TextAlign.center,
        ),
        content: FormBuilder(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FormBuilderDateTimePicker(
                  name: "date",
                  initialValue: effectiveDate,
                  decoration: const InputDecoration(
                    labelText: "FECHA EFECTIVA",
                    helperText: "Elija la fecha en la cual se efectuará el registro",
                    helperMaxLines: 3,
                  ),
                  initialEntryMode: DatePickerEntryMode.calendarOnly,
                  alwaysUse24HourFormat: false,
                  inputType: InputType.date,
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                ),
                const SizedBox(height: 20),
                FormBuilderTextField(
                  name: "description",
                  initialValue: decription,
                  decoration: const InputDecoration(
                    labelText: "CONCEPTO",
                    helperText: "Descripción del concepto",
                    helperMaxLines: 3,
                  ),
                  maxLength: 50,
                  maxLines: 3,
                  minLines: 1,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(context),
                    FormBuilderValidators.minLength(context, 3),
                    FormBuilderValidators.maxLength(context, 50),
                  ]),
                ),
                const SizedBox(height: 20),
                FormBuilderTextField(
                  name: "amount",
                  initialValue: amount,
                  decoration: const InputDecoration(
                    labelText: "MONTO",
                    helperText: "El monto a registrar",
                    suffixText: "DOP",
                    helperMaxLines: 3,
                  ),
                  keyboardType: TextInputType.number,
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(context),
                    FormBuilderValidators.numeric(context),
                  ]),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text("Cancelar"),
                    ),
                    const VerticalDivider(),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          final formResult = formKey.currentState?.validate();

                          if (formResult == null) return;
                          if (formResult == false) return;

                          formKey.currentState?.save();

                          final effectiveDate = formKey.currentState!.value["date"] as DateTime;
                          final description = formKey.currentState!.value["description"];
                          final amount = formKey.currentState!.value["amount"];

                          formKey.currentState!.validate();

                          if (record == null) {
                            mainContext.read<HistoryOfAmountBloc>().add(AddRecordToHistoryButtonPressed(
                                effectiveDate: effectiveDate.microsecondsSinceEpoch,
                                amount: double.parse(amount),
                                description: description));
                          } else {
                            mainContext.read<HistoryOfAmountBloc>().add(UpdateRecordToHistoryButtonPressed(
                                id: record["id"].toString(),
                                effectiveDate: effectiveDate.microsecondsSinceEpoch,
                                description: description,
                                amount: double.parse(amount)));
                          }

                          Navigator.of(context).pop();
                        },
                        child: record == null ? const Text("Agregar") : const Text("Corregir"),
                        style: ElevatedButton.styleFrom(
                          primary: Theme.of(context).errorColor,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      );
    },
  );
}
