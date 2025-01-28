import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rappellemoi/constants/routes.dart';
import 'package:rappellemoi/services/auth/auth_exceptions.dart';
import 'package:rappellemoi/services/bloc/auth_bloc.dart';
import 'package:rappellemoi/services/bloc/auth_event.dart';
import 'dart:developer' as devtools show log;

import 'package:rappellemoi/services/bloc/auth_state.dart';
import 'package:rappellemoi/utilities/dialogs/error_dialog.dart';

// This class handles the login page

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;
  bool passwordVisibility = true;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();

    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();

    super.dispose();
  }
  
  void _togglePasswordVisibility(){
    setState(() {
      passwordVisibility = !passwordVisibility;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState> (
      listener: (context, state) async {
        if(state is AuthStateLoggedOut){
          if(state.exception is FailResetPasswordException){
            await showErrorDialog(context, "Le changement de mot de passe n'a pas pu aboutir.");
          }
          else if(state.exception is EmailAlreadyInUseAuthException){
            await showErrorDialog(context, "Il existe déjà un compte avec cette adresse mail.");

          }
          else if (state.exception is InvalidEmailAuthException){
            await showErrorDialog(context, "L'email est non valide.");
          }
          else if (state.exception is WeakPasswordAuthException){
            await showErrorDialog(context, "Le mot de passe est trop faible.");
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("CONNEXION"),
        ),
        body: ListView(
          children: [
            const SizedBox(height: 50),
            Container(
              height: 75.0,
              width: 75.0,
              decoration: const BoxDecoration(
                  image: DecorationImage(
                      image: AssetImage('assets/images/logo.jpg'),
                      fit: BoxFit.contain)),
            ),
            const SizedBox(height: 50),
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
                      hintText: "Entrez votre adresse mail...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    textAlign: TextAlign.center,
                    enableSuggestions: false,
                    obscureText: passwordVisibility,
                    autocorrect: false,
                    controller: _password,
                    decoration: InputDecoration(
                      hintText: 'Entrez votre mot de passe...',
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          passwordVisibility ? Icons.visibility : Icons.visibility_off
                        ),
                        onPressed: _togglePasswordVisibility,
                      )
                    ),
                  ),
                ])),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextButton(
                onPressed: () {
                  devtools.log("The login button has been pressed");
                  context.read<AuthBloc>().add(AuthEventLogin(
                      email: _email.text, password: _password.text));
                  //Clear the fields after the login button has been pressed
                  _email.clear();
                  _password.clear();
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
                  "Connexion",
                ),
              ),
            ),
            const SizedBox(height: 50.0),
            TextButton(
                onPressed: (//Redirect toward the registering page
                    ) {
                  context.read<AuthBloc>().add(const AuthEventShouldRegister());
                },
                child: const Text(
                    'Pas encore de compte? Inscrivez vous en cliquant ici :D')),
            TextButton(
                onPressed: () {
                  devtools.log('The user clicked on forgotten password');
                  //Event Forgotten password
                  context
                      .read<AuthBloc>()
                      .add(AuthEventForgottenPassword(email: _email.text));
                  devtools.log('Password sent, check your email');
                },
                child: const Text('Mot de passe oublié'))
          ],
        ),
      ),
    );
  }
}
