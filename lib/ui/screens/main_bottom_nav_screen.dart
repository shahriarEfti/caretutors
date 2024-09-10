import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utility/app_colors.dart';
import '../widgets/profile_app_bar.dart';
import 'canceled_task_screen.dart';
import 'completed_task_screen.dart';
import 'in_progress_screen.dart';
import 'new_task_screen.dart';

class BottomNavController extends GetxController {
  var selectedIndex = 0.obs;

  final List<Widget> screens = [
    NewTaskScreen(),
    const CompleteTaskScreen(),
     InProgressTaskScreen(),
    const CancelledTaskScreen(),
  ];

  void changeScreen(int index) {
    selectedIndex.value = index;
  }
}

class MainBottomNavScreen extends StatelessWidget {
  MainBottomNavScreen({super.key});

  final BottomNavController bottomNavController = Get.put(BottomNavController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ProfileAppBar(context),
      body: Obx(() => bottomNavController.screens[bottomNavController.selectedIndex.value]),
      bottomNavigationBar: Obx(
            () => BottomNavigationBar(
          currentIndex: bottomNavController.selectedIndex.value,
          onTap: (index) => bottomNavController.changeScreen(index),
          selectedItemColor: AppColors.themeColor,
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          items:  [
            BottomNavigationBarItem(icon: Icon(Icons.abc), label: 'New Task'),
            BottomNavigationBarItem(icon: Icon(Icons.done), label: 'Completed'),
            BottomNavigationBarItem(icon: Icon(Icons.ac_unit), label: 'In Progress'),
            BottomNavigationBarItem(icon: Icon(Icons.close), label: 'Cancelled'),
          ],
        ),
      ),
    );
  }
}
