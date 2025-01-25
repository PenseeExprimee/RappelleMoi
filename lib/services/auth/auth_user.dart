import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter/material.dart';


// This class defines what a user will be in our code.
// Ths class only exposes the attributes we need.
@immutable
class AuthUser {
  
  final String id;
  final String email;
  final bool isEmailVerified;

  const AuthUser({
    required this.id,
    required this.email,
    required this.isEmailVerified
  });

  //we need a fatory constructor, because this fonction will take a firebase user and return a AuthUser

  factory AuthUser.fromFirebase(User user) => AuthUser(
    id: user.uid, 
    email: user.email!, //the email string is read from the firebase user
    isEmailVerified: user.emailVerified
  );
  
}