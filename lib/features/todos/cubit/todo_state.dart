import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class TodoState extends Equatable { //equatable help flutter know when two states are different, because i'm using copy with
  final List<Map<String, dynamic>> todos;

  final bool isLoading;

  const TodoState({ //const because the intial state never changes, so it can be optimized in memory
    required this.todos,
     required this.isLoading}); //every state must have a todo list and Loading state

//initial
  factory TodoState.initial() => const TodoState(//factory is used here to create a named constructor. decides what to return, can add logic
    todos: [], //empty todos
  isLoading:true,); //loading

  TodoState copyWith({  //to update a state, i must create a new state. when cubit update state, it doesn't modify the old state, it creates a new state with modifies values(todos)
    List<Map<String, dynamic>>? todos,
    bool? isLoading,
  }) {
    return TodoState(
      todos: todos ?? this.todos,
      isLoading: isLoading ?? this.isLoading,
    );
  }

//equttable props. this tells flutter that todoSate objects are wqual id todos are the same and is loading is the same.  because ui should rebuild only when sometthing changes
  @override
  List<Object> get props => [todos, isLoading];
}