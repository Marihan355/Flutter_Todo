import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/responsiveness.dart';
import '../cubit/todo_cubit.dart';

class TodoForm extends StatefulWidget {
  final String uid;
  final Map<String, dynamic>? existing;

  const TodoForm({super.key, required this.uid, this.existing});

  @override
  State<TodoForm> createState() => _TodoFormState();
}

class _TodoFormState extends State<TodoForm> {
  late TextEditingController titleCtrl;// late Because the controller is initialized in initState, not at declaration
  late TextEditingController descCtrl;
  DateTime? due;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.existing?["title"]);
    descCtrl = TextEditingController(text: widget.existing?["desc"]);//initialize description controller
    if (widget.existing?["due"] != null) {
      due = DateTime.fromMillisecondsSinceEpoch(widget.existing!["due"]); 
    }
  }

  @override
  Widget build(BuildContext context) {
    final w = screenWidth(context);
    final h = screenHeight(context);
    final pastelBlueDark = const Color(0xFF6CA9D9);

    return SafeArea(
      child: AlertDialog(
        title: Text(
          widget.existing == null ? "New Todo" : "Edit Todo",
          style: TextStyle(
            fontSize: w * 0.05,
            fontWeight: FontWeight.bold,

          ),
        ),
        content: SingleChildScrollView( //to avoid overflow when keyboard appears
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,//align to left
            children: [
              // TITLE
              TextField(
                controller: titleCtrl,
                decoration: InputDecoration(
                  labelText: "Title",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: h * 0.015,
                    horizontal: w * 0.03,
                  ),
                ),
                style: TextStyle(fontSize: w * 0.04),
              ),
              SizedBox(height: h * 0.015),

              // DESCRIPTION
              TextField(
                controller: descCtrl,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: "Description",
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: EdgeInsets.symmetric(
                    vertical: h * 0.015,
                    horizontal: w * 0.03,
                  ),
                ),
                style: TextStyle(fontSize: w * 0.035),
              ),
              SizedBox(height: h * 0.015),

              //Date Picker
              Row(
                children: [ //row for date icon, selected date text, and pick date button
                  Icon(Icons.calendar_month, color: pastelBlueDark, size: w * 0.06),//calendar icon
                  SizedBox(width: w * 0.02),
                  Expanded(//
                    child: Text(
                      due == null //if no date selected, show "no due date"
                          ? "No due date"
                          : "${due!.day}/${due!.month}/${due!.year}", //selected due date
                      style: TextStyle(fontSize: w * 0.035,),
                    ),
                  ),
                  TextButton( //pick date button
                    onPressed: () async { //open date picker dialog
                      final picked = await showDatePicker(//this is a ready pop dialoge widget flutter gives me
                        context: context,
                        initialDate: due ?? DateTime.now(),
                        firstDate: DateTime.now(), // no past dates
                        lastDate: DateTime(2100),//for future date
                        builder: (ctx, child) { //
                          return Theme(
                            data: Theme.of(context).copyWith( //copyWith creates a copy of the current theme and allows you to override specific properties
                              colorScheme: ColorScheme.light(
                                primary: pastelBlueDark,//header background color
                                onPrimary: Colors.white,//header text color
                                surface: Colors.white,//content background color
                                onSurface: Colors.black87,//content text color
                              ),
                            ),
                            child: child!,//the actual date picker dialog.I'm sure it won't be null so I  use !
                          );
                        },
                      );
                      if (picked != null) setState(() => due = picked); //the picked date isn't null, then due= picked
                    },
                    child: Text(
                      "Pick Date",
                      style: TextStyle(color: pastelBlueDark, fontSize: w * 0.035),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton( //cancel btn
            onPressed: () => Navigator.pop(context), //close the dialog
            child: Text(
              "Cancel",
              style: TextStyle(fontSize: w * 0.04),
            ),
          ),
          ElevatedButton( //save btn
            style: ElevatedButton.styleFrom(
              backgroundColor: pastelBlueDark,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: h * 0.015,
                horizontal: w * 0.05,
              ),
            ),
            onPressed: () { //to add(if it didn't exist) or update todo (if it existed), then close the dialog
            final title = titleCtrl.text.trim();  //check if title is empty
            if (title.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Title is required."),
                  backgroundColor: Colors.red,
                ),
              );
              return; //don't save
            }

              if (widget.existing == null) {
                context.read<TodoCubit>().addTodo(
                  widget.uid,
                  titleCtrl.text,
                  descCtrl.text,
                  due,
                );
              } else {
                context.read<TodoCubit>().updateTodo(
                  widget.uid,
                  widget.existing!["id"],
                  titleCtrl.text,
                  descCtrl.text,
                  due,
                );
              }
              Navigator.pop(context);//close the dialog
            },
            child: Text(
              "Save",
              style: TextStyle(fontSize: w * 0.04),
            ),
          ),
        ],
      ),
    );
  }
}