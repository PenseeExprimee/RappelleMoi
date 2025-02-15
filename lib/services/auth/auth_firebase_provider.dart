import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rappellemoi/firebase_options.dart';
import 'package:rappellemoi/services/auth/auth_exceptions.dart';
import 'package:rappellemoi/services/auth/auth_provider.dart';
import 'package:rappellemoi/services/auth/auth_user.dart';
import 'package:firebase_auth/firebase_auth.dart' show AuthCredential, EmailAuthProvider, FirebaseAuth, FirebaseAuthException;
import 'dart:developer' as devtools show log;


// This class gathers all the functions that will be used in our app
// when the chosen provider is firebase.


class FirebaseAuthProvider implements AuthProvider {
  
  @override
  AuthUser? get currentUser { 
    final user = FirebaseAuth.instance.currentUser;

    if(user != null){
      return AuthUser.fromFirebase(user);
    }
      return null;
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
        } 
        
        throw UserNotLoggedInAuthException();
      
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
            devtools.log("The email is already in use");
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
      } 
      devtools.log("For some reason the user is null");
      throw GenericAuthException();
      
    } on FirebaseAuthException catch (e) {
      devtools.log(e.code);
      if(e.code == 'invalid-credential'){
        throw InvalidCredentialsAuthException();
      } else if(e.code == 'invalid-email'){
        throw InvalidEmailAuthException();
      }
      if(e.code == 'wrong-password'){ //episode 2
        throw InvalidCredentialsAuthException();
      }
      else {
        devtools.log(e.code);
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
    try{
    // get the current user. Here, I can't use my getter because I will need a method that my AuthUser does not have.
    final user = FirebaseAuth.instance.currentUser;
    // This function should only be responsible of sending the verification email,
    // not the logic "does this user need to receive the verification email". Because the user should not end on that page if he does not need to verify its email.
    
    if(user != null){
      await user.sendEmailVerification();
      devtools.log("I sent the verification email;");
    } else {
      throw UserNotLoggedInAuthException();
    }
    } on FirebaseAuthException catch (e) {
        switch (e.code) {
          case 'too-many-requests':
            throw TooManyRequestAuthException();
          case 'user-token-expired':
            throw UserTokenExpiredAuthException();
          case 'user-disabled':
            throw UserDisabledAuthException();
          case 'network-request-failed':
            throw NetworkRequestFailed();
          default:
            throw GenericAuthException();
        }
  } catch (e){
    devtools.log("An exception occcured: $e");
  }
  }

  @override
  Future<void> sendResetEmail({
    required String email
  }) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      devtools.log('Just sent the password reset email');
    } on FirebaseException catch (e) {
      if(e.code == "missing-email"){
        devtools.log('Missing email');
          throw FailResetPasswordException();
        }
      else if (e.code== "invalid-email"){
        devtools.log("Please enter a valid email address");
        throw InvalidEmailForResetException();
      }
      else{
        devtools.log("This is the error: ${e.code}");
        throw GenericAuthException();
      }
      
    } catch(e){
      devtools.log("Something else happened during the password reset");
    }
  }
  
  @override
  Future<void> deleteMyAccount({required credentials}) async {

    try{
    
      //get the current user
      final currentUser = FirebaseAuth.instance.currentUser;
      //check if the user is not null
      if(currentUser == null){
        throw UserNotLoggedInAuthException();
      }
      //Check if the credentials passed are not null
      if(credentials["email"] != null && credentials["password"] !=null) {
        final email = credentials["email"];
        final password = credentials["password"];
        
        //Reauthenticate
        AuthCredential nonNullCredentials = EmailAuthProvider.credential(email: email! , password: password!);
        await currentUser.reauthenticateWithCredential(nonNullCredentials);
        devtools.log("Reauthentication done");
        devtools.log("This is the current user uid: ${currentUser.uid}");
        
        //Get the notes of the user
        final QuerySnapshot allCurrentUserNotes = await FirebaseFirestore.instance.collection('notes').where("user_id", isEqualTo: currentUser.uid).get();
        devtools.log("All current user notes: ${allCurrentUserNotes.toString()}");
        for (QueryDocumentSnapshot doc in allCurrentUserNotes.docs) {
          devtools.log("Docs to be deleted: ${doc.toString()}");
          await doc.reference.delete();
        }
        devtools.log("All notes of the user deleted");
        //Cancel all scheduled notification
        await FlutterLocalNotificationsPlugin().cancelAll();

        //Delete the user
        await currentUser.delete();
      }
      
    
    } on FirebaseException catch (e){
      if(e.code == "invalid-email" || e.code == "wrong-password"){
        devtools.log("Invalid credentials");
        throw InvalidCredentialsAuthException();
      }
    } catch(e){
      devtools.log('Another error appeared: $e');
      throw CouldNotDeleteTheAccountException();
    }
    //get the notes associated to the user and delete them
    //delete the user account
  }

}