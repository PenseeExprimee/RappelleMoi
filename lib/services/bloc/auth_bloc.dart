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
        emit(const AuthStateLoggedOut(isLoading: false, exception: null));

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
        else {
          emit(AuthStateLoggedIn(isLoading: false, user: user));
        }

      } on InvalidEmailAuthException { //episode 2
        
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

    on <AuthEventForgottenPassword>((event,emit) async{
      try{
        devtools.log('Event forgotten password triggered');
        emit(const AuthStateForgottenPassword(isLoading: false, exception: null));

      } on ForgottenPasswordException catch(e){
        devtools.log("Forgotten password exception occured: $e");
      }
    });

    on <AuthEventSendResetPasswordLink>((event,emit) async {
      devtools.log('Send the reset password link');
      try {
        await provider.sendResetEmail(email: event.email);
        devtools.log('Do i see this one?');
        emit(const AuthStateForgottenPassword(isLoading: false, exception: null));
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
      } on GenericAuthException catch(e){
        devtools.log('An error occured while deleting the account: $e');
      }
    });
  }

  
  
}