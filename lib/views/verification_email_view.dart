import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rappellemoi/constants/text.dart';
import 'package:rappellemoi/services/auth/auth_exceptions.dart';
import 'package:rappellemoi/services/bloc/auth_bloc.dart';
import 'package:rappellemoi/services/bloc/auth_event.dart';
import 'package:rappellemoi/services/bloc/auth_state.dart';
import 'package:rappellemoi/utilities/dialogs/error_dialog.dart';

class VerifEmail extends StatelessWidget {
  const VerifEmail({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if(state is AuthStateNeedsEmailVerification){
          if(state.exception is TooManyRequestAuthException){
            showErrorDialog(context, tooManyRequests);
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Vérification d'email."),
        ),
        body: Column(
          children: [
            const SizedBox(height: 50),
            Container(
              height: 120.0,
              width: 120.0,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/email_open.jpg'),
                      fit: BoxFit.contain)),
            ),
            const SizedBox(height: 50),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                  "Nous vous avons envoyé un e-mail de vérification. Veuillez cliquer sur le lien contenu dans cet e-mail pour confirmer votre compte.Si vous ne l’avez pas reçu, cliquez sur le bouton ci-dessous pour le renvoyer"),
            ),
            const SizedBox(height: 50),
            TextButton(
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
                onPressed: () {
                  //send an event to signify that the user should verify his email
                  context
                      .read<AuthBloc>()
                      .add(const AuthEventShouldVerifyEmail());
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.mail),
                    SizedBox(width: 10),
                    Text('Renvoyer le mail')
                  ],
                )),
            const SizedBox(height: 10),
            TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.cyan[400],
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular((100.0))),
                  ),
                ),
                onPressed: () {
                  //send an event to signify that the user should verify his email
                  context.read<AuthBloc>().add(const AuthEventLoggedout());
                },
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.home),
                    SizedBox(width: 10),
                    Text("Page d'accueil")
                  ],
                ))
          ],
        ),
      ),
    );
  }
}
