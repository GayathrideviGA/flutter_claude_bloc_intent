class Task {
  final String id;
  final bool isCompleted;
  final String title;
  Task({required this.id, required this.title, this.isCompleted = false});
  Task copyWith({String? id, String? title, bool? isCompleted}) {
    return Task(id: id ?? this.id, title: title ?? this.title, isCompleted: isCompleted ?? this.isCompleted);
  }
}
