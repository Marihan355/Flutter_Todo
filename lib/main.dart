import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'app.dart';
import 'firebase_options.dart';

// local, remote , sync repos
import 'features/todos/repository/todo_local_repository.dart';
import 'features/todos/repository/todo_remote_repository.dart';
import 'features/todos/repository/todo_sync_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Hive initialization
  await Hive.initFlutter();
  final box = await Hive.openBox<Map>('todos');
//create repositories
  final localRepo = TodoLocalRepository(box); //handle hive
  final remoteRepo = TodoRepository(); //handle firestore
  final syncRepo = TodoSyncRepository(remote: remoteRepo, local: localRepo); //sync

  runApp(MyApp(syncRepo)); //myApp injects syncRepo into RepositoryProvider, so Auth and todo cuubit use it for all operations
}