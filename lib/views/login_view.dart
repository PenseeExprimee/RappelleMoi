import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rappellemoi/services/bloc/auth_bloc.dart';
import 'package:rappellemoi/services/bloc/auth_event.dart';
import 'dart:developer' as devtools show log;

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
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
        title: const Text("Rappelle moi : LOGIN"),
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
                image:  AssetImage('assets/images/logo.jpg'),
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
                    hintText: "Enter your username...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 2
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
          TextButton(
            onPressed:() {
              devtools.log("The login button has been pressed");
              context.read<AuthBloc>().add(AuthEventLogin(
                email: _email.text,
                password: _password.text
                )
              );
              //Clear the fields after the login button has been pressed
              _email.clear();
              _password.clear();
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
            child: const Text( "Login",),
          ),
            
          const SizedBox(
            height: 50.0
          ),
          TextButton(
            onPressed:(  //Redirect toward the registering page
            ) {
                context.read<AuthBloc>().add(const AuthEventShouldRegister());
            },
            child: const Text('Pas encore de compte? Inscrivez vous en cliquant ici :D')
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