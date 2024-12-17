import 'package:bloc/bloc.dart';
import 'package:rappellemoi/services/auth/auth_exceptions.dart';
import 'package:rappellemoi/services/auth/auth_provider.dart';
import 'package:rappellemoi/services/bloc/auth_event.dart';
import 'package:rappellemoi/services/bloc/auth_state.dart';
import 'dart:developer' as devtools show log;

class AuthBloc extends Bloc<AuthEvent, AuthState>{
  AuthBloc(AuthProvider provider): super(const AuthStateUninitialized(isLoading: true)){
    
    on <AuthEventInitialize>((event, emit) async {
      devtools.log("Auth event initialize triggered");
      await provider.initialize();

      //Update the state

      final user = provider.currentUser;

      if(user == null){ //there is no user logged in
        emit(const AuthStateLoggedOut(isLoading: false));

      } else{
        emit(AuthStateLoggedIn(
          isLoading: false,
          user: user,
          )
        );
      }
    });
    
    on <AuthEventLogin>((event,emit) async{
      devtools.log("Auth event login triggered");
      //initial state that we emit when the event arrives: we are logged out
      emit(
        const AuthStateLoggedOut(
          isLoading: true
        )
      );
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
        else {
          emit(AuthStateLoggedIn(isLoading: false, user: user));
        }

      } on Exception catch (e) { //for some reason the login failed
        emit(const AuthStateLoggedOut(isLoading: false));
        devtools.log("An error occured during the login process: $e");

      }

    });

    on <AuthEventLoggedout>((event,emit) async{
      devtools.log("Auth event logged out triggered");
      emit(const AuthStateLoggedOut(isLoading: true));
      try {
        await provider.logout();
        emit(const AuthStateLoggedOut(isLoading: false));
      } catch (e) {
        devtools.log("Auth event logged out: an error occured during the process: $e");
      }
    });
  
    on <AuthEventShouldRegister>((event, emit) {
      emit(const AuthStateRegistering(isLoading: false));
      },
    );

    on <AuthEventRegistering>((event, emit) async {
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
        
      } on WeakPasswordAuthException catch (e){
        devtools.log("In auth event registering, weak password: $e");
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
        
      }
    },);
  }

  
}