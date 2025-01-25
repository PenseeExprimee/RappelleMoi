import 'package:flutter/material.dart';

// We need windows to be displayed to the users whenever we want to give them some information
// regular information, errors...

//DialogOptionBuilder is a function that returns a map
typedef  DialogOptionBuilder<T> = Map<String,T?> Function(); 

Future <T?> showGenericDialog<T>({
  //parameters
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionsBuilder,
}) {
  final options = optionsBuilder();
  return showDialog<T>(
    context: context,
    builder: (context){
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: options.keys.map((optionTitle){ //every title is mapped to a text button
          final value = options[optionTitle];
          return TextButton(
            onPressed: (){
              if(value != null){
                //will dismiss the dialog and return back the value
                Navigator.of(context).pop(value);
              } else {
                //just dismiss the dialog if the button has no specific value.
                Navigator.of(context).pop();
              }
            },
            child: Text(optionTitle),
          );
        }).toList(),
      );
    },
  );
}