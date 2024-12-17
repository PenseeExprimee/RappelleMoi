// import 'package:rappellemoi/services/auth/auth_firebase_provider.dart';
// import 'package:rappellemoi/services/auth/auth_provider.dart';
// import 'package:rappellemoi/services/auth/auth_user.dart';

// class AuthServices implements AuthProvider{
//   final AuthProvider provider;
//   AuthServices(this.provider);

//   //The firebase factory constructor initializes my service with a firebase provider.
//   factory AuthServices.firebase() => AuthServices(FirebaseAuthProvider());
  
//   @override
//   Future<AuthUser> createUser({required String email, required String password}) async {
//     return provider.createUser(email: email, password: password);
//   }

//   @override
//   AuthUser? get currentUser => provider.currentUser;

//   @override
//   Future<void> initialize() => provider.initialize();

//   @override
//   Future<AuthUser> login({required email, required password}) => provider.login(email: email, password: password);

//   @override
//   Future<void> logout() => provider.logout();

//   @override
//   Future<void> sendEmailVerification() => provider.sendEmailVerification();

//   @override
//   Future<void> sendResetEmail({required String email}) => provider.sendResetEmail(email: email);

// }