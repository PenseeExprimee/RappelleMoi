import 'package:flutter/material.dart';
import 'package:rappellemoi/utilities/dialogs/generic_dialog.dart';

Future <void> showErrorDialog(
  BuildContext context,
  String text
) {
  return showGenericDialog(
    context: context,
    title: "Une erreur s'est produite",
    content: text,
    optionsBuilder: () => {
      'OK': null,
    }
  );
}
