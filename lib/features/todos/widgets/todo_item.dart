import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/responsiveness.dart';
import '../cubit/todo_cubit.dart';
import 'todo_form.dart';

class TodoItem extends StatefulWidget {
  final String uid;
  final Map<String, dynamic> todo;

  const TodoItem({super.key, required this.uid, required this.todo});

  @override
  State<TodoItem> createState() => _TodoItemState();
}

class _TodoItemState extends State<TodoItem> {
  bool checked = false; // animation flag
  bool disappear = false; // fade+slide flag

  @override
  void initState() {
    super.initState();
    checked = widget.todo['done'] == true;
  }

  @override
  void didUpdateWidget(covariant TodoItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.todo['done'] != widget.todo['done']) {
      setState(() => checked = widget.todo['done'] == true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = screenWidth(context);
    final h = screenHeight(context);

    final dueDate = widget.todo["due"] != null
        ? DateTime.fromMillisecondsSinceEpoch(widget.todo["due"])
        : null;

    final isLate = dueDate != null && dueDate.isBefore(DateTime.now());
    final isDone = widget.todo['done'] == true;
    final showGreenFlash = (!isDone && checked && disappear == false);
    return AnimatedSlide(
      duration: const Duration(milliseconds: 300),
      offset: disappear ? const Offset(0.3, 0) : Offset.zero,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 300),
        opacity: disappear ? 0 : 1, //fade out when disappearing
        child: InkWell( //tap to edit todo when not done
          onTap: isDone
              ? null //disable tap if done
              : () {
            showDialog(//edit todo dialog
              context: context,
              builder: (_) =>
                  TodoForm(uid: widget.uid, existing: widget.todo),
            );
          },
          child: AnimatedContainer( //showGreenFlash: animation when it's done, but reverting in completed
            duration: const Duration(milliseconds: 900),//
            padding: EdgeInsets.all(h * 0.015),
            margin: EdgeInsets.symmetric(
              vertical: h * 0.008,
              horizontal: w * 0.03,
            ),
            decoration: BoxDecoration(
              color: showGreenFlash
                  ? Colors.green.withOpacity(0.10)
                  : Colors.white,
              borderRadius: BorderRadius.circular(w * 0.03),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3), 
                )
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,//left
              children: [
                Checkbox( //done checkbox
                  value: (checked || isDone),
                  activeColor: Colors.green,
                  checkColor: Colors.white,
                  onChanged: (value) { //done is green
                    if (value == null) return;//

                    setState(() {//animation on checkbox toggle
                      checked = value;
                      disappear = true;
                    });

                    Future.delayed(const Duration(milliseconds: 900), () {//delay toggle to match animation
                      context.read<TodoCubit>().toggleDone( 
                        widget.uid,
                        widget.todo["id"],
                        value,
                      );
                    });
                  },
                ),

                SizedBox(width: w * 0.02),

                Expanded(//expand to fill space
                  child: DefaultTextStyle.merge(
                    style: TextStyle(
                      //decoration: isDone ? TextDecoration.lineThrough : TextDecoration.none,
                    ),
                    child: Column( //column for title, desc, due date
                      crossAxisAlignment: CrossAxisAlignment.start,//left top
                      children: [
                        Text(
                          (widget.todo["title"] ?? '').toString(),
                          style: TextStyle(
                            fontSize: w * 0.045,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        if ((widget.todo["desc"] ?? '')
                            .toString()
                            .trim()//removes white space before and after 
                            .isNotEmpty)//
                          Padding(
                            padding: EdgeInsets.only(top: h * 0.005),
                            child: Text(
                              (widget.todo["desc"] ?? '').toString(),
                              style: TextStyle(
                                fontSize: w * 0.035,
                                color: Colors.black54,
                              ),
                            ),
                          ),

                        if (dueDate != null)
                          Padding(
                            padding: EdgeInsets.only(top: h * 0.008),
                            child: Text(
                              "${dueDate.day}/${dueDate.month}/${dueDate.year}",
                              style: TextStyle(
                                fontSize: w * 0.035,
                                fontWeight: FontWeight.w500,
                                color: isLate ? Colors.red : Colors.blueGrey,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                IconButton(//delete button
                  icon: Icon(Icons.delete,
                      color: Colors.blue[400], size: w * 0.07),
                  onPressed: () {
                    showDialog(//"are you sure?" dialog
                      context: context,
                      builder: (_) =>
                          AlertDialog(
                            title: const Text("Delete Task?"),
                            content:
                            const Text(
                                "Are you sure you want to delete this task?"),
                            actions: [
                              TextButton(
                                child: const Text("Cancel"),
                                onPressed: () => Navigator.pop(context),
                              ),
                              TextButton(
                                child: const Text("Delete"),
                                onPressed: () {
                                  Navigator.pop(context);
                                  context
                                      .read<TodoCubit>()
                                      .deleteTodo(
                                      widget.uid, widget.todo["id"]);
                                },
                              ),
                            ],
                          ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }}
