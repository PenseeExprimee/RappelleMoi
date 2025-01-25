

import 'package:rappellemoi/services/auth/auth_firebase_provider.dart';
import 'package:rappellemoi/services/auth/auth_provider.dart';
import 'package:rappellemoi/services/auth/auth_user.dart';

// The service adds a layer of abstraction between the UI and the provider.
// The complete stack is: UI -> Service -> AuthProvider -> Chosen Provider.
// In our case, the chosen provider is Firebase.
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
  
  @override
  Future<void> deleteMyAccount({required Map<String, String >credentials}) {
    return provider.deleteMyAccount(credentials: credentials);
  }

  
}