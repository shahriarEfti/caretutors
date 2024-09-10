import 'package:flutter/material.dart';

import '../../data/models/network_response.dart';
import '../../data/models/task_by_status_count_wrapper_model.dart';
import '../../data/models/task_count_by_status_model.dart';
import '../../data/models/task_list_wrapper_model.dart';
import '../../data/models/task_model.dart';
import '../../data/network_callers/network_caller.dart';
import '../../data/utilities/urls.dart';
import '../utility/app_colors.dart';
import '../widgets/centered_progress_indicator.dart';
import '../widgets/snackbar_message.dart';
import '../widgets/task_item.dart';
import '../widgets/task_summary_card.dart';
import 'add_new_task_screen.dart';


class NewTaskScreen extends StatefulWidget {
  const NewTaskScreen({super.key});

  @override
  State<NewTaskScreen> createState() => _NewTaskScreenState();
}

class _NewTaskScreenState extends State<NewTaskScreen> {
  bool _getNewTasksInProgress = false;
  bool _getTaskCountByStatusInProgress = false;
  List<TaskModel> newTaskList = [];
  List<TaskCountByStatusModel> taskCountByStatusList = [];

  @override
  void initState() {
    super.initState();
    _getTaskCountByStatus();
    _getNewTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
        child: Column(
          children: [
            _buildSummarySection(),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  _getNewTasks();
                  _getTaskCountByStatus();
                },
                child: Visibility(
                  visible: _getNewTasksInProgress == false,
                  replacement: const CenteredProgressIndicator(),
                  child: ListView.builder(
                    itemCount: newTaskList.length,
                    itemBuilder: (context, index) {
                      return TaskListItem(
                        taskModel: newTaskList[index],
                        onUpdateTask: () {
                          _getNewTasks();
                          _getTaskCountByStatus();
                        }, labelBgColor: Colors.grey,
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _onTapAddButton,
        backgroundColor: AppColors.themeColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _onTapAddButton() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddNewTaskScreen(),
      ),
    ).then((_) {
      _getNewTasks();
      _getTaskCountByStatus();
    });
  }

  Widget _buildSummarySection() {
    if (_getTaskCountByStatusInProgress) {
      return const SizedBox(
        height: 100,
        child: CenteredProgressIndicator(),
      );
    } else {
      return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: taskCountByStatusList.map((e) {
            return TaskSummaryCard(
              title: (e.sId ?? 'Unknown').toUpperCase(),
              count: e.sum.toString(),
            );
          }).toList(),
        ),
      );
    }
  }

  Future<void> _getNewTasks() async {
    setState(() {
      _getNewTasksInProgress = true;
    });

    NetworkResponse response = await NetworkCaller.getResponse(Urls.newTask);

    if (response.isSuccess) {
      TaskListWrapperModel taskListWrapperModel =
      TaskListWrapperModel.fromJson(response.responseData);
      setState(() {
        newTaskList = taskListWrapperModel.taskList ?? [];
      });
    } else {
      if (mounted) {
        showSnackBarMessage(
            context, response.errorMessage ?? 'Get new task failed! Try again');
      }
    }

    setState(() {
      _getNewTasksInProgress = false;
    });
  }

  Future<void> _getTaskCountByStatus() async {
    setState(() {
      _getTaskCountByStatusInProgress = true;
    });

    NetworkResponse response =
    await NetworkCaller.getResponse(Urls.taskStatusCount);

    if (response.isSuccess) {
      TaskCountByStatusWrapperModel taskCountByStatusWrapperModel =
      TaskCountByStatusWrapperModel.fromJson(response.responseData);
      setState(() {
        taskCountByStatusList =
            taskCountByStatusWrapperModel.taskCountByStatusList ?? [];
      });
    } else {
      if (mounted) {
        showSnackBarMessage(context,
            response.errorMessage ?? 'Get task count by status failed! Try again');
      }
    }

    setState(() {
      _getTaskCountByStatusInProgress = false;
    });
  }
}