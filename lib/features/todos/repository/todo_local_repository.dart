import 'package:hive/hive.dart';

class TodoLocalRepository {
  final Box<Map> _box; //hive box

  TodoLocalRepository(this._box);

  //stream for UI updates/watch
  Stream<List<Map<String, dynamic>>> watchTodos() { //key is string, value, dynamic
    return _box.watch().map((_) {
      return _box.values.map((e) => Map<String, dynamic>.from(e)).toList(); //e is the map from hive
    });
  }

  // get all todos immediately/get
  List<Map<String, dynamic>> getTodos() {
    return _box.values.map((e) => Map<String, dynamic>.from(e)).toList();
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