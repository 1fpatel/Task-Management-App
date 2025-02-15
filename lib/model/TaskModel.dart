import 'dart:convert';

TaskModel taskModelFromJson(String str) =>
    TaskModel.fromJson(json.decode(str));

String taskModelToJson(TaskModel data) => json.encode(data.toJson());

class TaskModel {
  String id;
  DateTime createdAt;
  DateTime updatedAt;
  String title;
  String description;
  bool isCompleted;

  TaskModel({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    required this.title,
    required this.description,
    required this.isCompleted,
  });

  // Convert JSON to Model
  factory TaskModel.fromJson(Map<String, dynamic> json) {
    return TaskModel(
      id: json["_id"],
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
      title: json["title"],
      description: json["description"],
      isCompleted: json["is_completed"],
    );
  }

  // Convert Model to JSON
  Map<String, dynamic> toJson() {
    return {
      "_id": id,
      "created_at": createdAt,
      "updated_at": updatedAt,
      "title": title,
      "description": description,
      "is_completed": isCompleted,
    };
  }
}
