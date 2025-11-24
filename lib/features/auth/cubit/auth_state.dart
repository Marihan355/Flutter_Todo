abstract class AuthState {}

//initial
class AuthInitial extends AuthState {}

//loading
class AuthLoading extends AuthState {}

//success
class AuthSuccess extends AuthState {
  final String uid;
  AuthSuccess(this.uid);
}

//failure
class AuthFailure extends AuthState {
  final String message;
  AuthFailure(this.message);
}

class AuthLoggedOut extends AuthState {}