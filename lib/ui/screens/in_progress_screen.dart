import 'package:flutter/material.dart';

import '../../data/models/network_response.dart';
import '../../data/models/task_list_wrapper_model.dart';
import '../../data/models/task_model.dart';
import '../../data/network_callers/network_caller.dart';
import '../../data/utilities/urls.dart';
import '../widgets/centered_progress_indicator.dart';
import '../widgets/task_item.dart';


class InProgressTaskScreen extends StatefulWidget {
  const InProgressTaskScreen({super.key});

  @override
  State<InProgressTaskScreen> createState() => _InProgressTaskScreenState();
}

class _InProgressTaskScreenState extends State<InProgressTaskScreen> {
  bool _progressTaskInProgress = false;
  List<TaskModel> progressTaskList = [];

  @override
  void initState() {
    super.initState();
    _getProgressTask();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: RefreshIndicator(
        color: AppColor.themeColor,
        onRefresh: () async {
          await _getProgressTask();
        },
        child: Visibility(
          visible: !_progressTaskInProgress,
          replacement: const CenteredProgressIndicator(),
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: ListView.builder(
              itemCount: progressTaskList.length,
              itemBuilder: (context, index) {
                return TaskListItem(
                  taskModel: progressTaskList[index],
                  labelBgColor: AppColor.progressLabelColor,
                  onUpdateTask: () {
                    _getProgressTask();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _getProgressTask() async {
    setState(() {
      _progressTaskInProgress = true;
    });

    NetworkResponse response = await NetworkCaller.getResponse(Urls.progressTask);

    if (response.isSuccess) {
      TaskListWrapperModel taskListWrapperModel =
      TaskListWrapperModel.fromJson(response.responseData);
      setState(() {
        progressTaskList = taskListWrapperModel.taskList ?? [];
      });
    } else {
      _setCustomToast(
        response.errorMessage ?? "Get progress task failed!",
        Icons.error_outline,
        AppColor.red,
        AppColor.white,
      );
    }

    setState(() {
      _progressTaskInProgress = false;
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
  static const progressLabelColor = Colors.orange;
  static const red = Colors.red;
  static const white = Colors.white;
}