import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dart_date/dart_date.dart';

class Utils {
  const Utils._();

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String dateToTimeAge({required DateTime date}) {
    return date.timeago(locale: 'es');
  }

  static String formatNumberToCurrency({required double value}) {
    final formatter = NumberFormat.currency(locale: 'en_DO', decimalDigits: 2, symbol: '');
    return formatter.format(value);
  }

  static ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBack({
    required BuildContext context,
    required String message,
    Color color = Colors.red,
    bool isFloating = false,
  }) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: isFloating ? SnackBarBehavior.floating : SnackBarBehavior.fixed,
        action: SnackBarAction(
          label: 'Ok',
          onPressed: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(
            reason: SnackBarClosedReason.hide,
          ),
        ),
      ),
    );
  }
}
