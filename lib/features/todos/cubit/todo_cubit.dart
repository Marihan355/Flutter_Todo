import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../repository/todo_sync_repository.dart';
import 'todo_state.dart';
import '../repository/todo_remote_repository.dart'; //the cubit listens to hive, it emits state and forward requests to sync-- sync saves in hive and trysync

class TodoCubit extends Cubit<TodoState> {
  final TodoSyncRepository _repo;  //sync repo

  TodoCubit(this._repo) : super(TodoState.initial()); //i pass to the cubit the repo and initalstate

//load todos
  void loadTodos(String uid) {
    emit(state.copyWith(isLoading: true)); //loading ui indicator

    _repo.watchTodos(uid).listen((data) {  //return a stream of todos from Hive. listen(subscribe to that stream)
      emit(TodoState(todos: data, isLoading: false)); //whenever there's new data, cubit emit new state. is ;loading false so ui knows loading finished
    });
  }

//add
  Future<void> addTodo(String uid, String title, String desc, DateTime? due) {
    return _repo.addTodo(uid, title, desc, due);
  }

//update
  Future<void> updateTodo(String uid, String id, String title, String desc, DateTime? due) {
    return _repo.updateTodo(uid, id, title, desc, due);
  }

//delette
  Future<void> deleteTodo(String uid, String id) {
    return _repo.deleteTodo(uid, id);
  }

//toggledone
  Future<void> toggleDone(String uid, String id, bool done) {
    return _repo.toggleDone(uid, id, done);
  }
}


