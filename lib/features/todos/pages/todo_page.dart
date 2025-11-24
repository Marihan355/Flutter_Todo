import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo/features/todos/repository/todo_sync_repository.dart';
import '../../../core/utils/responsiveness.dart';
import '../cubit/todo_cubit.dart';
import '../cubit/todo_state.dart';
import '../repository/todo_sync_repository.dart';
import '../widgets/todo_item.dart';
import '../widgets/todo_form.dart';

class TodoPage extends StatefulWidget {
  const TodoPage({super.key});

  @override
  State<TodoPage> createState() => _TodoPageState();
}

class _TodoPageState extends State<TodoPage> {
  int selectedTab = 0; // 0 = My Todos, 1 = Completed

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;
    // Load todos when page opens
    context.read<TodoCubit>().loadTodos(uid);
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final w = screenWidth(context);
    final h = screenHeight(context);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue[100],
          elevation: 2,
          title: Text(
            "My Todo List",
            style: TextStyle(fontSize: w * 0.05),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  "/login",
                      (route) => false,
                );
              },
            ),
          ],
        ),


        body: SafeArea(
          child: Column(
            children: [
              SizedBox(height: h * 0.01),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _tabButton("My Todos", 0),
                  SizedBox(width: w * 0.05),
                  _tabButton("Completed", 1),
                ],
              ),

              SizedBox(height: h * 0.02),

              Expanded(
                child: BlocBuilder<TodoCubit, TodoState>(
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final filtered = state.todos.where((todo) {
                      if (selectedTab == 0) {
                        return todo["done"] == false;
                      } else {
                        return todo["done"] == true;
                      }
                    }).toList();

                    if (filtered.isEmpty) {
                      return Center(
                        child: Text(
                          selectedTab == 0
                              ? "No tasks yet."
                              : "No completed tasks.",
                          style: TextStyle(
                            fontSize: w * 0.045,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }

                    return ListView(
                      children: filtered.map((todo) {
                        return Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: h * 0.01, horizontal: w * 0.03),
                          child: TodoItem(
                            key: ValueKey(todo["id"]),
                            uid: uid,
                            todo: todo,
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        floatingActionButton: selectedTab == 0
            ? FloatingActionButton(
          child: Icon(Icons.add, size: w * 0.07),
          onPressed: () {
            showDialog(
              context: context,
              builder: (_) => TodoForm(uid: uid),
            );
          },
        )
            : null,
      );
  }

  Widget _tabButton(String label, int index) {
    final isSelected = selectedTab == index;

    return GestureDetector(
      onTap: () {
        setState(() => selectedTab = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[300] : Colors.blue[50],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}