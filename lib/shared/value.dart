import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:toko_online/shared/theme.dart';

String convertCurrency(int number) {
  return NumberFormat.currency(
    locale: "id_ID",
    decimalDigits: 0,
  ).format(number);
}

void showingSnackBar(BuildContext context, String title, String labelAction,
    Function onActionPressed) {
  Scaffold.of(context).removeCurrentSnackBar();
  Scaffold.of(context).showSnackBar(
    SnackBar(
      content: Text(title),
      backgroundColor: mainColor,
      duration: Duration(seconds: 2),
      action: SnackBarAction(
        label: labelAction,
        onPressed: onActionPressed,
      ),
    ),
  );
}

String getInitials(String name) {
  if (name == null) {
    return "";
  }
  final initial = name.split(" ");
  if (initial.length > 1)
    return initial[0].substring(0, 1) + (initial.last.substring(0, 1));
  return initial[0].substring(0, 1);
}
