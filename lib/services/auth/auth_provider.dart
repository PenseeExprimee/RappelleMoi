import 'package:rappellemoi/services/auth/auth_user.dart';

//This class defines the functions that will be used
// for all providers. (firebase or others)

abstract class AuthProvider{

  Future <void> initialize();

  AuthUser? get currentUser;

  Future <AuthUser> createUser({
    required  String email,
    required String password
  });

  Future<AuthUser>login({
    required email,
    required password,
  });

  Future <void> logout();

  Future <void> sendEmailVerification();

  Future <void> sendResetEmail({
    required String email,
  });

  Future <void> deleteMyAccount({required Map<String, String> credentials});

}