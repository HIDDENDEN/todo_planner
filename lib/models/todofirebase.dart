class TodoFirebase{
  final int id;
  final String taskId;
  final String title;
  final int isDone;
  TodoFirebase({this.id, this.taskId, this.title, this.isDone});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'taskId': taskId,
      'title': title,
      'isDone': isDone,
    };
  }
}