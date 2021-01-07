import 'dart:ffi';

import 'package:todo_planner/models/taskfirebase.dart';
import 'package:todo_planner/models/todofirebase.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';


class DatabaseHelper {

  Future<String> insertTaskFirebase(TaskFirebase task) async {

    String taskId = "";

    CollectionReference collectionReference = FirebaseFirestore.instance.collection('tasks');
    await collectionReference.add(task.toMap()).then((value) {
      taskId = value.id;
      print("value_firebase = ${value.id}");

    });
    return taskId;

  }

  Future<void> insertTodoFirebase(TodoFirebase todo) async {
    CollectionReference collectionReference = FirebaseFirestore.instance.collection("todo");
    await collectionReference.add(todo.toMap());
  }

  Future<void> updateTaskTitleFirebase(String id, String title) async {
    await FirebaseFirestore.instance.collection('tasks').doc(id).update({'title': title});
  }

  Future<void> updateTaskDescriptionFirebase(String id, String description) async {
    await FirebaseFirestore.instance.collection('tasks').doc(id).update({'description': description});

  }

  Future<void> updateTodoDoneFirebase(String id, int isDone) async {
    await FirebaseFirestore.instance.collection('todo').doc(id).update({'isDone': isDone});

  }

  Future<void> deleteTaskFirebase(String id) async {
    await FirebaseFirestore.instance.collection('tasks').doc(id).delete();
    var todoList = await FirebaseFirestore.instance.collection('todo').get();
    List<QueryDocumentSnapshot> snapshots =  todoList.docs;
    List<String> todoIds = List<String>();
    for (int i =0;i< snapshots.length;i++){
      if(snapshots[i]['taskId'] == id){
         FirebaseFirestore.instance.collection('todo').doc(snapshots[i].id).delete();
      }
    }
  }

}
