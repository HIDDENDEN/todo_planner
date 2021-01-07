class TaskFirebase{
  final String idFirebase;
  final String title;
  final String description;

  TaskFirebase({this.idFirebase, this.title, this.description});

  Map<String, dynamic> toMap(){
    return{
      'idFirebase': idFirebase,
      'title': title,
      'description': description,
    };
  }
}