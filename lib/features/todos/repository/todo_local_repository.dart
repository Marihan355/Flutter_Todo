import 'package:hive/hive.dart';

class TodoLocalRepository {
  final Box<Map> _box; //hive box

  TodoLocalRepository(this._box);

  //stream for UI updates/watch ui
  Stream<List<Map<String, dynamic>>> watchTodos() { //key is string, value, dynamic
  return _box.watch().map((_) => _sortedTodos());
  }

  // get all todos immediately, sorted
  List<Map<String, dynamic>> getTodos() {
    return _sortedTodos();
  }

  // returns all entries (including deleted) unsorted/raw
  List<Map<String, dynamic>> getAllRawTodos() {
    return _box.values.map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // returns unsynced todos (including deleted) — used by sync logic
  List<Map<String, dynamic>> getUnsyncedTodos() {
    return _box.values
        .map((e) => Map<String, dynamic>.from(e))
        .where((t) => t['isSynced'] == false)
        .toList();
  }

  List<Map<String, dynamic>> _sortedTodos() {
    final list = _box.values
        .map((e) => Map<String, dynamic>.from(e))
        .where((t) => t["isDeleted"] != true) // skip deleted locally
        .toList(growable: false);
    // If created field exists, sort; otherwise keep insertion order
    list.sort((a, b) {
      final aCreated = a['created'] is int ? a['created'] as int : 0;
      final bCreated = b['created'] is int ? b['created'] as int : 0;
      return bCreated.compareTo(aCreated); // descending
    });
    return list;
  }

  //save or update a todo
  Future<void> saveTodo(Map<String, dynamic> todo) async {
    await _box.put(todo['id'], todo);
  }

  //delete a single todo
  Future<void> deleteTodo(String id) async {
    await _box.delete(id);
  }

  //clear all todos safely 
  Future<void> clearAllTodos() async {
    await _box.clear(); 
  }
}