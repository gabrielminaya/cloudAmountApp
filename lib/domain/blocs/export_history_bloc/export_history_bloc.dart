import 'dart:developer';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:cloudamountapp/core/failure.dart';
import 'package:cloudamountapp/core/utils.dart';
import 'package:meta/meta.dart';
import 'package:path_provider/path_provider.dart';
import 'package:excel/excel.dart';
import 'package:open_file/open_file.dart' as openfile;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart';

part 'export_history_event.dart';
part 'export_history_state.dart';

class ExportHistoryBloc extends Bloc<ExportHistoryEvent, ExportHistoryState> {
  ExportHistoryBloc() : super(ExportHistoryInitial()) {
    on<ExportToExcelButtonPressed>((event, emit) async {
      try {
        await Permission.storage.request();

        final excel = Excel.createExcel();
        final directory = await getApplicationDocumentsDirectory();
        var totalNegativeAmount = 0.0;
        var totalPositiveAmount = 0.0;
        var totalAmount = 0.0;

        for (final item in event.history) {
          if (double.parse(item["amount"].toString()) > 0) {
            totalPositiveAmount += double.parse(item["amount"].toString());
          }
          if (double.parse(item["amount"].toString()) < 0) {
            totalNegativeAmount += double.parse(item["amount"].toString());
          }
          totalAmount += double.parse(item["amount"].toString());
        }

        excel.rename("Sheet1", "DUMP");

        excel.appendRow("DUMP", ["FECHA", "CONCEPTO", "MONTO"]);
        for (final item in event.history) {
          final effetiveDate = DateTime.fromMicrosecondsSinceEpoch(int.parse(item["effective_date"].toString()));
          excel.appendRow(
            "DUMP",
            [
              "${effetiveDate.day}/${effetiveDate.month}/${effetiveDate.year}",
              item["description"],
              item["amount"],
            ],
          );
        }
        excel.appendRow("DUMP", ["", "TOTAL DE ENTRADAS", totalPositiveAmount]);
        excel.appendRow("DUMP", ["", "TOTAL DE SALIDAS", totalNegativeAmount]);
        excel.appendRow("DUMP", ["", "TOTAL NETO", totalAmount]);

        final fileBytes = excel.save();

        if (fileBytes != null) {
          File(join(directory.path, "data.xls"))
            ..createSync(recursive: true)
            ..writeAsBytesSync(fileBytes);
        }

        await openfile.OpenFile.open(join(directory.path, "data.xls"));
        emit(ExportHistorySuccess());
      } catch (e) {
        emit(ExportHistoryFailure(failure: Failure(message: e.toString())));
      }
    });

    on<ExportToPdfButtonPressed>((event, emit) async {
      try {
        final pdf = pw.Document();
        final directory = await getApplicationDocumentsDirectory();
        final dateNow = DateTime.now();
        var totalNegativeAmount = 0.0;
        var totalPositiveAmount = 0.0;
        var totalAmount = 0.0;

        log("${event.history.length}");

        for (final item in event.history) {
          if (double.parse(item["amount"].toString()) > 0) {
            totalPositiveAmount += double.parse(item["amount"].toString());
          }
          if (double.parse(item["amount"].toString()) < 0) {
            totalNegativeAmount += double.parse(item["amount"].toString());
          }
          totalAmount += double.parse(item["amount"].toString());
        }

        pdf.addPage(pw.MultiPage(
            pageFormat: PdfPageFormat.a4,
            build: (pw.Context context) {
              return [
                pw.Header(
                  level: 0,
                  child: pw.Text("Historial de movimientos",
                      style: const pw.TextStyle(fontSize: 20), textAlign: pw.TextAlign.center),
                ),
                pw.Table.fromTextArray(
                  context: context,
                  data: [
                    [
                      "FECHA",
                      "CONCEPTO",
                      "MONTO",
                    ],
                    ...event.history.map((item) {
                      final effetiveDate =
                          DateTime.fromMicrosecondsSinceEpoch(int.parse(item["effective_date"].toString()));
                      return [
                        "${effetiveDate.day}/${effetiveDate.month}/${effetiveDate.year}",
                        item["description"],
                        Utils.formatNumberToCurrency(value: item["amount"]),
                      ];
                    }),
                    [
                      "",
                      "TOTAL DE ENTRADAS",
                      Utils.formatNumberToCurrency(value: totalPositiveAmount),
                    ],
                    [
                      "",
                      "TOTAL DE SALIDAS",
                      Utils.formatNumberToCurrency(value: totalNegativeAmount),
                    ],
                    [
                      "",
                      "TOTAL NETO",
                      Utils.formatNumberToCurrency(value: totalAmount),
                    ],
                  ],
                  headerAlignment: pw.Alignment.center,
                  cellAlignment: pw.Alignment.center,
                ),
                pw.Text(
                    "Generado el ${dateNow.day}/${dateNow.month}/${dateNow.year} a las ${dateNow.hour}:${dateNow.minute}"),
              ];
              // Center
            }));

        final fileBytes = await pdf.save();

        File(join(directory.path, "data.pdf"))
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);

        await openfile.OpenFile.open(join(directory.path, "data.pdf"));

        emit(ExportHistorySuccess());
      } catch (e) {
        emit(ExportHistoryFailure(failure: Failure(message: e.toString())));
      }
    });
  }
}
