import 'package:flutter/material.dart';
import 'package:rappellemoi/utilities/dialogs/generic_dialog.dart';

Future <void> showInfoDialog(
  BuildContext context,
  String text
) {
  return showGenericDialog(
    context: context,
    title: 'Information',
    content: text,
    optionsBuilder: () => {
      'OK': null,
    }
  );
}