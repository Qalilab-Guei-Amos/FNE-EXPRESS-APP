import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/responsive.dart';
import '../../../models/fne_record.dart';

class FneCard extends StatelessWidget {
  final FneRecord record;
  final VoidCallback onTap;
  const FneCard({super.key, required this.record, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isValidated = record.fneNumber != null;
    final accentColor = isValidated ? AppTheme.primary : AppTheme.primary;
    final radius = R.radius(context);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      elevation: 0,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: const Color(0xFFE8EDF2), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(radius),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Bande accent gauche ───────────────────────────
                  Container(width: 4, color: accentColor),

                  // ── Contenu ───────────────────────────────────────
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: R.isTablet(context) ? 18 : 14,
                        vertical: R.isTablet(context) ? 14 : 14,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Ligne supérieure : icône + infos ──────
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: R.icon(context, 42),
                                height: R.icon(context, 42),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppTheme.primary.withValues(alpha: 0.14),
                                      AppTheme.primary.withValues(alpha: 0.04),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  borderRadius: BorderRadius.circular(11),
                                ),
                                child: Icon(Icons.receipt_long,
                                    color: AppTheme.primary,
                                    size: R.icon(context, 21)),
                              ),
                              SizedBox(width: R.isTablet(context) ? 14 : 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      record.clientName,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        color: AppTheme.textDark,
                                        fontSize: R.fs(context, 14),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      AppFormatters.date(record.createdAt),
                                      style: TextStyle(
                                        color: AppTheme.textGrey,
                                        fontSize: R.fs(context, 11),
                                      ),
                                    ),
                                    if (record.fneNumber != null) ...[
                                      const SizedBox(height: 2),
                                      Text(
                                        record.fneNumber!,
                                        style: TextStyle(
                                          color: AppTheme.primary
                                              .withValues(alpha: 0.75),
                                          fontSize: R.fs(context, 10.5),
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // ── Séparateur ────────────────────────────
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: Divider(
                                height: 1,
                                thickness: 1,
                                color: const Color(0xFFE8EDF2)),
                          ),

                          // ── Montant ───────────────────────────────
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            decoration: BoxDecoration(
                              color: AppTheme.primary,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.payments_outlined,
                                    size: R.icon(context, 14),
                                    color: Colors.white70),
                                const SizedBox(width: 6),
                                Text(
                                  'Montant TTC',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: R.fs(context, 11),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  AppFormatters.currency(record.totalTTC),
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    fontSize: R.fs(context, 13.5),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
