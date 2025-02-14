import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rappellemoi/constants/routes.dart';
import 'package:rappellemoi/firebase_options.dart';
import 'package:rappellemoi/helpers/loading/loading_screen.dart';
import 'package:rappellemoi/services/crud/notification.dart';
import 'package:rappellemoi/services/notification/notification_service.dart';
import 'package:rappellemoi/services/auth/auth_firebase_provider.dart';
import 'package:rappellemoi/services/bloc/auth_bloc.dart';
import 'package:rappellemoi/services/bloc/auth_event.dart';
import 'package:rappellemoi/services/bloc/auth_state.dart';
import 'package:rappellemoi/views/forgotten_password_view.dart';
import 'package:rappellemoi/views/login_view.dart';
import 'package:rappellemoi/views/notes/click_on_notification.dart';
import 'package:rappellemoi/views/notes/create_or_update_view.dart';
import 'package:rappellemoi/views/notes/notes_view.dart';
import 'package:rappellemoi/views/register_view.dart';
import 'package:rappellemoi/views/verification_email_view.dart';
import 'package:rappellemoi/views/view_my_profile.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'dart:developer' as devtools show log;


final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //initialization of flutter engine
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  tz.initializeTimeZones();
  await NotificationService.initNotification();
  await Permission.notification.isDenied.then((value){
    if(value){
      Permission.notification.request();
    }
  });
  runApp( MaterialApp(
    title: 'Rappelle moi!',
    navigatorKey: navigatorKey,
    theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    home: BlocProvider<AuthBloc>( //we create the bloc right from the start
      create: (context) => AuthBloc(FirebaseAuthProvider()),
      child: const HomePage(),
      ),
    routes: {
      createOrUpdateNotes: (context) => const CreateOrUpdateNotesView(),
      showNotificationRoute: (context) => const ClickOnNotificationView(),
      notesViewRoute: (context) => const NotesView(),
      forgottenPasswordRoute: (context) => const ForgottenPasswordView(),
      viewMyProfile: (context) => const MyProfileview(),
    }
  ));
}


class HomePage extends StatelessWidget {
  const HomePage({super.key});


  @override
  Widget build(BuildContext context) {

    //to initialize the provider
    context.read<AuthBloc>().add(const AuthEventInitialize());

    return BlocConsumer<AuthBloc,AuthState>(
      listener: (context, state){
        //responsible of displaying overlays
        if(state.isLoading){
          LoadingScreen().show( //call the factory constructor 
            context: context,
            text: state.loadingText ?? 'Please wait...'
          );
        } else {
          LoadingScreen().hide();
        }
      },
      //The app displays different view, depending on the state.
      builder: (context,state){
        if(state is AuthStateLoggedOut){
          return const LoginView();
        }
        else if (state is AuthStateLoggedIn){
          return const NotesView();
        } else if (state is AuthStateRegistering){
          return const RegisterView();
        } 
        else if (state is AuthStateNeedsEmailVerification){
          return const VerifEmail();
        }
        else if (state is AuthStateForgottenPassword){
          return const ForgottenPasswordView();
        }
        else {
          devtools.log("Are we stuck here?");
          return const Scaffold(
            
            body: CircularProgressIndicator()
          );
        }
      }
    );
  }
}

