import 'package:flutter/material.dart';
import 'package:rappellemoi/utilities/dialogs/field_dialog.dart';

Future <Map<String,String>?> showFieldDialog(
  BuildContext context,
  String text
) {
  return showGenericFieldDialog(
    context: context,
    title: 'Information requise',
    content: text,
    optionsBuilder: () => {
      'OK': true,
    }
  );
}
