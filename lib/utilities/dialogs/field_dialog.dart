import 'package:flutter/material.dart';
import 'dart:developer' as devtools show log;


// We need windows to be displayed to the users whenever we want to give them some information
// regular information, errors...
//DialogOptionBuilder is a function that returns a map
typedef  DialogOptionBuilder<T> = Map<String,T?> Function(); 

Future <Map<String,String>?> showGenericFieldDialog<T>({
  //parameters
  required BuildContext context,
  required String title,
  required String content,
  required DialogOptionBuilder optionsBuilder,
}) {
  final options = optionsBuilder();
  late final _email = TextEditingController();
  late final _password = TextEditingController();

  return showDialog<Map<String,String>?>(
    context: context,
    builder: (context){
      return AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              textAlign: TextAlign.center,
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
              hintText: "Entrez votre adresse mail...",
              border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
            const SizedBox(height:10), 
            TextField(
              textAlign: TextAlign.center,
              controller: _password,
              keyboardType: TextInputType.emailAddress,
              autocorrect: false,
              enableSuggestions: false,
              decoration: const InputDecoration(
              hintText: "Entrez votre mot de passe...",
              border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            )],
        ),
        actions: options.keys.map((optionTitle){ //every title is mapped to a text button
          final value = options[optionTitle];
          return TextButton(
            onPressed: (){
              if(value != null){
                devtools.log("Value not null detected");
                //will dismiss the dialog and return back the value
            
                Navigator.of(context).pop({"email": _email.text, "password": _password.text });
                
              } else {
                //just dismiss the dialog if the button has no specific value.
                devtools.log("Value of ok button isnull");
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