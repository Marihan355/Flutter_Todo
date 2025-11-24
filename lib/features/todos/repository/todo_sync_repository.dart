import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:todo/features/todos/repository/todo_local_repository.dart';
import 'package:todo/features/todos/repository/todo_remote_repository.dart';
import 'todo_local_repository.dart';

class TodoSyncRepository {
  final TodoRepository remote;
  final TodoLocalRepository local;
  StreamSubscription<ConnectivityResult>? _connectivitySub; //listen to internet status

//sync repository
  TodoSyncRepository({
    required this.remote,
    required this.local,
  }) {
    // Listen on connectivity changes to sync unsynced todos
    _connectivitySub = Connectivity().onConnectivityChanged.listen((status) {
      if (status != ConnectivityResult.none) {
        _syncAllUnsyncedTodos();
      }
    });
  }
  //stop listening/when i exit app
  void dispose() {
    _connectivitySub?.cancel();
  }

  //watch local hive todos
  Stream<List<Map<String, dynamic>>> watchTodos(String uid) async* {  //the * means it's not a future, it's a stream, real time updates
    // Emit current todos immediately(perk of local hive)
    yield local.getTodos();

    // emit updates whenever Hive/local changes/forward hive real time updates
    yield* local.watchTodos();
  }

  // Add/Update/Delete/toggle

  //add
  Future<void> addTodo(String uid, String title, String desc, DateTime? due) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString(); //local id

    final todo = {
      "id": id,
      "uid": uid,
      "title": title,
      "desc": desc,
      "due": due?.millisecondsSinceEpoch,
      "created": DateTime.now().millisecondsSinceEpoch,
      "done": false,
      "isSynced": false,
    };
    await local.saveTodo(todo); //save to local
    _trySync(uid, todo);   //try pushing into firestore
  }

//update
  Future<void> updateTodo(String uid, String id, String title, String desc, DateTime? due) async {
    final existing = local.getTodos().firstWhere((t) => t["id"] == id); //find it in local

    final updated = {
      ...existing,
      "title": title,
      "desc": desc,
      "due": due?.millisecondsSinceEpoch,
      "isSynced": false,
    };
    await local.saveTodo(updated); //update local
    _trySync(uid, updated); //try updating the firestore
  }

//delete
  Future<void> deleteTodo(String uid, String id) async {
    await local.saveTodo({  //deleted in local
      "id": id,
      "isDeleted": true,
      "isSynced": false,
    });
    _trySync(uid, {"id": id, "isDeleted": true}); //try deleting in firestore
  }

//toggle
  Future<void> toggleDone(String uid, String id, bool done) async {
    final existing = local.getTodos().firstWhere((t) => t["id"] == id); //find it in local

    final updated = {
      ...existing,
      "done": done,
      "isSynced": false,
    };
    await local.saveTodo(updated); //save in local
    _trySync(uid, updated);         //try upadateing firestore
  }

  //  SYNC LOGIC //_trySync
  Future<void> _trySync(String uid, Map<String, dynamic> todo) async {
    final connected = await Connectivity().checkConnectivity();
    if (connected == ConnectivityResult.none) return; //if offline,sync later

    if (todo["isDeleted"] == true) {
      await remote.deleteTodo(uid, todo["id"]); //remove from firestore
      await local.deleteTodo(todo["id"]);   //remove from local
      return;
    }
   //update or add
    if (await remote.exists(uid, todo["id"])) {
      await remote.updateTodo(
        uid,
        todo["id"],
        todo["title"],
        todo["desc"],
        _convertDue(todo["due"]),
      );
    } else {
      await remote.addTodo(
        uid,
        todo["title"],
        todo["desc"],
        _convertDue(todo["due"]),
      );
    }

    // mark synced
    todo["isSynced"] = true;
    await local.saveTodo(todo);
  }


//when logout is clicked, everything in Hive Box is removed, so data isn't pulling from the same source if multible users use the same device
  Future<void> pullFromRemote(String uid) async {
    // Fetch all remote todos
    final remoteTodos = await remote.getAllTodos(uid);

    // Clear local Hive todos first
    await local.clearAllTodos();

    // Save all remote todos locally
    for (var todo in remoteTodos) {
      final due = todo["due"];
      final created = todo["created"];

      final todoMap = {  //i'm filling out the feilds in local box and values from remote
        "id": todo["id"],
        "uid": uid,
        "title": todo["title"],
        "desc": todo["desc"],

        "due": due is int
            ? due
            : (due is DateTime ? due.millisecondsSinceEpoch : null),
        "created": created is int
            ? created
            : (created is DateTime ? created.millisecondsSinceEpoch : DateTime.now().millisecondsSinceEpoch),
        "done": todo["done"] ?? false,
        "isSynced": true,
      };

      await local.saveTodo(todoMap);//save in local
    } 
  }

//syncAllUnsynced
  Future<void> _syncAllUnsyncedTodos() async {
    final unsynced = local.getTodos().where((t) => t["isSynced"] == false); //find todos in local here isSynced is false
    for (var todo in unsynced) {
      final uid = todo["uid"]; //find the userid in remote
      if (uid != null) {      //if user exists
        await _trySync(uid, todo);
      }
    }


  }

  DateTime? _convertDue(dynamic value) {  //? means the variable can be null
    if (value == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(value); //or it will store date time object//it converts a number into readable DateTime object
  }
}