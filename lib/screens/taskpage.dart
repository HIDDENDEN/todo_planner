import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:todo_planner/database_helper.dart';
import 'package:todo_planner/models/taskfirebase.dart';
import 'package:todo_planner/models/todofirebase.dart';
import 'package:todo_planner/widgets.dart';

class TaskPage extends StatefulWidget {
  final TaskFirebase taskFirebase;



  TaskPage({@required this.taskFirebase});

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  DatabaseHelper _dbHelper = DatabaseHelper();

  String _taskIdFirebase = "";
  String _taskTitle = "";
  String _taskDescription = "";

  FocusNode _titleFocus;
  FocusNode _descriptionFocus;
  FocusNode _todoFocus;

  bool _contentVisible = false;

  @override
  void initState() {
    if (widget.taskFirebase != null) {
      //Set visibility to true
      _contentVisible = true;

      _taskTitle = widget.taskFirebase.title;
      _taskDescription = widget.taskFirebase.description;
      _taskIdFirebase = widget.taskFirebase.idFirebase;
      print("check =$_taskIdFirebase");
      print("check =$_taskDescription");
    }

    _titleFocus = FocusNode();
    _descriptionFocus = FocusNode();
    _todoFocus = FocusNode();

    super.initState();
  }

  @override
  void dispose() {
    _titleFocus.dispose();
    _descriptionFocus.dispose();
    _todoFocus.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Stack(
            children: [
              //=== head of task page with back arrow, Title and description
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                      top: 24.0,
                      bottom: 6.0,
                    ),
                    child: Row(
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Image(
                              image: AssetImage(
                                'assets/images/back_arrow_icon.png',
                              ),
                            ),
                          ),
                        ),

                        //=== it is my task TextField
                        //=== here i add new task in database
                        Expanded(
                          child: TextField(
                            focusNode: _titleFocus,
                            onSubmitted: (value) async {
                              if (value != "") {
                                //Check if the task is not null
                                // if (widget.taskFirebase == null) {
                                if (_taskIdFirebase == "") {
                                  TaskFirebase _newTask =
                                      TaskFirebase(title: value);
                                  // _taskId =
                                  // await _dbHelper.insertTask(_newTask);

                                  _taskIdFirebase = await _dbHelper
                                      .insertTaskFirebase(_newTask);
                                  print(
                                      "_taskIdFirebase after inserting = $_taskIdFirebase");

                                  print("taskID_firebase = $_taskIdFirebase");

                                  setState(() {
                                    _contentVisible = true;
                                    _taskTitle = value;
                                  });
                                } else {
                                  print(
                                      "_taskIdFirebase before update = $_taskIdFirebase");
                                  await _dbHelper.updateTaskTitleFirebase(
                                      _taskIdFirebase, value);
                                  setState(() {
                                    _taskTitle = value;
                                  });
                                  print("Task Updated");
                                  print(
                                      "Task title after update = $_taskTitle");
                                }

                                _descriptionFocus.requestFocus();
                              }
                            },
                            controller: TextEditingController()
                              ..text = _taskTitle,
                            decoration: InputDecoration(
                              hintText: "Enter Task Title",
                              border: InputBorder.none,
                            ),
                            style: TextStyle(
                              fontSize: 26.0,
                              fontWeight: FontWeight.bold,
                              // color: Color(0xFF211551),
                              foreground: Paint()..shader = LinearGradient(
                                colors: <Color>[Color(0xFF911466), Color(0xFF450a30)],
                              ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: _contentVisible,
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: 12.0,
                      ),

                      //=== Description Text Field
                      child: TextField(
                        focusNode: _descriptionFocus,
                        onSubmitted: (value) async {
                          if (value != "") {
                            if (_taskIdFirebase.length > 0) {
                              print("Task title before before = $_taskTitle");
                              await _dbHelper.updateTaskDescriptionFirebase(
                                  _taskIdFirebase, value);
                              print("Updated description");
                              setState(() {
                                print("Task title before = $_taskTitle");
                                _taskDescription = value;
                                print("Task title after = $_taskTitle");
                              });
                            }
                          }

                          _todoFocus.requestFocus();
                        },
                        controller: TextEditingController()
                          ..text = _taskDescription,
                        decoration: InputDecoration(
                            hintText: "Enter Description for the task...",
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 24.0,
                            )),
                      ),
                    ),
                  ),

                  //=== placing task in list one by one
                  Visibility(
                    visible: _contentVisible,
                    child: FutureBuilder(
                        initialData: [],
                        // future: _dbHelper.getTodo(_taskId),
                        builder: (context, snapshot) {
                          return Expanded(
                            child: StreamBuilder(
                              stream: FirebaseFirestore.instance
                                  .collection('todo')
                                  .where("taskId", isEqualTo: _taskIdFirebase)
                                  .snapshots(),
                              builder: (context, snapshot) {
                                return ListView.builder(
                                  itemCount: snapshot.data == null
                                      ? 0
                                      : snapshot.data.documents.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () async {
                                        if (snapshot.data.documents[index]
                                                ['isDone'] ==
                                            0) {
                                          await _dbHelper
                                              .updateTodoDoneFirebase(
                                                  snapshot.data.documents[index]
                                                      .documentID,
                                                  // ['id'],
                                                  1);
                                        } else {
                                          await _dbHelper
                                              .updateTodoDoneFirebase(
                                                  snapshot.data.documents[index]
                                                      .documentID,
                                                  // ['id'],
                                                  0);
                                        }
                                        setState(() {});
                                      },
                                      child: TodoWidget(
                                        text: snapshot.data.documents[index]
                                            ['title'],
                                        isDone: snapshot.data.documents[index]
                                                    ['isDone'] ==
                                                0
                                            ? false
                                            : true,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        }),
                  ),

                  //=== bottom todoo add
                  Visibility(
                    visible: _contentVisible,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.0,
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 20.0,
                            height: 20.0,
                            margin: EdgeInsets.only(
                              right: 12.0,
                            ),
                            decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(6.0),
                                border: Border.all(
                                  color: Color(0xFF86829D),
                                  width: 1.5,
                                )),
                            child: Image(
                              image: AssetImage(
                                'assets/images/check_icon.png',
                              ),
                            ),
                          ),
                          Expanded(
                            child: TextField(
                              focusNode: _todoFocus,
                              controller: TextEditingController()..text = "",
                              onSubmitted: (value) async {
                                //check if the field is not empty
                                if (value != "") {
                                  //Check if the task is not null
                                  if (_taskIdFirebase.length > 0) {
                                    DatabaseHelper _dbHelper = DatabaseHelper();

                                    TodoFirebase _newTodoFirebase =
                                        TodoFirebase(
                                      title: value,
                                      isDone: 0,
                                      taskId:
                                          _taskIdFirebase, // === )))) Here I made an error. I was passing  widget.task.id. Thar was working wrong for just created new Task card
                                    );

                                    await _dbHelper
                                        .insertTodoFirebase(_newTodoFirebase);
                                    setState(() {});
                                    _todoFocus.requestFocus();
                                  }
                                }
                              },
                              decoration: InputDecoration(
                                hintText: "Enter Todo item...",
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),

              //=== here my delete button
              Visibility(
                visible: _contentVisible,
                child: Positioned(
                  bottom: 24.0,
                  right: 24.0,
                  child: GestureDetector(
                    onTap: () async {
                      if (_taskIdFirebase.length > 0) {
                        await _dbHelper.deleteTaskFirebase(_taskIdFirebase);
                        Navigator.pop(context);
                      }
                    },
                    child: Container(
                      width: 60.0,
                      height: 60.0,
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Color(0xFF911466), Color(0xFF450a30)],
                            begin: Alignment(0.0, -1.0),
                            end: Alignment(0.0, 1.0),
                          ),
                          borderRadius: BorderRadius.circular(20.0)),
                      child: Image(
                        image: AssetImage(
                          "assets/images/delete_icon.png",
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
