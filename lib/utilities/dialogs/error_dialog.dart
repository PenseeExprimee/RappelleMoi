import 'package:flutter/material.dart';
import 'package:rappellemoi/utilities/dialogs/generic_dialog.dart';

Future <void> showErrorDialog(
  BuildContext context,
  String text
) {
  return showGenericDialog(
    context: context,
    title: 'An errror occured',
    content: text,
    optionsBuilder: () => {
      'OK': null,
    }
  );
}
