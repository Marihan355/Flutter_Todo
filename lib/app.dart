import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/register_screen.dart';
import 'features/todos/pages/todo_page.dart';

import 'features/auth/cubit/auth_cubit.dart';
import 'features/auth/repository/auth_repo.dart';

import 'features/todos/cubit/todo_cubit.dart';
import 'features/todos/repository/todo_sync_repository.dart';

class MyApp extends StatelessWidget {
  final TodoSyncRepository syncRepo;

  const MyApp(this.syncRepo, {super.key});

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value( 
      value: syncRepo,
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthCubit(AuthRepo(syncRepo)), //authcubit need the repo
          ),
          BlocProvider(
            create: (context) => TodoCubit(context.read<TodoSyncRepository>()),//gets the repository from the nearest repositoryProvider in the widget tree. it's aabove, by Repository Provider
          ),
        ],
        child: MaterialApp(
          title: 'Todo App',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            fontFamily: 'PlayfairDisplay',
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF003366)),
            useMaterial3: true, //tells flutter to use ne default colors, button shapes and elevations and so on, instead of old material2. like activating the latest material design
          ),
          initialRoute: "/login",
          routes: {
            "/login": (_) => LoginScreen(),
            "/register": (_) => RegisterScreen(),
            "/todos": (_) => const TodoPage(),
          },
        ),
      ),
    );
  }
}