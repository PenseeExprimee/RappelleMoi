import 'package:flutter/material.dart';
import 'package:rappellemoi/utilities/dialogs/generic_dialog.dart';

Future <bool> choiceDialog(
  BuildContext context,
  String text
) {
  return showGenericDialog(
    context: context,
    title: 'Confirmation requise',
    content: text,
    optionsBuilder: () => {
      'Supprimer mon compte': true,
      'Annuler':null
    }
  ).then((value) => value ?? false);
}
