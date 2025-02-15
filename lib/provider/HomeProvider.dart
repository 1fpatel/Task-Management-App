import 'dart:math';

import 'package:flutter/material.dart';
import 'package:task_management/model/TaskModel.dart';
import 'package:task_management/services/api_services.dart';

class HomeProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();
  List<TaskModel> _tasks = [];
  List<TaskModel> _filteredTasks = [];
  bool _isLoading = false;
  int _page = 1;
  final int _limit = 10;
  bool _hasMore = true;

  List<TaskModel> get tasks => _filteredTasks;
  // List<TaskModel> get tasks => _tasks;
  bool get isLoading => _isLoading;
  bool get hasMore => _hasMore;

  double progressValue = 0.0;

  String _searchQuery = '';
  DateTime? selectedDate;

  HomeProvider() {
    fetchTasks();
  }

  fetchTasks() async {
    if (_isLoading || !_hasMore) return;

    _isLoading = true;
    notifyListeners();

    try {
      List<TaskModel> newTasks = await _apiService.fetchTasks(_page, _limit);

      if (newTasks.isEmpty) {
        _hasMore = false;
      } else {
        _tasks.addAll(newTasks);
        _page++;

        if (newTasks.length < _limit) {
          _hasMore = false;
        }
      }

      _filteredTasks = List.from(_tasks);
      applyFilters();
    } catch (e) {
      debugPrint("Error fetching tasks: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  void applyFilters() {
    _filteredTasks = _tasks.where((task) {
      bool matchesSearch = _searchQuery.isEmpty || task.title.toLowerCase().contains(_searchQuery.toLowerCase());

      bool matchesDate = selectedDate == null ||
          task.createdAt.toLocal().year == selectedDate!.year &&
              task.createdAt.toLocal().month == selectedDate!.month &&
              task.createdAt.toLocal().day == selectedDate!.day;

      // print("selectedDate: ${selectedDate}");
      // print("task.createdAt: ${task.createdAt}");
      print("matchesDate: ${matchesDate}");
      bool matchesStatus = (!filterCompleted && !filterPending) ||
          (filterCompleted && task.isCompleted) ||
          (filterPending && !task.isCompleted);

      return matchesSearch && matchesDate && matchesStatus;
    }).toList();

    notifyListeners();
  }

  Future<void> addTask(String title, String description, BuildContext context) async {
    try {
      _isLoading = true;
      notifyListeners();

      TaskModel newTask = await _apiService.addTask(title, description, isCompleted);
      print("newTask: ${newTask}");

      _tasks.insert(0, newTask);
      await calculateProgress();
      applyFilters();

    } catch (error) {
      debugPrint("Error adding task: $error");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString()), backgroundColor: Colors.red),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteTask(String id) async {
    bool success = await _apiService.deleteTask(id);

    if (success) {
      _tasks.removeWhere((task) => task.id == id);
      calculateProgress();
      applyFilters();
      notifyListeners();
    }
  }

  Future<void> calculateProgress() async {
    var tasks = await _apiService.fetchTasks(1, 10);

    print("tasks found.: ${tasks}");

    if (tasks == null || tasks.isEmpty) {
      print("No tasks found.");
      progressValue = 0.0;
    } else {
      int totalTasks = tasks.length;
      int completedTasks = tasks.where((task) => task.isCompleted).length;

      print("totalTasks: $totalTasks");
      print("completedTasks: $completedTasks");

      progressValue = totalTasks > 0 ? completedTasks / totalTasks : 0.0;
    }

    notifyListeners();
  }

  Future<void> updateTask(String taskId, String title, String description, BuildContext context) async {
    try {
      if (title.isNotEmpty && description.isNotEmpty) {
        TaskModel updatedTask = await _apiService.updateTask(taskId, title, description, isCompleted);

        int index = _tasks.indexWhere((task) => task.id == taskId);
        if (index != -1) {
          _tasks[index] = updatedTask;
        }

        notifyListeners();
        calculateProgress();
        applyFilters();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Task updated successfully"), backgroundColor: Colors.green),
        );
      }
    } catch (error) {
      print("Error updating task: $error");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating task"), backgroundColor: Colors.red),
      );
    }
  }


  void setSearchQuery(String query) {
    _searchQuery = query;
    applyFilters();
  }


 bool filterCompleted = false;
 bool filterPending = false;

  void setFilters({DateTime? date, bool? isCompleted, bool? isPending}) {
    selectedDate = date;
    filterCompleted = isCompleted ?? false;  // Renamed
    filterPending = isPending ?? false;  // Renamed
    applyFilters();
  }

  Future<void> refreshTasks() async {
    _tasks.clear();
    _page = 1;
    _hasMore = true;
    _searchQuery = "";
    selectedDate = null;
    fetchTasks();
  }

  final Random _random = Random();

  Color getRandomColor() {
    return Colors.primaries[_random.nextInt(Colors.primaries.length)];
  }

  List<Color> taskColors = [];


  bool isCompleted = false;
  bool isTyping = false;

  onchngeisComplete(value){
    isCompleted = value;
    notifyListeners();
  }
  onchngeisTyping(field1Controller,field2Controller){
    isTyping = (field1Controller.text.isNotEmpty && field2Controller.text.isNotEmpty);
    notifyListeners();
  }
}
