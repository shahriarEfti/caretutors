import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../data/models/network_response.dart';
import '../../data/models/task_model.dart';
import '../../data/network_callers/network_caller.dart';
import '../../data/utilities/urls.dart';
import '../screens/canceled_task_screen.dart';

class TaskListItem extends StatefulWidget {
  const TaskListItem({
    Key? key,
    required this.taskModel,
    required this.labelBgColor,
    required this.onUpdateTask,
  }) : super(key: key);

  final TaskModel taskModel;
  final Color labelBgColor;
  final VoidCallback onUpdateTask;

  @override
  State<TaskListItem> createState() => _TaskListItemState();
}

class _TaskListItemState extends State<TaskListItem> {
  bool _deleteInProgress = false;
  bool _editTaskStatusInProgress = false;

  String dropDownValue = '';

  List<String> statusList = [
    'New',
    'Progress',
    'Completed',
    'Canceled',
  ];

  @override
  void initState() {
    super.initState();
    dropDownValue = widget.taskModel.status!;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: AppColor.white,
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: ListTile(
        title: Text(
          widget.taskModel.title ?? '',
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.taskModel.description ?? '',
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
            ),
            Text(
              "Date: ${widget.taskModel.createdDate}",
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 1),
                  decoration: BoxDecoration(
                    color: widget.labelBgColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Text(
                    widget.taskModel.status ?? '',
                    style: const TextStyle(
                      color: AppColor.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                ButtonBar(
                  buttonPadding: const EdgeInsets.all(0),
                  children: [
                    PopupMenuButton<String>(
                      color: AppColor.white,
                      icon: const Icon(
                        Icons.edit,
                      ),
                      onSelected: (String selectedValue) {
                        dropDownValue = selectedValue;
                        if (mounted) {
                          setState(() {});
                        }
                        _updateTaskStatus(selectedValue);
                      },
                      itemBuilder: (BuildContext context) {
                        return statusList.map(
                              (String value) {
                            return PopupMenuItem<String>(
                              value: value,
                              child: ListTile(
                                title: Text(
                                  value,
                                  softWrap: false,
                                ),
                                trailing: dropDownValue == value ? const Icon(Icons.done) : null,
                              ),
                            );
                          },
                        ).toList();
                      },
                    ),
                    IconButton(
                      iconSize: 24,
                      onPressed: () {
                        _showDeleteConfirmationDialog(); // Call a local method to handle delete confirmation
                      },
                      icon: const Icon(
                        Icons.delete,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateTaskStatus(String status) async {
    _editTaskStatusInProgress = true;

    if (mounted) {
      setState(() {});
    }

    loadingDialog(context); // Call loading dialog

    NetworkResponse response = await NetworkCaller.getResponse(
      Urls.updateTaskStatus(widget.taskModel.sId!, status),
    );

    _editTaskStatusInProgress = false;

    if (mounted) {
      setState(() {});
    }

    if (mounted) {
      Navigator.pop(context);
    }

    if (response.isSuccess) {
      widget.onUpdateTask();
    } else {
      setCustomToast(
        response.errorMessage ?? "Task status update failed!",
        Icons.error_outline,
        AppColor.red,
        AppColor.white,
      );
    }
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Task"),
          content: const Text("Are you sure you want to delete this task?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _deleteTask();
              },
              child: const Text("Delete"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteTask() async {
    _deleteInProgress = true;

    if (mounted) {
      setState(() {});
    }

    loadingDialog(context); // Call loading dialog

    NetworkResponse response =
    await NetworkCaller.getResponse(Urls.deleteTask(widget.taskModel.sId!));

    if (response.isSuccess) {
      widget.onUpdateTask();
    } else {
      setCustomToast(
        response.errorMessage ?? "Task delete failed!",
        Icons.error_outline,
        AppColor.red,
        AppColor.white,
      );
    }

    _deleteInProgress = false;

    if (mounted) {
      setState(() {});
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  void loadingDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }

  void setCustomToast(String message, IconData icon, Color bgColor, Color textColor) {
    // Implement your custom toast notification here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: textColor),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(color: textColor),
              ),
            ),
          ],
        ),
        backgroundColor: bgColor,
      ),
    );
  }
}