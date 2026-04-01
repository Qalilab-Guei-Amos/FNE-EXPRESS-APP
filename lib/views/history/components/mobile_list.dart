import 'package:flutter/material.dart';
import '../../../controllers/history_controller.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/fne_record.dart';
import 'history_card.dart';
import 'delete_dialog.dart';
import 'tablet_grid.dart' show openRecord;

class HistoryMobileList extends StatelessWidget {
  final HistoryController ctrl;
  final List<FneRecord> records;
  const HistoryMobileList({super.key, required this.ctrl, required this.records});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(R.hPad(context)),
      itemCount: records.length,
      separatorBuilder: (_, _) => SizedBox(height: R.gap(context) * 0.6),
      itemBuilder: (context, index) {
        final record = records[index];
        final canDelete = record.status != FneStatus.certifiee;

        return HistoryCard(
          record: record,
          onTap: () => openRecord(record, ctrl),
          onDelete: canDelete
              ? () async {
                  final confirmed =
                      await showDeleteDialog(context, ctrl, record);
                  if (confirmed == true) ctrl.deleteRecord(record.id);
                }
              : null,
        );
      },
    );
  }
}
