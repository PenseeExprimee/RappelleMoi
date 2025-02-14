import 'package:bloc/bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:rappellemoi/services/auth/auth_exceptions.dart';
import 'package:rappellemoi/services/auth/auth_provider.dart';
import 'package:rappellemoi/services/bloc/auth_event.dart';
import 'package:rappellemoi/services/bloc/auth_state.dart';
import 'package:rappellemoi/constants/text.dart';
import 'dart:developer' as devtools show log;

import 'package:rappellemoi/services/crud/notification.dart';
import 'package:rappellemoi/services/notification/notification_service.dart';

//This class defines all the events that will trigger our bloc.
// An event triggers the bloc -> the state changes -> the UI changes accordingly

class AuthBloc extends Bloc<AuthEvent, AuthState>{
  AuthBloc(AuthProvider provider): super(const AuthStateUninitialized(isLoading: true)){
    
    on <AuthEventInitialize>((event, emit) async {
      devtools.log("Auth event initialize triggered");
      await provider.initialize();

      //Update the state

      final user = provider.currentUser;

      if(user == null){ //there is no user logged in
        emit(const AuthStateLoggedOut(isLoading: false, exception: null));

      } else{ // a user is logged in
        emit(AuthStateLoggedIn(
          isLoading: false,
          user: user,
          exception: null,
          )
        );
      }
    });
    
    on <AuthEventLogin>((event,emit) async{
      devtools.log("Auth event login triggered");
      
      //initial state that we emit when the event arrives: we are logged out 
      emit(
        const AuthStateLoggedOut(
          isLoading: true,
          loadingText: "Login: please wait...",
          exception:null
          )
      );
      await Future.delayed(const Duration(seconds: 1)); //to have time to see the overlay
      //implement the logic to atually login
      // get the user credential from the event
      final email = event.email;
      final password = event.password;

      try{
        //use the function of your provider to actually login
        final user = await provider.login(email: email,password: password);

        //Check if the user needs to verify its email
        if(!user.isEmailVerified){
          devtools.log("Inside the login event: The email of the user is not verified");
          emit(const AuthStateNeedsEmailVerification(isLoading: false)); //the email has already been sent at the creation of the account. The user will be able to re-send the email if he wants to.
        }
        else { //the email of the user is already verified
          

          //reschedule all notifications
          //Start by getting the notes in the local database
          final _localNotesService = LocalNotesService();
          //Query all notifications
          final allNotification = await _localNotesService.getAllNotifications();
          final allNotes = await _localNotesService.getAllNotes();
          
          allNotification.forEach((element) async {
            final notificationId = element["id"] as int;
            final noteId = element["note_id"];

            //Look for the right note
            var note = DatabaseNote(id: 0, cloudNoteId: 'init', userId: 'initUserId', text: 'initTextId', date: 'InitDate');
            allNotes.forEach((databaseNote){
              if(databaseNote.cloudNoteId == noteId){
                note = databaseNote;
              }
            });
            devtools.log("This is the date login: ${note.date}");
            DateTime now = DateTime.now();
            DateTime parsedDate = DateTime.parse(note.date.trim());
            if(parsedDate.isBefore(now)){
              await NotificationService.showNotification(
                  id: notificationId,
                  title: 'Rappelle moi :D',
                  body: note.text,
              );
      
            }
            else {
              NotificationService.scheduleNotification(
                id: notificationId,
                title: 'Rappelle moi :D',
                body: note.text,
                scheduledNotificationDateTime: parsedDate,
                payLoad: note.cloudNoteId,
                );
            }
          });
          emit(AuthStateLoggedIn(isLoading: false, user: user, exception: null));
        }

      } on InvalidEmailAuthException { 
        
        emit(const AuthStateLoggedOut(isLoading: true, exception:null,loadingText: "The email is not valid."));
        await Future.delayed(const Duration(seconds: 2));
        emit(const AuthStateLoggedOut(isLoading: false, exception: null));

      } on InvalidCredentialsAuthException {

        emit(const AuthStateLoggedOut(isLoading: true,exception: null, loadingText: "Invalid credentials."));
        await Future.delayed(const Duration(seconds: 2));
        emit(const AuthStateLoggedOut(isLoading: false, exception: null));

      } on Exception catch (e) { //for some reason the login failed
        
        emit(AuthStateLoggedOut(isLoading: true,exception: null, loadingText: "An error occured during the login process: $e"));
        await Future.delayed(const Duration(seconds: 2));
        emit(const AuthStateLoggedOut(isLoading: false, exception: null));
        devtools.log("An error occured during the login process: $e");

      }

    });

    on <AuthEventLoggedout>((event,emit) async{
      devtools.log("Auth event logged out triggered");
      emit(const AuthStateLoggedOut(
        isLoading: true, 
        loadingText: "Logging out...",
        exception: null
        )
      );
      try {
        await provider.logout();
        FlutterLocalNotificationsPlugin().cancelAll();
        emit(const AuthStateLoggedOut(
          isLoading: false,
          exception: null,
          )
        );
      } on UserNotLoggedInAuthException { //happens when we click on the "pas encore de compte?"
        emit(const AuthStateLoggedOut(isLoading: false, exception: null));
      } catch (e) {
        devtools.log("Auth event logged out: an error occured during the process: $e");
      }
    });
  
    on <AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(isLoading: false));
      },
    );

    on <AuthEventRegistering>((event, emit) async {
      emit(const AuthStateLoggedOut(isLoading: true, exception: null,loadingText: "Creating your account..."));
      try {
        devtools.log("Auth event registering triggered");
        final email = event.email;
        final password = event.password;
        await provider.createUser(
          email: email,
          password: password
        );
        //send the verification email
        await provider.sendEmailVerification();

        //emit the state of email verification
        emit(const AuthStateNeedsEmailVerification(isLoading: false));

      } on InvalidEmailAuthException catch (e) {

        devtools.log("In auth event registering, invalid email $e");
        emit(AuthStateLoggedOut(isLoading: false, exception: e));

      } on WeakPasswordAuthException catch (e){

        devtools.log("In auth event registering, weak password: $e");
        emit(AuthStateLoggedOut(isLoading: false, exception: e));

      } on EmailAlreadyInUseAuthException catch(e){
        
        devtools.log("The email is already in use :c :$e");
        emit(AuthStateLoggedOut(isLoading: false, exception: e));
      }
    });
  
    on <AuthEventShouldVerifyEmail>((event, emit) async {
      try {
        devtools.log("Re send verification email button triggered");
        //Actually send the email
        await provider.sendEmailVerification();

        //send 
      } on UserNotLoggedInAuthException catch (e) {
        devtools.log("The verification email could not be used because there is no current user: $e");
        
      } on TooManyRequestAuthException catch(e) {
        devtools.log("The user did too many requests of verification email");
        emit(AuthStateNeedsEmailVerification(isLoading: false,exception: e));
      } catch(e){
        devtools.log("An error occured: $e");
      }
    },);

    on <AuthEventForgottenPassword>((event,emit) async{
      try{
        devtools.log('Event forgotten password triggered');
        emit(const AuthStateForgottenPassword(isLoading: false, exception: null));

      } on ForgottenPasswordException catch(e){
        devtools.log("Could not change the page: $e");
      }
    });

    on <AuthEventSendResetPasswordLink>((event,emit) async {
      devtools.log('Send the reset password link');
      try {
        await provider.sendResetEmail(email: event.email);
        devtools.log('Do i see this one?');
        emit(const AuthStateForgottenPassword(isLoading: false, exception: null, message: compteExitant));
        devtools.log('Auth state emitted');
      
      } on FailResetPasswordException catch (e){
        
        devtools.log('The password reset link could not be sent: because the email field was empty: $e');
        emit(AuthStateForgottenPassword(isLoading: false, exception: e));

      } on InvalidEmailForResetException catch(e){
        devtools.log("The user should enter a valid email address: $e");
        emit(AuthStateForgottenPassword(isLoading: false, exception: e));
      } 
    });

    on <AuthEventDeleteMyAccount>((event, emit) async {
      try {

        await provider.deleteMyAccount(credentials: event.credentials);
        emit(const AuthStateLoggedOut(isLoading: false, exception: null));

      } on CouldNotDeleteTheAccountException catch (e) {
        devtools.log("An error occured while trying to delete the account: $e");
        //grab the currrent user
        final user = provider.currentUser;
        emit(AuthStateLoggedIn(isLoading: false, user: user!, exception: e ));
      
      } on InvalidCredentialsAuthException catch (e){
        devtools.log('Credentials not passed or wrong: $e');
        //grab the currrent user
        final user = provider.currentUser;
        emit(AuthStateLoggedIn(isLoading: false, user: user!, exception: e ));
      }
    });
  }

  
  
}