import 'package:flutter/material.dart';
import '../../../controllers/history_controller.dart';
import '../../../core/utils/responsive.dart';

Future<bool?> showDeleteDialog(
    BuildContext context, HistoryController ctrl, String id) {
  return showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text('Supprimer cette FNE ?',
          style: TextStyle(fontSize: R.fs(context, 17))),
      content: Text('Cette action est irréversible.',
          style: TextStyle(fontSize: R.fs(context, 14))),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text('Annuler',
              style: TextStyle(fontSize: R.fs(context, 14))),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text('Supprimer',
              style: TextStyle(
                  color: Colors.red, fontSize: R.fs(context, 14))),
        ),
      ],
    ),
  );
}

class HistoryEmptyState extends StatelessWidget {
  const HistoryEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history,
              size: R.icon(context, 80),
              color: Colors.grey.withValues(alpha: 0.3)),
          SizedBox(height: R.gap(context)),
          Text(
            'Aucune FNE dans l\'historique',
            style: TextStyle(
                color: Colors.grey, fontSize: R.fs(context, 16)),
          ),
        ],
      ),
    );
  }
}
