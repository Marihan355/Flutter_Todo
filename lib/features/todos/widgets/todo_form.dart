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
  late TextEditingController titleCtrl;
  late TextEditingController descCtrl;
  DateTime? due;

  @override
  void initState() {
    super.initState();
    titleCtrl = TextEditingController(text: widget.existing?["title"]);
    descCtrl = TextEditingController(text: widget.existing?["desc"]);
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
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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

              // DATE ROW
              Row(
                children: [
                  Icon(Icons.calendar_month, color: pastelBlueDark, size: w * 0.06),
                  SizedBox(width: w * 0.02),
                  Expanded(
                    child: Text(
                      due == null
                          ? "No due date"
                          : "${due!.day}/${due!.month}/${due!.year}",
                      style: TextStyle(fontSize: w * 0.035,),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: due ?? DateTime.now(),
                        firstDate: DateTime.now(), // no past dates
                        lastDate: DateTime(2100),
                        builder: (ctx, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                              colorScheme: ColorScheme.light(
                                primary: pastelBlueDark,
                                onPrimary: Colors.white,
                                surface: Colors.white,
                                onSurface: Colors.black87,
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );
                      if (picked != null) setState(() => due = picked);
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
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(fontSize: w * 0.04),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: pastelBlueDark,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                vertical: h * 0.015,
                horizontal: w * 0.05,
              ),
            ),
            onPressed: () {
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
              Navigator.pop(context);
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