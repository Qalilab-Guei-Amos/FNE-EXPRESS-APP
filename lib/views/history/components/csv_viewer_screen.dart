import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';

class CsvViewerScreen extends StatelessWidget {
  final String title;
  final String establishment;
  final String? period;
  final String generatedAt;
  final String totalCA;
  final int fneCount;
  final List<String> headers;
  final List<List<String>> rows;
  final String? filePath; // Chemin du fichier pour le partage

  const CsvViewerScreen({
    super.key,
    required this.title,
    required this.establishment,
    this.period,
    required this.generatedAt,
    required this.totalCA,
    required this.fneCount,
    required this.headers,
    required this.rows,
    this.filePath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),
      appBar: AppBar(
        title: Text(
          title,
          style: TextStyle(fontSize: R.fs(context, 16), fontWeight: FontWeight.w900, letterSpacing: 0.5),
        ),
        elevation: 0,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          if (filePath != null)
            IconButton(
              icon: const Icon(Icons.share_rounded),
              tooltip: 'Partager le rapport Excel',
              onPressed: () {
                Share.shareXFiles(
                  [XFile(filePath!)],
                  subject: 'Rapport Financier - $establishment',
                );
              },
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Header Premium ──
          Container(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            decoration: const BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(32),
                bottomRight: Radius.circular(32),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  establishment.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.w900, 
                    color: Colors.white,
                    letterSpacing: 1.2
                  ),
                ),
                const SizedBox(height: 8),
                if (period != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      period!,
                      style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                    ),
                  ),
                const SizedBox(height: 12),
                Text(
                  'Généré le $generatedAt',
                  style: TextStyle(fontSize: 10, color: Colors.white.withValues(alpha: 0.7)),
                ),
                const SizedBox(height: 24),
                
                // Stats Badges
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatCard(context, Icons.receipt_long_rounded, 'Total FNE', '$fneCount'),
                    const SizedBox(width: 16),
                    _buildStatCard(context, Icons.account_balance_wallet_rounded, 'Chiffre d\'Affaires', totalCA),
                  ],
                ),
              ],
            ),
          ),

          // ── Data Table Header ──
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columnSpacing: 32,
                    horizontalMargin: 32,
                    headingRowHeight: 60,
                    dataRowMinHeight: 52,
                    dataRowMaxHeight: 52,
                    headingRowColor: WidgetStateProperty.all(AppTheme.primary.withValues(alpha: 0.04)),
                    columns: headers.map((h) => DataColumn(
                      label: Text(
                        h.toUpperCase(), 
                        style: const TextStyle(
                          fontWeight: FontWeight.w800, 
                          color: AppTheme.primary, 
                          fontSize: 11,
                          letterSpacing: 0.5
                        )
                      )
                    )).toList(),
                    rows: rows.asMap().entries.map((entry) {
                      final index = entry.key;
                      final row = entry.value;
                      return DataRow(
                        color: WidgetStateProperty.all(index % 2 == 0 ? Colors.white : const Color(0xFFFDFDFD)),
                        cells: row.map((cell) => DataCell(
                          Text(
                            cell, 
                            style: TextStyle(
                              fontSize: 12, 
                              color: AppTheme.textDark.withValues(alpha: 0.85),
                              fontWeight: cell.contains(' F') ? FontWeight.w700 : FontWeight.normal
                            )
                          )
                        )).toList()
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, IconData icon, String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppTheme.primary),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label, 
                style: TextStyle(fontSize: 9, color: Colors.grey[500], fontWeight: FontWeight.w600)
              ),
              Text(
                value, 
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppTheme.primary)
              ),
            ],
          ),
        ],
      ),
    );
  }
}
