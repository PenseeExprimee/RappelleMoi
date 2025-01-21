import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:permission_handler/permission_handler.dart';
//import 'package:googleapis/keep/v1.dart';
import 'package:rappellemoi/constants/routes.dart';
import 'package:rappellemoi/firebase_options.dart';
import 'package:rappellemoi/helpers/loading/loading_screen.dart';
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
import 'package:timezone/data/latest.dart' as tz;
import 'dart:developer' as devtools show log;


final navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); //initialisation préalable du moteur flutter
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  //await FirebaseApi().initNotifications();
  tz.initializeTimeZones();
  await NotificationService.initNotification();
  await Permission.notification.isDenied.then((value){
    if(value){
      Permission.notification.request();
    }
  });
  
  
  
  
  
  
  //runApp(const MyApp());
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
    }
  ));
}


// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner:  false,
//       home: const MyHomePage(title: "Something is the title",),
//       navigatorKey: navigatorKey ,
//       routes: {
//         '/notification_screen': (context) => const NotificationPageTuotrial(),
//       },
//     );
//   }
// }


DateTime scheduleTime = DateTime.now();

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            DatePickerTxt(),
            ScheduleBtn(),
          ],
        ),
      ),
    );
  }
}

class DatePickerTxt extends StatefulWidget {
  const DatePickerTxt({
    super.key,
  });

  @override
  State<DatePickerTxt> createState() => _DatePickerTxtState();
}

class _DatePickerTxtState extends State<DatePickerTxt> {
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        DatePicker.showDateTimePicker(
          context,
          showTitleActions: true,
          onChanged: (date) => scheduleTime = date,
          onConfirm: (date) {},
        );
      },
      child: const Text(
        'Select Date Time',
        style: TextStyle(color: Colors.blue),
      ),
    );
  }
}

class ScheduleBtn extends StatelessWidget {
  const ScheduleBtn({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Text('Show notification'),
      onPressed: () {
        //debugPrint('Notification Scheduled for $scheduleTime');
        //NotificationService.showNotification(title: 'tilte', body: 'laura');
           NotificationService.scheduleNotification(
              title: 'Scheduled Notification',
              body: '$scheduleTime',
              scheduledNotificationDateTime: scheduleTime);
      },
    );
  }
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
          devtools.log('are we stuck here?');
          return const Scaffold(
            body: CircularProgressIndicator()
          );
        }
      }
    );
  }
}

