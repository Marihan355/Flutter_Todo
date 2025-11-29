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
  State<TodoPage> createState() => _TodoPageState(); //create state for TodoPage because it has dynamic content (tabs and todo list)
}

class _TodoPageState extends State<TodoPage> {
  int selectedTab = 0; // 0 = My Todos, 1 = Completed

  @override
  void initState() {
    super.initState();
    final uid = FirebaseAuth.instance.currentUser!.uid;//get current user id
    // Load todos when page opens
    context.read<TodoCubit>().loadTodos(uid); //load todos for the user
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    final w = screenWidth(context);
    final h = screenHeight(context);

    return Scaffold(
        appBar: AppBar( //top App bar
          backgroundColor: Colors.blue[100],
          elevation: 2,//shadow below app bar
          title: Text(
            "My Todo List",
            style: TextStyle(fontSize: w * 0.05),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.pushNamedAndRemoveUntil( //navigate to login page after logout (It moves to a new page AND deletes all previous pages from the navigation stack.)
                  context,
                  "/login",
                      (route) => false,
                );
              },
            ),
          ],
        ),


        body: SafeArea(
          child: Column( //for the tabs and todo list
            children: [
              SizedBox(height: h * 0.01), 

              Row(
                mainAxisAlignment: MainAxisAlignment.center, //center the tabs
                children: [
                  _tabButton("My Todos", 0), //my todos tab stand at index 0
                  SizedBox(width: w * 0.05),
                  _tabButton("Completed", 1), //completed todos tab stand at index 1
                ],
              ),

              SizedBox(height: h * 0.02),

              Expanded( //to take remaining space for the todo list
                child: BlocBuilder<TodoCubit, TodoState>( //listen to changes in TodoState
                  builder: (context, state) {
                    if (state.isLoading) {
                      return const Center(child: CircularProgressIndicator()); //loading indicator while fetching todos
                    }

                    final filtered = state.todos.where((todo) {//filter todos based on selected tab
                      if (selectedTab == 0) {
                        return todo["done"] == false;
                      } else {
                        return todo["done"] == true;
                      }
                    }).toList();

                    if (filtered.isEmpty) {//handling no todos case in either tab
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

                    return ListView(//list of todos
                      children: filtered.map((todo) {
                        return Padding(
                          padding: EdgeInsets.symmetric( //padding around each todo item
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

        floatingActionButton: selectedTab == 0 //my "My Todos" tab
            ? FloatingActionButton( //add new todo cross button
          child: Icon(Icons.add, size: w * 0.07),
          onPressed: () {
            showDialog(  //open todo form dialog
              context: context,
              builder: (_) => TodoForm(uid: uid), //pass uid to form
            );
          },
        )
            : null,
      );
  }

  Widget _tabButton(String label, int index) {
    final isSelected = selectedTab == index;

    return GestureDetector( //for detectig tabs(clicks)
      onTap: () {
        setState(() => selectedTab = index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),//tab padding
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[300] : Colors.blue[50],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,//tab labels
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}