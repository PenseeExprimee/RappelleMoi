import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rappellemoi/services/bloc/auth_bloc.dart';
import 'package:rappellemoi/services/bloc/auth_event.dart';
import 'dart:developer' as devtools show log;

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late final TextEditingController _email;
  late final TextEditingController _password;


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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Rappelle moi: Créer un compte"),
      ),
      body: ListView (
        children: [
          const SizedBox(
            height: 50
          ),
          Container(
            height: 75.0,
            width: 75.0,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image:  AssetImage('assets/images/register_view_login.jpg'),
                fit: BoxFit.contain
              )
            ),
          ),
          const SizedBox(
            height: 50
          ),
           Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  textAlign: TextAlign.center,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  enableSuggestions: false,
                  decoration: const InputDecoration(
                    hintText: "Enter your email address...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 20
                ),
                TextField(
                  textAlign: TextAlign.center,
                  enableSuggestions: false,
                  obscureText: true,
                  autocorrect: false,
                  controller: _password,
                  decoration: const InputDecoration(
                    hintText: 'Enter your password...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
              ]
            )
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextButton(
              onPressed:() {
                devtools.log("The register button has been pressed");
                context.read<AuthBloc>().add(AuthEventRegistering(
                    email: _email.text,
                    password: _password.text,
                  )
                );
                //clear the field after the button has been pressed
                _email.clear();
                _password.clear();
                
                //clean the text field
              },
              style: TextButton.styleFrom(
                foregroundColor:  Colors.white,
                backgroundColor: Colors.blue,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular((100.0))),
                  side: BorderSide(
                    color: Colors.blue,
                    width: 5,
                  )
                ),
              ),
              child: const Text( "Créer un compte",),
            ),
          ),
            
          const SizedBox(
            height: 50.0
          ),
          TextButton(
            onPressed:() { //return to the login view
              context.read<AuthBloc>().add(const AuthEventLoggedout());
            },
            child: const Text('Déjà un compte? Connectez vous en cliquant ici :D')
          ),
          TextButton(
            onPressed:() {},
            child: const Text('Mot de passe oublié')
          )
        ],
      ),
    );
  }
}