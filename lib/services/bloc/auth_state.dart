

import 'package:flutter/material.dart';
import 'package:rappellemoi/services/auth/auth_user.dart';

@immutable
abstract class AuthState {
  final bool isLoading;
  final String? loadingText;

  const AuthState({required this.isLoading, this.loadingText = 'Please wait a moment'});
}

class AuthStateUninitialized extends AuthState {
  const AuthStateUninitialized({required super.isLoading});
}

class AuthStateLoggedIn extends AuthState{
  final AuthUser user;
  // ignore: use_super_parameters
  const AuthStateLoggedIn({ required isLoading, required this.user}): super(isLoading: isLoading);
}

class AuthStateLoggedOut extends AuthState {
  // ignore: use_super_parameters
  const AuthStateLoggedOut({required isLoading, loadingText}):super(isLoading: isLoading, loadingText: loadingText);
}

class AuthStateRegistering extends AuthState {
  // ignore: use_super_parameters
  const AuthStateRegistering({required isLoading}) : super(isLoading: isLoading);
}

class AuthStateNeedsEmailVerification extends AuthState {
  // ignore: use_super_parameters
  const AuthStateNeedsEmailVerification({required isLoading}) : super(isLoading: isLoading);
}