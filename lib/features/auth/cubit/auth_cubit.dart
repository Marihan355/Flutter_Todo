import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
//import '../../todos/repository/todo_local_repository.dart';
import '../../todos/repository/todo_local_repository.dart';
import '../../todos/repository/todo_sync_repository.dart';
import '../repository/auth_repo.dart';
import 'auth_state.dart';
import '../../todos/repository/todo_sync_repository.dart';
import '../../todos/repository/todo_remote_repository.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepo repo;

  AuthCubit(this.repo) : super(AuthInitial());

  //login
  Future<void> login(String email, String password) async {
    try {
      emit(AuthLoading());

      // Login with FirebaseAuth through repo
      final user = await repo.login(email, password);

      final uid = user!.uid;
      await repo.todoSyncRepository.local.clearAllTodos();
      // Pull todos from Firestore
      await repo.todoSyncRepository.pullFromRemote(uid);

      // emit success
      emit(AuthSuccess(uid));

    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }

//register
  Future<void> register(String email, String password) async {
    try {
      emit(AuthLoading());
      final user = await repo.register(email, password);
      await repo.todoSyncRepository.local.clearAllTodos();
      emit(AuthSuccess(user!.uid));
      await repo.todoSyncRepository.pullFromRemote(user.uid);
    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }


//logout
  Future<void> logout() async {
    try {
      await repo.logout();

      // clear all local Hive todos using the sync repo
      await repo.todoSyncRepository.local.clearAllTodos();

      // emit logged out state
      emit(AuthLoggedOut());

    } catch (e) {
      emit(AuthFailure(e.toString()));
    }
  }}
