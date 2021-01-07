import 'package:flutter/material.dart';
import 'package:todo_planner/database_helper.dart';
import 'package:todo_planner/models/taskfirebase.dart';
import 'package:todo_planner/screens/taskpage.dart';
import 'package:todo_planner/widgets.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Homepage extends StatefulWidget {
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        //--- to set elements in good area ( like fit to window)
        child: Container(
          width: double.infinity, // --- fullscreen width
          padding: EdgeInsets.symmetric(
            horizontal: 24.0,
          ),
          color: Color(0xFFF6F6F6),
          child: Stack(
            // --- here I use Stack to place elements one by one vertically
            children: [
              // === Column contains my cards
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(
                      top: 2.0,
                      bottom: 2.0,
                    ),
                    child: Image(
                      image: AssetImage('assets/images/wing.png'),
                      height: 100,
                      width: 100,
                    ),
                  ),

                  // === here I 'call' my cards
                  Expanded(
                    child: FutureBuilder(
                      initialData: [],
                      // future: _dbHelper.getTasks(),
                      builder: (context, snapshot) {
                        return ScrollConfiguration(
                          behavior: NoGlowBehaviour(),
                          child: StreamBuilder(
                            stream: FirebaseFirestore.instance
                                .collection('tasks')
                                .snapshots(),
                            builder: (context, snapshot) {
                              return ListView.builder(
                                itemCount: snapshot.data == null
                                    ? 0
                                    : snapshot.data.documents.length,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => TaskPage(
                                                  taskFirebase: TaskFirebase(
                                                    idFirebase: snapshot
                                                        .data
                                                        .documents[index]
                                                        .documentID,
                                                    title: snapshot.data
                                                            .documents[index]
                                                        ['title'],
                                                    description: snapshot.data
                                                            .documents[index]
                                                        ['description'],
                                                  ),
                                                )),
                                      ).then((value) {
                                        setState(() {});
                                      });
                                    },
                                    child: TaskCardWidget(
                                      title: snapshot.data.documents[index]
                                          ['title'],
                                      //.title,
                                      desc: snapshot.data.documents[index]
                                          ['description'], //.description,
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),

              //=== Positioned contains my 'Add button + '
              Positioned(
                bottom: 24.0,
                right: 0.0,

                //=== set onTap reaction to open new page 'Task Page'
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TaskPage(
                          taskFirebase: null,
                        ),
                      ),
                    ).then((value) {
                      setState(() {});
                    }); //==== to refresh info is there any new task card added after pressing back arrow on taskpage
                  },
                  child: Container(
                    width: 60.0,
                    height: 60.0,
                    decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xFF6b0270), Color(0xFF2c0252)],
                          begin: Alignment(0.0, -1.0),
                          end: Alignment(0.0, 1.0),
                        ),
                        borderRadius: BorderRadius.circular(20.0)),
                    child: Image(
                      image: AssetImage(
                        "assets/images/add_icon.png",
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
