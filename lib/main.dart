import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rappellemoi/services/auth/auth_firebase_provider.dart';
import 'package:rappellemoi/services/bloc/auth_bloc.dart';
import 'package:rappellemoi/services/bloc/auth_event.dart';
import 'package:rappellemoi/services/bloc/auth_state.dart';
import 'package:rappellemoi/views/login_view.dart';
import 'package:rappellemoi/views/notification_view.dart';
import 'dart:developer' as devtools show log;

import 'package:rappellemoi/views/register_view.dart';
import 'package:rappellemoi/views/verification_email_view.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); //initialisation préalable du moteur flutter
  runApp( MaterialApp(
    title: 'Rappelle moi!',
    theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    home: BlocProvider<AuthBloc>( //we create the bloc right from the start
      create: (context) => AuthBloc(FirebaseAuthProvider()),
      child: const HomePage(),
      )
  ));
}


class HomePage extends StatelessWidget {
  const HomePage({super.key});


  @override
  Widget build(BuildContext context) {

    //to initialize the provider
    devtools.log("Came here :D");
    context.read<AuthBloc>().add(const AuthEventInitialize());

    return BlocConsumer<AuthBloc,AuthState>(
      listener: (context, state){
        //not implemented yet
      },
      builder: (context,state){
        if(state is AuthStateLoggedOut){
          return const LoginView();
        }
        else if (state is AuthStateLoggedIn){
          return const NotificationPage();
        } else if (state is AuthStateRegistering){
          return const RegisterView();
        } 
        else if (state is AuthStateNeedsEmailVerification){
          return const VerifEmail();
        }
        else {
          return const Scaffold(
            body: CircularProgressIndicator()
          );
        }
      }
    );
  }
}

