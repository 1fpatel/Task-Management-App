import 'package:flutter/material.dart';
import 'package:task_management/model/TaskModel.dart';
import 'package:task_management/services/api_services.dart';

class EditProvider extends ChangeNotifier {
  final ApiService apiService = ApiService();
  bool isTyping = false;
  bool isCompleted = false;
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();

  // ✅ Fetch task by ID and populate fields
  Future<void> fetchTaskDetails(String taskId) async {
    try {
      TaskModel task = await apiService.getTaskById(taskId);
      titleController.text = task.title;
      descriptionController.text = task.description;
      isCompleted = task.isCompleted;

      notifyListeners();
    } catch (error) {
      print("Error fetching task: $error");
    }
  }
  //
  // // ✅ Update Task
  // Future<void> updateTask(String taskId,context) async {
  //   try {
  //     String title = titleController.text.trim();
  //     String description = descriptionController.text.trim();
  //
  //     if (title.isNotEmpty && description.isNotEmpty) {
  //       TaskModel updatedTask = await apiService.updateTask(taskId, title, description, isCompleted);
  //       print("Task Updated Successfully: ${updatedTask.title}");
  //
  //       // ✅ Show success message
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(content: Text("Task updated successfully"), backgroundColor: Colors.green),
  //       );
  //
  //       notifyListeners();
  //     }
  //   } catch (error) {
  //     print("Error updating task: $error");
  //
  //     // ❌ Show error message
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text("Error updating task"), backgroundColor: Colors.red),
  //     );
  //   }
  // }

  // ✅ Update isTyping state
  void onchngeisTyping() {
    isTyping = titleController.text.isNotEmpty && descriptionController.text.isNotEmpty;
    notifyListeners();
  }

  // ✅ Update completion status
  void onchngeisComplete(bool value) {
    isCompleted = value;
    notifyListeners();
  }

  clearAll(){
    titleController.clear();
    descriptionController.clear();
    isCompleted = false;
    notifyListeners();
  }
}
