

import 'package:rappellemoi/services/auth/auth_firebase_provider.dart';
import 'package:rappellemoi/services/auth/auth_provider.dart';
import 'package:rappellemoi/services/auth/auth_user.dart';

class AuthService extends AuthProvider{

  AuthProvider provider;

 //normal constructor
  AuthService({
    required this.provider
  });

  //factory constructor
  factory AuthService.firebase() => AuthService(provider: FirebaseAuthProvider());

  @override
  Future<AuthUser> createUser({required String email, required String password}) {
    return provider.createUser(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => provider.currentUser;

  @override
  Future<void> initialize() {
    return provider.initialize();
  }

  @override
  Future<AuthUser> login({required email, required password}) {
    return provider.login(email: email, password: password);
  }

  @override
  Future<void> logout() {
    return provider.logout();
  }

  @override
  Future<void> sendEmailVerification() {
    return provider.sendEmailVerification();
  }

  @override
  Future<void> sendResetEmail({required String email}) {
    return provider.sendResetEmail(email: email);
  }

  
}