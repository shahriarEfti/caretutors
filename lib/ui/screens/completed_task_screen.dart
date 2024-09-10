import 'package:flutter/material.dart';

import '../../data/models/network_response.dart';
import '../../data/models/task_list_wrapper_model.dart';
import '../../data/models/task_model.dart';
import '../../data/network_callers/network_caller.dart';
import '../../data/utilities/urls.dart';
import '../widgets/centered_progress_indicator.dart';
import '../widgets/task_item.dart';


class CompleteTaskScreen extends StatefulWidget {
  const CompleteTaskScreen({super.key});

  @override
  State<CompleteTaskScreen> createState() => _CompleteTaskScreenState();
}

class _CompleteTaskScreenState extends State<CompleteTaskScreen> {
  bool _completeTaskInProgress = false;
  List<TaskModel> completeTaskList = [];

  @override
  void initState() {
    super.initState();
    _getCompleteTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: RefreshIndicator(
        color: AppColor.themeColor,
        onRefresh: () async {
          await _getCompleteTask();
        },
        child: Visibility(
          visible: !_completeTaskInProgress,
          replacement: const CenteredProgressIndicator(),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView.builder(
              itemCount: completeTaskList.length,
              itemBuilder: (context, index) {
                return TaskListItem(
                  taskModel: completeTaskList[index],
                  labelBgColor: AppColor.completeLabelColor,
                  onUpdateTask: () {
                    _getCompleteTask();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getCompleteTask() async {
    setState(() {
      _completeTaskInProgress = true;
    });

    NetworkResponse response = await NetworkCaller.getResponse(Urls.completeTask);

    if (response.isSuccess) {
      TaskListWrapperModel taskListWrapperModel =
      TaskListWrapperModel.fromJson(response.responseData);
      setState(() {
        completeTaskList = taskListWrapperModel.taskList ?? [];
      });
    } else {
      _setCustomToast(
        response.errorMessage ?? "Get complete task failed!",
        Icons.error_outline,
        AppColor.red,
        AppColor.white,
      );
    }

    setState(() {
      _completeTaskInProgress = false;
    });
  }



  void _setCustomToast(String message, IconData icon, Color bgColor, Color textColor) {
    final snackBar = SnackBar(
      content: Row(
        children: <Widget>[
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
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class AppColor {
  static const themeColor = Colors.blue;
  static const completeLabelColor = Colors.green;
  static const red = Colors.red;
  static const white = Colors.white;
}