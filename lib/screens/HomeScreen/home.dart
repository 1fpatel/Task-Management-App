import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:task_management/model/TaskModel.dart';
import 'package:task_management/provider/AuthProvider.dart';
import 'package:task_management/provider/EditProvider.dart';
import 'package:task_management/provider/HomeProvider.dart';
import 'package:task_management/utils/app_icons.dart';
import 'package:task_management/utils/app_images.dart';
import 'package:task_management/utils/color.dart';
import 'package:task_management/utils/strings.dart';

class TaskManagerHome extends StatefulWidget {
  @override
  _TaskManagerHomeState createState() => _TaskManagerHomeState();
}

class _TaskManagerHomeState extends State<TaskManagerHome>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  bool _fabPressed = false;
  late ScrollController _scrollController;
  late HomeProvider homeProvider;
  late EditProvider editProvider;


  TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode(); // 🔹 Focus only when tapped

  DateTime? _selectedDate;
  String? _selectedStatus; // "Completed" or "Pending"

  @override
  void initState() {
    super.initState();
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    editProvider = Provider.of<EditProvider>(context, listen: false);

    homeProvider.calculateProgress();
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 600),
    );

    _slideAnimation =
        Tween<Offset>(begin: Offset(0, 0.3), end: Offset(0, 0)).animate(
          CurvedAnimation(parent: _controller, curve: Curves.easeOut),
        );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _controller.forward();
  }

  void _scrollListener() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      homeProvider.fetchTasks();
      homeProvider.calculateProgress();
    }
  }

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return GoodMorning;
    }
    if (hour < 17) {
      return GoodAfternoon;
    }
    return GoodEvening;
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer <AuthenticationProvider>(
          builder: (context, authProvider, child) {
          return Column(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                height: height * .17,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                decoration: BoxDecoration(
                  color: colorPrimary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                  boxShadow: [BoxShadow(color: Colors.grey.shade300, blurRadius: 10, spreadRadius: 2)],
                ),
                child: SafeArea(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(greeting(), style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w500, color: Colors.white)),
                            Text(authProvider.user!.displayName.toString(), style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                          ],
                        ),
                      ),

                      Row(
                        children: [
                          Icon(CupertinoIcons.bell_fill, color: Colors.white, size: 28),
                          SizedBox(width: 15),
                          Hero(
                            tag: "profile_image",
                            child: CircleAvatar(radius: 25, backgroundImage: AssetImage(profile)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20),

                      Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.shade200,
                                blurRadius: 10,
                                spreadRadius: 3),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(TaskStatus,
                                    style: GoogleFonts.poppins(
                                        fontSize: 16, fontWeight: FontWeight.w500)),
                                SizedBox(height: 5),
                                Row(
                                  children: [
                                    Container(
                                      height: 10,
                                      width: 10,
                                      decoration: BoxDecoration(
                                          color: colorPrimary,
                                          shape: BoxShape.circle),
                                    ),
                                    SizedBox(width: 5),
                                    Text(Completed,
                                        style: GoogleFonts.poppins(
                                            fontSize: 14, color: Colors.grey[600])),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Container(
                                      height: 10,
                                      width: 10,
                                      decoration: BoxDecoration(
                                          color: Colors.grey.shade300,
                                          shape: BoxShape.circle),
                                    ),
                                    SizedBox(width: 5),
                                    Text(Incomplete,
                                        style: GoogleFonts.poppins(
                                            fontSize: 14, color: Colors.grey[600])),
                                  ],
                                ),
                              ],
                            ),
                            Consumer<HomeProvider>(
                                builder: (context, homeProvider, child) {
                                  // homeProvider.calculateProgress();
                                  return AnimatedContainer(
                                  duration: Duration(milliseconds: 600),
                                  child: CircularProgressIndicator(
                                    value: homeProvider.progressValue,
                                    backgroundColor: Colors.grey.shade300,
                                    strokeWidth: 10,
                                    valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.blue),
                                  ),
                                );
                              }
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(TaskList,
                              style: GoogleFonts.poppins(
                                  fontSize: 18, fontWeight: FontWeight.w600)),
                          GestureDetector(
                              onTap: (){
                                _showFilterDialog(context, homeProvider);
                              },
                              child: Image.asset(icn_filter, height: 22)),
                          // Row(
                          //   children: [
                          //     Icon(CupertinoIcons.search),
                          //     SizedBox(width: 20),
                          //     GestureDetector(
                          //         onTap: (){
                          //           _showFilterDialog(context);
                          //         },
                          //         child: Image.asset(icn_filter, height: 22)),
                          //     SizedBox(width: 10),
                          //   ],
                          // ),
                        ],
                      ),
                      SizedBox(height: 10),

                      TextField(
                        controller: _searchController,
                        onChanged: (value) => context.read<HomeProvider>().setSearchQuery(value),
                        focusNode: _searchFocusNode, // 🔹 Focus when tapped
                        decoration: InputDecoration(
                          hintText: "Search tasks...",
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      // SizedBox(height: 10),

                      Expanded(
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Consumer<HomeProvider>(
                            builder: (context, homeProvider, child) {
                              if (homeProvider.isLoading && homeProvider.tasks.isEmpty) {
                                return const Center(child: CircularProgressIndicator(color: Colors.green,));
                              }

                              if (!homeProvider.isLoading && homeProvider.tasks.isEmpty) {
                                return const Center(
                                  child: Text(
                                    Notasksavailable,
                                    style: TextStyle(fontSize: 18, color: Colors.grey),
                                  ),
                                );
                              }
                              return RefreshIndicator(
                                onRefresh: homeProvider.refreshTasks,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  itemCount: homeProvider.tasks.length + (homeProvider.hasMore && homeProvider.isLoading ? 1 : 0),
                                  itemBuilder: (context, index) {
                                    if (index == homeProvider.tasks.length) {
                                      return homeProvider.hasMore && homeProvider.isLoading
                                          ? const Padding(
                                        padding: EdgeInsets.all(8.0),
                                        child: Center(child: CircularProgressIndicator()),
                                      )
                                          : const SizedBox();
                                    }

                                    TaskModel task = homeProvider.tasks[index];

                                    if (index >= homeProvider.taskColors.length) {
                                      homeProvider.taskColors.add(homeProvider.getRandomColor());
                                    }
                                    return taskCard(task.title, task.description.toString(), task.id.toString(), homeProvider.taskColors[index]);
                                  },
                                ),
                              );
                            },
                          ),

                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      floatingActionButton: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        child: FloatingActionButton(
          onPressed: () {_showBottomSheet(context);},
          backgroundColor: colorPrimary,
          child: Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
    );
  }

  void _showFilterDialog(BuildContext context, HomeProvider homeProvider) {
    DateTime? tempDate = homeProvider.selectedDate;
    bool isCompleted = homeProvider.filterCompleted ?? false;
    bool isPending = homeProvider.filterPending ?? false;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(FilterTasks, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              TextButton(
                onPressed: () {
                  tempDate = null;
                  isCompleted = false;
                  isPending = false;
                  (context as Element).markNeedsBuild();
                },
                child: Text(ClearAll, style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(Icons.calendar_today),
                    title: Text(tempDate != null ? "${tempDate!.toLocal()}".split(' ')[0] : SelectDate),
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: tempDate ?? DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2030),
                      );
                      if (pickedDate != null) {
                        setState(() => tempDate = pickedDate);
                      }
                    },
                  ),


                  CheckboxListTile(
                    title: Text(Completed),
                    value: isCompleted,
                    onChanged: (value) {
                      setState(() {
                        isCompleted = value ?? false;
                      });
                    },
                  ),
                  CheckboxListTile(
                    title: Text(Pending),
                    value: isPending,
                    onChanged: (value) {
                      setState(() {
                        isPending = value ?? false;
                      });
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(Cancel),
            ),
            ElevatedButton(
              onPressed: () {

                homeProvider.setFilters(date: tempDate, isCompleted: isCompleted, isPending: isPending);
                Navigator.pop(context);
              },
              child: Text(ApplyFilters),
            ),
          ],
        );
      },
    );
  }


  void _showBottomSheet(BuildContext context) {
    TextEditingController field1Controller = TextEditingController();
    TextEditingController field2Controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            padding: EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Consumer<HomeProvider>(
                builder: (context, provider, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close, color: Colors.black),
                        ),
                        contentPadding: EdgeInsets.zero,
                        titleAlignment: ListTileTitleAlignment.center,
                        title: Text(
                          AddNewTask,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorPrimary),
                        ),
                      ),
                      SizedBox(height: 10),


                      TextField(
                        controller: field1Controller,
                        onChanged: (value) {
                          provider.onchngeisTyping(field1Controller, field2Controller);
                        },
                        decoration: InputDecoration(
                          labelText: "Title",
                          prefixIcon: Icon(Icons.text_fields, color: colorPrimary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      SizedBox(height: 15),


                      TextField(
                        controller: field2Controller,
                        onChanged: (value) {
                          provider.onchngeisTyping(field1Controller, field2Controller);
                        },
                        decoration: InputDecoration(
                          labelText: Description,
                          prefixIcon: Icon(Icons.text_fields, color: colorPrimary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      SizedBox(height: 15),


                      Row(
                        children: [
                          Checkbox(
                            value: provider.isCompleted,
                            activeColor: colorPrimary,
                            onChanged: (value) {
                              provider.onchngeisComplete(value ?? false);
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              provider.onchngeisComplete(!provider.isCompleted);
                            },
                            child: Text(
                              "Is Completed?",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),


                      GestureDetector(
                        onTap: provider.isLoading
                            ? null // 🔒 Disable button while loading
                            : () async {
                          String title = field1Controller.text.trim();
                          String description = field2Controller.text.trim();

                          if (title.isNotEmpty && description.isNotEmpty) {
                            await provider.addTask(title, description, context);
                            field1Controller.clear();
                            field2Controller.clear();
                            provider.onchngeisComplete(false);
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: provider.isLoading ? Colors.grey : provider.isTyping ? colorPrimary : Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: provider.isLoading
                              ? CircularProgressIndicator(color: Colors.white) // ⏳ Show loader
                              : Text(
                            "Submit",
                            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showEditBottomSheet(BuildContext context, String taskId) async {

    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing
      builder: (context) => Center(child: CircularProgressIndicator()),
    );

    await editProvider.fetchTaskDetails(taskId);

    if (!context.mounted) return;

    Navigator.pop(context);


    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            padding: EdgeInsets.all(15),
            child: SingleChildScrollView(
              child: Consumer<EditProvider>(
                builder: (context, provider, child) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: IconButton(
                          onPressed: () {
                            editProvider.clearAll();
                            Navigator.pop(context);
                          },
                          icon: Icon(CupertinoIcons.left_chevron),
                        ),
                        contentPadding: EdgeInsets.zero,
                        titleAlignment: ListTileTitleAlignment.center,
                        title: Text(
                          EditTask,
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorPrimary),
                        ),
                      ),
                      SizedBox(height: 10),


                      TextField(
                        controller: provider.titleController,
                        onChanged: (_) => provider.onchngeisTyping(),
                        decoration: InputDecoration(
                          labelText: "Title",
                          prefixIcon: Icon(Icons.text_fields, color: colorPrimary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      SizedBox(height: 15),


                      TextField(
                        controller: provider.descriptionController,
                        onChanged: (_) => provider.onchngeisTyping(),
                        decoration: InputDecoration(
                          labelText: Description,
                          prefixIcon: Icon(Icons.text_fields, color: colorPrimary),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                      ),
                      SizedBox(height: 15),


                      Row(
                        children: [
                          Checkbox(
                            value: provider.isCompleted,
                            activeColor: colorPrimary,
                            onChanged: (value) {
                              provider.onchngeisComplete(value ?? false);
                              provider.onchngeisTyping();
                            },
                          ),
                          GestureDetector(
                            onTap: () {
                              provider.onchngeisComplete(!provider.isCompleted);
                              provider.onchngeisTyping();
                            },
                            child: Text(
                              "Is Completed?",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),


                      GestureDetector(
                        onTap: () async {
                          String title = provider.titleController.text.trim();
                          String description = provider.descriptionController.text.trim();

                          if (title.isNotEmpty && description.isNotEmpty) {
                            await homeProvider.updateTask(taskId, title, description, context);
                            Navigator.pop(context);
                          }
                        },
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 15),
                          decoration: BoxDecoration(
                            color: provider.isTyping ? colorPrimary : Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            Update,
                            style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                    ],
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context,id, title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ConfirmDelete, style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text("Are you sure you want to delete\n${title}?"),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // Close dialog
            child: Text(Cancel, style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: colorPrimary),
            onPressed: () async {
             await homeProvider.deleteTask(id);
              Navigator.pop(context); // Close dialog
              // _logout(); // Logout function
            },
            child: Text(Delete, style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget taskCard(String title, String time, String id, Color color) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      padding: EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.05), blurRadius: 8, spreadRadius: 2),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 10,
            width: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 10),


          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  time,
                  style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          SizedBox(width: 10),

          GestureDetector(
            onTap: () async {
              _showEditBottomSheet(context, id);
            },
            child: Icon(Icons.edit, color: color),
          ),
          SizedBox(width: 20),
          GestureDetector(
            onTap: () {
              _showDeleteDialog(context, id, title);
            },
            child: Icon(CupertinoIcons.delete, color: redcolor),
          ),
        ],
      ),
    );
  }
}

