import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:todo/features/todos/repository/todo_local_repository.dart';
import 'package:todo/features/todos/repository/todo_remote_repository.dart';
import 'todo_local_repository.dart';

class TodoSyncRepository {
  final TodoRepository remote; //remote
  final TodoLocalRepository local; //local
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
    final created = DateTime.now().millisecondsSinceEpoch;

    final todo = {
      "id": id,
      "uid": uid,
      "title": title,
      "desc": desc,
      "due": due?.millisecondsSinceEpoch,
      "created": created,
      "done": false,
      "isSynced": false,
      "isDeleted": false,
    };
    await local.saveTodo(todo); //save to local
    await _trySync (uid, todo);   //try pushing into firestore
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
      "done": existing["done"] ?? false,
    };
    await local.saveTodo(updated); //update local
    await _trySync(uid, updated); //try updating the firestore
  }

//delete (soft-delete remote by setting isDeleted or hard delete depending on remove)
  Future<void> deleteTodo(String uid, String id) async {
  final existing = local.getTodos().firstWhere((t) => t['id'] == id);
  final updated = {
    ...existing,
    "isDeleted": true,
    "isSynced": false,
  };
  await local.saveTodo(updated);
  await _trySync(uid, updated); // pass full object
} //try deleting in firestore
  

//toggle
  Future<void> toggleDone(String uid, String id, bool done) async {
    final existing = local.getTodos().firstWhere((t) => t["id"] == id); //find it in local

    final updated = {
      ...existing,
      "done": done,
      "isSynced": false,
    };
    await local.saveTodo(updated); //save in local
    await _trySync(uid, updated);         //try upadateing firestore
  }

  //  SYNC LOGIC //_trySync
  Future<void> _trySync(String uid, Map<String, dynamic> todo) async {
    final connected = await Connectivity().checkConnectivity();
    if (connected == ConnectivityResult.none) return; //if offline,sync later
     
    // If todo only has id + isDeleted (sent from deleteTodo), fetch existing local representation to get uid/created
    final id = todo["id"];
    if (id == null) return;

    // If deleted -> remove remote and local
    if (todo["isDeleted"] == true) {
      // Try to delete remote (if exists) and always remove local copy afterwards
      try {
        await remote.deleteTodo(uid, id, soft: false);
      } catch (_) {
        // If remote delete fails, attempt soft delete instead
        try {
          await remote.deleteTodo(uid, id, soft: true);
        } catch (_) {}
      }
      await local.deleteTodo(id);
      return;
    }

   //update or add
    // Ensure we have a full local todo object
    final localTodos = local.getTodos();
    final existingLocal = localTodos.firstWhere((t) => t["id"] == id, orElse: () => todo);

    final title = existingLocal["title"] ?? todo["title"] ?? '';
    final desc = existingLocal["desc"] ?? todo["desc"] ?? '';
    final due = existingLocal["due"];
    final created = existingLocal["created"] is int ? existingLocal["created"] as int : DateTime.now().millisecondsSinceEpoch;
    final done = existingLocal["done"] ?? false;

    // If remote already has same id => update, otherwise add using that id
    final existsRemotely = await remote.exists(uid, id);

    if (existsRemotely) {
      await remote.updateTodo(
        uid,
        id,
        title,
        desc,
        due != null ? DateTime.fromMillisecondsSinceEpoch(due) : null,
        done: done,
        createdMillis: created,
        isDeleted: false,
      );
      } else {
      await remote.addTodo(
        uid,
        id,
        title,
        desc,
        due != null ? DateTime.fromMillisecondsSinceEpoch(due) : null,
        done,
        created,
      );
    }
    // mark synced locally
    final up = {
      ...existingLocal,
      "isSynced": true,
      "id": id,
      "done": done,
      "created": created,
      "isDeleted": false,
    };
    await local.saveTodo(up);
  }


//when logout is clicked, everything in Hive Box is removed, so data isn't pulling from the same source if multible users use the same device
  Future<void> pullFromRemote(String uid) async {
    // Fetch all remote todos
    final remoteTodos = await remote.getAllTodos(uid);

    // Clear local Hive todos first
    await local.clearAllTodos();

    // Save all remote todos locally
    for (var todo in remoteTodos) {
       // Skip remote docs that are marked deleted
      if (todo['isDeleted'] == true) continue;

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
        "isDeleted": false,
      };

      await local.saveTodo(todoMap);//save in local
    } 
  }

//syncAllUnsynced
  Future<void> _syncAllUnsyncedTodos() async {
    final unsynced = local.getUnsyncedTodos(); //find todos in local here isSynced is false
   
    for (var todo in unsynced) {
      final uidOfTodo = todo["uid"]; //find the userid in remote
      if (uidOfTodo != null) {  
        try{await _trySync(uidOfTodo, todo);
        } catch (e){
          //errors
        }    //if user exists
        
      }
    }


  }

  DateTime? _convertDue(dynamic value) {  //? means the variable can be null
    if (value == null) return null;
    return DateTime.fromMillisecondsSinceEpoch(value); //or it will store date time object//it converts a number into readable DateTime object
  }
}