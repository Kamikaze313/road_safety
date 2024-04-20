import 'package:flutter/material.dart';

// class CustomSnackBar {
//   CustomSnackBar(BuildContext context, Widget content,
//       {SnackBarAction snackBarAction, Color backgroundColor = Colors.green}) {
//     final SnackBar snackBar = SnackBar(
//         action: snackBarAction,
//         backgroundColor: backgroundColor,
//         content: content,
//         behavior: SnackBarBehavior.floating);

//     ScaffoldMessenger.of(context).hideCurrentSnackBar();
//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   }
// }

class CustomSnackBar {
  CustomSnackBar(BuildContext context, Widget content,
      {String actionLabel = 'Action', VoidCallback? onActionPressed, Color backgroundColor = Colors.green}) {
    final SnackBarAction snackBarAction = SnackBarAction(
      label: actionLabel,
      onPressed: onActionPressed ?? () {}, // Use the provided onPressed callback, or an empty callback if not provided
    );

    final SnackBar snackBar = SnackBar(
      action: snackBarAction,
      backgroundColor: backgroundColor,
      content: content,
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

