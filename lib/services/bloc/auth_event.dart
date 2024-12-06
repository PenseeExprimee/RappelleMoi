import 'package:flutter/material.dart';

@immutable
abstract class AuthEvent {
  const AuthEvent();
}


class AuthEventLogin extends AuthEvent {
  final String email;
  final String password;
  const AuthEventLogin({required this.email, required this.password});
}

class AuthEventLoggedout extends AuthEvent{
  const AuthEventLoggedout();
}

class AuthEventInitialize extends AuthEvent {
  const AuthEventInitialize();
}

class AuthEventRegistering extends AuthEvent {
  final String email;
  final String password;
  const AuthEventRegistering({required this.email, required this.password});
}

class AuthEventShouldRegister extends AuthEvent {
  const AuthEventShouldRegister();
}