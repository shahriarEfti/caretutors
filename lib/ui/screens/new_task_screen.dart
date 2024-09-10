import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

class TaskController extends GetxController {
  var isLoadingTasks = false.obs;
  var isLoadingTaskCount = false.obs;
  var newTaskList = <TaskModel>[].obs;
  var taskCountByStatusList = <TaskCountByStatusModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    getTaskCountByStatus();
    getNewTasks();
  }

  Future<void> getNewTasks() async {
    isLoadingTasks.value = true;

    NetworkResponse response = await NetworkCaller.getResponse(Urls.newTask);

    if (response.isSuccess) {
      TaskListWrapperModel taskListWrapperModel =
      TaskListWrapperModel.fromJson(response.responseData);
      newTaskList.value = taskListWrapperModel.taskList ?? [];
    } else {
      showSnackBarMessage(Get.context!, response.errorMessage ?? 'Get new task failed! Try again');
    }

    isLoadingTasks.value = false;
  }

  Future<void> getTaskCountByStatus() async {
    isLoadingTaskCount.value = true;

    NetworkResponse response = await NetworkCaller.getResponse(Urls.taskStatusCount);

    if (response.isSuccess) {
      TaskCountByStatusWrapperModel taskCountByStatusWrapperModel =
      TaskCountByStatusWrapperModel.fromJson(response.responseData);
      taskCountByStatusList.value = taskCountByStatusWrapperModel.taskCountByStatusList ?? [];
    } else {
      showSnackBarMessage(Get.context!, response.errorMessage ?? 'Get task count by status failed! Try again');
    }

    isLoadingTaskCount.value = false;
  }
}

class NewTaskScreen extends StatelessWidget {
  NewTaskScreen({super.key});

  final TaskController taskController = Get.put(TaskController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
        child: Column(
          children: [
            Obx(() => taskController.isLoadingTaskCount.value
                ? const SizedBox(
              height: 100,
              child: CenteredProgressIndicator(),
            )
                : _buildSummarySection()),
            const SizedBox(height: 8),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  taskController.getNewTasks();
                  taskController.getTaskCountByStatus();
                },
                child: Obx(
                      () => taskController.isLoadingTasks.value
                      ? const CenteredProgressIndicator()
                      : ListView.builder(
                    itemCount: taskController.newTaskList.length,
                    itemBuilder: (context, index) {
                      return TaskListItem(
                        taskModel: taskController.newTaskList[index],
                        onUpdateTask: () {
                          taskController.getNewTasks();
                          taskController.getTaskCountByStatus();
                        },
                        labelBgColor: Colors.grey,
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
    Get.to(() => const AddNewTaskScreen())!.then((_) {
      taskController.getNewTasks();
      taskController.getTaskCountByStatus();
    });
  }

  Widget _buildSummarySection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: taskController.taskCountByStatusList.map((e) {
          return TaskSummaryCard(
            title: (e.sId ?? 'Unknown').toUpperCase(),
            count: e.sum.toString(),
          );
        }).toList(),
      ),
    );
  }
}
