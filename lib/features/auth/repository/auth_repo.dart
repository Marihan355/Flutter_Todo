import 'package:firebase_auth/firebase_auth.dart';

import '../../todos/repository/todo_sync_repository.dart';

class AuthRepo {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TodoSyncRepository todoSyncRepository; //i'm using it to clear local todos on logout

  // I can contact todo repo now when i'm in auth
  AuthRepo(this.todoSyncRepository);

  Future<User?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    return result.user;
  }

  Future<User?> register(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
        email: email, password: password);
    return result.user;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  User? currentUser() => _auth.currentUser;
}