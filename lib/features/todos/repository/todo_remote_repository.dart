import 'package:cloud_firestore/cloud_firestore.dart';

class TodoRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Load all todos for a user as a stream
  Stream<List<Map<String, dynamic>>> loadTodos(String uid) { //Ui live updating the list without reloading //string keys, dynamic valuess

    return _db
        .collection('users')
        .doc(uid)
        .collection('todos')
        .orderBy('created', descending: true)
        .snapshots()  //pictures of firestore data
        .map((snapshot) => //map the picture/snapshot of the whole collection of todos
        snapshot.docs.map((doc) => doc.data()).toList()); //coc is DocumentSnapshot


  }

  //addtodos
  Future<void> addTodo(
      String uid, String title, String desc, DateTime? due) async {
    final doc = _db.collection('users').doc(uid).collection('todos').doc();
    await doc.set({
      "id": doc.id,
      "title": title,
      "desc": desc,
      "due": due?.millisecondsSinceEpoch,
      "created": DateTime.now().millisecondsSinceEpoch,
      "done": false,
    });
  }

//get todos
  Future<List<Map<String, dynamic>>> getAllTodos(String uid) async {
    final snapshot = await _db
        .collection('users') //users
        .doc(uid)            //user id
        .collection('todos') //todos
        .get();              //get

    return snapshot.docs.map((doc) => doc.data()).toList();
  }

//uupdate todos
  Future<void> updateTodo(
      String uid, String id, String title, String desc, DateTime? due) async {
    await _db.collection('users').doc(uid).collection('todos').doc(id).update({
      "title": title,
      "desc": desc,
      "due": due?.millisecondsSinceEpoch,
    });
  }

//delete todos
  Future<void> deleteTodo(String uid, String id) async {
    await _db.collection('users').doc(uid).collection('todos').doc(id).delete();
  }

//toggle checkbox done
  Future<void> toggleDone(String uid, String id, bool done) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('todos')
        .doc(id)
        .update({'done': done});
  }

  /// for sync repo //checks if a todo exists in remote firestote db
  Future<bool> exists(String uid, String id) async {
    final doc = await _db
        .collection('users')
        .doc(uid)
        .collection('todos')
        .doc(id)
        .get();
    return doc.exists;

  }
}
