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
        snapshot.docs.map((doc) {
              final data = Map<String, dynamic>.from(doc.data() as Map);
              // ensure id included and consistent
              data['id'] = doc.id;
              return data;
            }).toList());
     }   //coc is DocumentSnapshot


  

  //addtodos
  Future<void> addTodo(
      String uid, String id,String title, String desc, DateTime? due, bool done, int? createdMillis) async {
    final docRef = _db.collection('users').doc(uid).collection('todos').doc(id);
    await docRef.set({
      "id": id,
      "title": title,
      "desc": desc,
      "due": due?.millisecondsSinceEpoch,
      "created": createdMillis ?? DateTime.now().millisecondsSinceEpoch,
      "done": done,
      "isDeleted": false,
      }, SetOptions(merge: true));
  }

//get todos
  Future<List<Map<String, dynamic>>> getAllTodos(String uid) async {
    final snapshot = await _db
        .collection('users') //users
        .doc(uid)            //user id
        .collection('todos') //todos
        .orderBy('created', descending: true)
        .get();              //get

   return snapshot.docs.map((doc) {
      final data = Map<String, dynamic>.from(doc.data() as Map);
      data['id'] = doc.id;
      return data;
    }).toList();
  }

//uupdate todos
  Future<void> updateTodo(
      String uid, String id, String title, String desc, DateTime? due, {bool? done, int? createdMillis, bool? isDeleted}) async {
    final docRef = _db.collection('users').doc(uid).collection('todos').doc(id);

    final Map<String, dynamic> payload = {
      "title": title,
      "desc": desc,
      "due": due?.millisecondsSinceEpoch,
    };
    if (done != null) payload['done'] = done;
    if (createdMillis != null) payload['created'] = createdMillis;
    if (isDeleted != null) payload['isDeleted'] = isDeleted;

    await docRef.set(payload, SetOptions(merge: true));
  }

//delete todos
  Future<void> deleteTodo(String uid, String id, {bool soft = false}) async {
    final docRef = _db.collection('users').doc(uid).collection('todos').doc(id);
    if (soft) {
      await docRef.set({"isDeleted": true}, SetOptions(merge: true));
    } else {
      await docRef.delete();
    }
  }

//toggle checkbox done
  Future<void> toggleDone(String uid, String id, bool done) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('todos')
        .doc(id)
        .set({'done': done}, SetOptions(merge: true));
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
