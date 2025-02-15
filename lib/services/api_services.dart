import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:task_management/model/TaskModel.dart';
import 'package:task_management/utils/constant.dart';


class ApiService {
  static const String baseUrl = Constant.baseurl;
  static const Map<String, String> headers = {"Content-Type": "application/json"};

  // GET - Fetch Tasks
  Future<List<TaskModel>> fetchTasks(int page, int limit) async {
    try {
      var url = "$baseUrl?page=$page&limit=$limit";
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );

      print("url: $url");
      print("response: ${response.body}");

      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body);

        // Ensure 'items' exists in the response and is a list
        if (jsonData['items'] is List) {
          List<TaskModel> tasks = (jsonData['items'] as List)
              .map((task) => TaskModel.fromJson(task))
              .toList();

          print("Parsed Tasks: $tasks");
          return tasks;
        } else {
          throw Exception("Invalid response format: 'items' is not a list");
        }
      } else {
        throw Exception("Failed to fetch tasks");
      }
    } catch (error) {
      throw Exception("Error: $error");
    }
  }

  // POST - Add Task
  Future<TaskModel> addTask(String title, String description, bool isCompleted) async {
    try {
      var body = {
        "title": title,
        "description": description,
        "is_completed": isCompleted,
      };
      print("body: $body");

      final response = await http.post(
        Uri.parse("$baseUrl"),
        headers: headers,
        body: json.encode(body),
      );

      print("response: ${response.body}");

      if (response.statusCode == 201) {
        var jsonResponse = json.decode(response.body);

        return TaskModel.fromJson(jsonResponse["data"]); // ✅ Extract task data correctly
      } else {
        throw Exception("Failed to add task");
      }
    } catch (error) {
      throw Exception("Error: $error");
    }
  }
  // GET - Fetch Task by ID
  Future<TaskModel> getTaskById(String id) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/$id"),
        headers: headers,
      );

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);

        return TaskModel.fromJson(jsonResponse["data"]);
      } else {
        throw Exception("Failed to fetch task");
      }
    } catch (error) {
      throw Exception("Error: $error");
    }
  }

  //  PUT - Update Task by ID
  Future<TaskModel> updateTask(String id, String title, String description, bool isCompleted) async {
    try {
      final response = await http.put(
        Uri.parse("$baseUrl/$id"),
        headers: headers,
        body: json.encode({
          "title": title,
          "description": description,
          "is_completed": isCompleted,
        }),
      );
      print("response: ${response.body}");

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);

        return TaskModel.fromJson(jsonResponse["data"]);
      } else {
        throw Exception("Failed to update task");
      }
    } catch (error) {
      throw Exception("Error: $error");
    }
  }

  //  DELETE - Delete Task by ID

  Future<bool> deleteTask(String id) async {
    try {
      var url = "$baseUrl/$id";
      final response = await http.delete(
        Uri.parse(url),
        headers: headers,
      );

      print("url: ${url}");
      print("response: ${response.body}");

      if (response.statusCode == 200) {
        var jsonResponse = json.decode(response.body);
        return jsonResponse["success"]; // ✅ Return success status
      } else {
        throw Exception("Failed to delete task");
      }
    } catch (error) {
      return false;
    }
  }
}
