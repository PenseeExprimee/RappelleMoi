import 'package:firebase_core/firebase_core.dart';
import 'package:rappellemoi/firebase_options.dart';
import 'package:rappellemoi/services/auth/auth_exceptions.dart';
import 'package:rappellemoi/services/auth/auth_provider.dart';
import 'package:rappellemoi/services/auth/auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth, FirebaseAuthException;
import 'dart:developer' as devtools show log;

class FirebaseAuthProvider implements AuthProvider {
  
  @override
  AuthUser? get currentUser { 
    final user = FirebaseAuth.instance.currentUser;

    if(user != null){
      return AuthUser.fromFirebase(user);
    } else{
      return null;
    }
  }

  @override
  Future<AuthUser> createUser({
    required String email,
    required String password
    }) async {
      try {
        // create a new user
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password
        );
        // check the value of the curent user with the getteur
        final user = currentUser;

        if(user !=null){
          return user;
        } else {
          throw UserNotLoggedInAuthException();
        }
      } on FirebaseAuthException catch (e){
          if(e.code == 'invalid-email'){
            devtools.log("Invalid-email");
            throw InvalidEmailAuthException();
          } 
          else if(e.code == 'weak-password'){
            devtools.log("The password is too weak");
            throw WeakPasswordAuthException();
          }
          else if (e.code == "email-already-in-use"){
            devtools.log("The email is already in user");
            throw EmailAlreadyInUseAuthException();
          }
          else{
            devtools.log(e.code);
            throw GenericAuthException();
          }
      } catch (_) {
          throw GenericAuthException();
      }
      
  }

  @override
  Future<void> initialize() async {
    await Firebase.initializeApp(
                    options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Future<AuthUser> login({required email, required password}) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password
      );

      final user = currentUser;
      if(user!= null){
        return user; //my getter already transforms the Firebase user into a Auth user
      } else {
        devtools.log("For some reason the user is null");
        throw GenericAuthException();
      }
    } on FirebaseAuthException catch (e) {
      if(e.code == 'invalid-credential'){
        throw InvalidCredentialsAuthException();
      } else if(e.code == 'invalid-email'){
        throw InvalidEmailAuthException();
      }
      else {
        devtools.log("An other firebase exception occured: $e");
        throw GenericAuthException();
      }
      
    } on Exception catch (e){
      devtools.log("No generic firebase auth exception but something happened: $e");
      throw GenericAuthException();
    }
  }

  @override
  Future<void> logout() async{
    //check that the user is logged in before trying to log out
    final user = FirebaseAuth.instance.currentUser;
    if(user != null){
      await FirebaseAuth.instance.signOut();
    } else {
      throw UserNotLoggedInAuthException();
    }
    
  }

  @override
  Future<void> sendEmailVerification() async {
    // get the current user. Here, I can't use my getter because I will need a method that my AuthUser does not have.
    final user = FirebaseAuth.instance.currentUser;
    // This function should only be responsible of sending the verification email,
    // not the logic "does this user need to receive the verification email". Because the user should not end on that page if he does not need to verify its email.
    
    if(user != null){
      user.sendEmailVerification();
      devtools.log("I sent the verification email;");
    } else {
      throw UserNotLoggedInAuthException();
    }
  }

  @override
  Future<void> sendResetEmail({
    required String email
  }) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseException catch (e) {
      devtools.log("Send reset email, error occured: ${e.code}");
      throw GenericAuthException();
      
    }
  }

}