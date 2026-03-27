import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/history_controller.dart';
import '../../core/utils/responsive.dart';
import 'components/delete_dialog.dart';
import 'components/mobile_list.dart';
import 'components/tablet_grid.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.put(HistoryController(), tag: 'history_screen');

    return Scaffold(
      appBar: AppBar(
        title: Text('Historique FNE',
            style: TextStyle(fontSize: R.fs(context, 18))),
      ),
      body: Obx(() {
        if (ctrl.records.isEmpty) {
          return const HistoryEmptyState();
        }
        if (R.isTablet(context)) {
          return HistoryTabletGrid(ctrl: ctrl);
        }
        return HistoryMobileList(ctrl: ctrl);
      }),
    );
  }
}
