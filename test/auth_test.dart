import 'package:flutter_test/flutter_test.dart';
import 'package:rappellemoi/services/auth/auth_exceptions.dart';
import 'package:rappellemoi/services/auth/auth_provider.dart';
import 'package:rappellemoi/services/auth/auth_user.dart';


void main(){
  group('Mock Authentication', (){
    final provider = MockProvider();

    test('The provider should not be initialized at start', (){
      expect(provider._isInitialized, false);
    });

    test('Can not logout if the not login', (){
      expect(
        provider.logout(), 
        throwsA(const TypeMatcher<NotInitializedException>())
      );
    });

    test('Should be able to be initialized',() async {
      await provider.initialize();
      expect(
        provider._isInitialized,true
      );

    });

    test('User should be null after initialization', () async {
      expect(provider._user, null);
    });

    test('Create user function should delegate to login function', () async {
        final badEmailUser = provider.createUser(
        email: 'foo@bar.com',
        password: 'anypassword',
      );

      expect(badEmailUser,
          throwsA(const TypeMatcher<InvalidEmailAuthException>()));

      final badPasswordUser = provider.createUser(
        email: 'someone@bar.com',
        password: 'foobar',
      );
      expect(badPasswordUser,
          throwsA(const TypeMatcher<InvalidCredentialsAuthException>()));

      final user = await provider.createUser(
        email: 'foo',
        password: 'bar',
      );
      expect(provider.currentUser, user);
      expect(user.isEmailVerified, false);
    });

    test('Logged in user should be able to get verified', () {
      provider.sendEmailVerification();
      final user = provider.currentUser;
      expect(user, isNotNull);
      expect(user!.isEmailVerified, true);
    });

    test('Should be able to log out and log in again', () async {
      await provider.logout();
      await provider.login(
        email: 'email',
        password: 'password',
      );
      final user = provider.currentUser;
      expect(user, isNotNull);
    });


  });
}
class MockProvider implements AuthProvider {

  AuthUser? _user;
  var _isInitialized = false;
  bool get isInitialized => _isInitialized;

  @override
  Future<AuthUser> createUser({required String email, required String password}) async {
    
    //check the initialization status of the provider
    if(_isInitialized == false)throw NotInitializedException();

    //create a delay to mimick the creation of the user
    await Future.delayed(const Duration(seconds: 3));

    //call the login function
    return login(email: email, password: password);
  }

  @override
  AuthUser? get currentUser => _user;

  @override
  Future<void> initialize() async {

    //Create a delay to mimick the initialization process
    await Future.delayed(const Duration(seconds: 3));

    //pass the initialization boolean to true
    _isInitialized = true;

  }

  @override
  Future<AuthUser> login({required email, required password}) {

    //check the initialization status
    if(_isInitialized == false) throw NotInitializedException();

    //simulate exception when entering the wrong credentials (email or password)
    if(email == "foo@bar.com") throw InvalidEmailAuthException();
    if(password == "foobar") throw InvalidCredentialsAuthException();

    //create a user with the AuthUser constructor . The email of this user is not verified, and then initialize _user
    const user = AuthUser(
      id: "my_id", 
      email: 'foo@bar.com', 
      isEmailVerified: false
    );
    _user = user;
    //return a furture value equal to user
    return Future.value(user);

  }

  @override
  Future<void> logout() async {
    //check the initialization status
    if(_isInitialized == false) throw NotInitializedException();

    //check that the user is not null
    if(_user == null) throw UserNotLoggedInAuthException();

    //Make the user equal to null to simulate a logout
    await Future.delayed(const Duration(seconds: 3));
    _user = null;
  }

  @override
  Future<void> sendEmailVerification() async {
    
    //Check the initialization status
    if(_isInitialized == false) throw NotInitializedException();

    //Check if there is a current user in _user
    if(_user == null) throw UserNotLoggedInAuthException();

    //Create a new user with verification status is true and update _user
    const newUser = AuthUser(
      id: "my_new_id",
      email: 'foo2@bar.com', 
      isEmailVerified: true
    );

    _user = newUser;


  }

  @override
  Future<void> sendResetEmail({required String email}) async{
    
    //check the initialization status
    if(_isInitialized == false) throw NotInitializedException();

    //throw an error if the email is incorrect
    throw UnimplementedError();
  }

}

class NotInitializedException implements Exception {}