import 'package:flutter/material.dart';
import '../../../controllers/history_controller.dart';
import '../../../core/utils/responsive.dart';
import 'history_card.dart';
import 'delete_dialog.dart';
import 'tablet_grid.dart' show openRecord;

class HistoryMobileList extends StatelessWidget {
  final HistoryController ctrl;
  const HistoryMobileList({super.key, required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(R.hPad(context)),
      itemCount: ctrl.records.length,
      separatorBuilder: (_, __) => SizedBox(height: R.gap(context) * 0.6),
      itemBuilder: (context, index) {
        final record = ctrl.records[index];
        return Dismissible(
          key: Key(record.id),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: Colors.red.shade600,
              borderRadius: BorderRadius.circular(R.radius(context)),
            ),
            child: Icon(Icons.delete,
                color: Colors.white, size: R.icon(context, 28)),
          ),
          confirmDismiss: (_) => showDeleteDialog(context, ctrl, record.id),
          onDismissed: (_) => ctrl.deleteRecord(record.id),
          child: HistoryCard(
            record: record,
            onTap: () => openRecord(record),
            onDelete: null,
          ),
        );
      },
    );
  }
}
