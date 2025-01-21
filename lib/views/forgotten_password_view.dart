import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rappellemoi/services/auth/auth_exceptions.dart';
import 'package:rappellemoi/services/bloc/auth_bloc.dart';
import 'package:rappellemoi/services/bloc/auth_event.dart';
import 'dart:developer' as devtools show log;

import 'package:rappellemoi/services/bloc/auth_state.dart';
import 'package:rappellemoi/utilities/dialogs/error_dialog.dart';
import 'package:rappellemoi/utilities/dialogs/info_dialog.dart';

class ForgottenPasswordView extends StatefulWidget {
  const ForgottenPasswordView({super.key});

  @override
  State<ForgottenPasswordView> createState() => _ForgottenPasswordViewState();
}

class _ForgottenPasswordViewState extends State<ForgottenPasswordView> {
  late final TextEditingController _email;

  @override
  void initState() {
    _email = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) async {
        devtools.log("Current state: $state");
       if(state is AuthStateForgottenPassword){
        devtools.log("at least here no?");
          if(state.exception is FailResetPasswordException){
            await showErrorDialog(context, "Please enter an email.");
          }
          else if(state.exception is InvalidEmailForResetException){
            await showErrorDialog(context, "Please enter a valid email.");
          }
          else{
            devtools.log("HEEEEEEEEEEERE LAURA");
            await showInfoDialog(context, "If an account with this email exists, a reset email has been sent.");
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("MEMOIRE COURTE"),
        ),
        body: ListView(
          children: [
            const SizedBox(height: 50),
            Container(
              height: 75.0,
              width: 75.0,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/eye_rolling.jpg'),
                      fit: BoxFit.contain)),
            ),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                  "Vous avez oublié votre mot de passe... \nEntrez l'adresse mail liée à votre compte pour recevoir un lien de réinitialisation.\nAttention, si le mail n'est associé à aucun compte, vous ne recevrez rien."),
            ),
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  TextField(
                    textAlign: TextAlign.center,
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autocorrect: false,
                    enableSuggestions: false,
                    decoration: const InputDecoration(
                      hintText: "Entrez votre adresse email...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                ])),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextButton(
                onPressed: () {
                  devtools.log("The reset password button has been pressed");
                  //Clear the fields after the login button has been pressed
                  context
                      .read<AuthBloc>()
                      .add(AuthEventSendResetPasswordLink(email: _email.text));
                  _email.clear();
                },
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular((100.0))),
                      side: BorderSide(
                        color: Colors.blue,
                        width: 5,
                      )),
                ),
                child: const Text(
                  "Reset mon mot de passe",
                ),
              ),
            ),
            const SizedBox(height: 20.0),
            Padding(
              padding: const EdgeInsets.only(left: 110, right: 110),
              child: TextButton(
                
                style: TextButton.styleFrom(
                  foregroundColor:  Colors.white,
                  backgroundColor: Colors.cyan[400],
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular((100.0))),
                  ),
                ),
                  onPressed: (//Redirect toward the registering page
                      ) {
                    context.read<AuthBloc>().add(const AuthEventLoggedout());
                  },
                  child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.home),
                    SizedBox(width: 10),
                    Text("Page d'accueil")
                    ],
                  )
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Date invalide"),
          content: const Text("La date choisie doit être dans le futur."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Ferme la boîte de dialogue
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }
}
