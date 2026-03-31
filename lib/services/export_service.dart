import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:to_csv/to_csv.dart' as to_csv;
import '../models/fne_record.dart';
import '../core/utils/formatters.dart';

class ExportService extends GetxService {
  // ── PDF d'une FNE individuelle ────────────────────────────────────────────
  Future<void> exportFnePdf(FneRecord record) async {
    final pdf = pw.Document();
    final inv = record.invoice;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          // En-tête
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF036F4F),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('FACTURE NORMALISÉE ÉLECTRONIQUE',
                    style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 4),
                if (record.fneNumber != null)
                  pw.Text(record.fneNumber!,
                      style: const pw.TextStyle(
                          color: PdfColors.white, fontSize: 11)),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Infos client & facture
          pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('CLIENT',
                        style: pw.TextStyle(
                            fontSize: 9,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.grey600)),
                    pw.SizedBox(height: 4),
                    pw.Text(record.clientName,
                        style: pw.TextStyle(
                            fontSize: 13, fontWeight: pw.FontWeight.bold)),
                    if (inv.clientPhone != null)
                      pw.Text(inv.clientPhone!,
                          style: const pw.TextStyle(fontSize: 10)),
                    if (inv.clientEmail != null)
                      pw.Text(inv.clientEmail!,
                          style: const pw.TextStyle(fontSize: 10)),
                    if (inv.clientNcc != null && inv.clientNcc!.isNotEmpty)
                      pw.Text('NCC: ${inv.clientNcc}',
                          style: const pw.TextStyle(fontSize: 10)),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('DATE',
                      style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey600)),
                  pw.Text(AppFormatters.date(record.createdAt),
                      style: const pw.TextStyle(fontSize: 11)),
                  pw.SizedBox(height: 8),
                  pw.Text('TYPE',
                      style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey600)),
                  pw.Text(inv.template,
                      style: const pw.TextStyle(fontSize: 11)),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 10),

          // Tableau articles
          pw.Text('ARTICLES',
              style: pw.TextStyle(
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.grey600)),
          pw.SizedBox(height: 8),
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(3),
              1: const pw.FlexColumnWidth(1),
              2: const pw.FlexColumnWidth(1.5),
              3: const pw.FlexColumnWidth(1),
              4: const pw.FlexColumnWidth(1.5),
            },
            children: [
              // En-tête tableau
              pw.TableRow(
                decoration: pw.BoxDecoration(
                    color: PdfColor.fromInt(0xFF036F4F)),
                children: [
                  _tableHeader('Désignation'),
                  _tableHeader('Qté'),
                  _tableHeader('P.U. HT'),
                  _tableHeader('TVA'),
                  _tableHeader('Total TTC'),
                ],
              ),
              // Lignes articles
              ...inv.items.map((item) => pw.TableRow(
                    children: [
                      _tableCell(item.designation),
                      _tableCell(_formatQty(item.quantity),
                          align: pw.TextAlign.center),
                      _tableCell(_fmtAmount(item.unitPrice),
                          align: pw.TextAlign.right),
                      _tableCell(item.taxCode,
                          align: pw.TextAlign.center),
                      _tableCell(_fmtAmount(item.amountTTC),
                          align: pw.TextAlign.right),
                    ],
                  )),
            ],
          ),
          pw.SizedBox(height: 16),

          // Totaux
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Container(
              width: 220,
              child: pw.Column(
                children: [
                  _totalRow('Total HT', _fmtAmount(inv.totalHT)),
                  _totalRow('Total TVA', _fmtAmount(inv.totalTVA)),
                  pw.Divider(color: PdfColor.fromInt(0xFF036F4F)),
                  _totalRow('Total TTC', _fmtAmount(record.totalTTC),
                      bold: true),
                ],
              ),
            ),
          ),

          // Lien vérification
          if (record.qrCode != null) ...[
            pw.SizedBox(height: 24),
            pw.Container(
              padding: const pw.EdgeInsets.all(10),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey300),
                borderRadius: pw.BorderRadius.circular(6),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('Vérification FNE',
                      style: pw.TextStyle(
                          fontSize: 9,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey600)),
                  pw.SizedBox(height: 4),
                  pw.Text(record.qrCode!,
                      style: const pw.TextStyle(
                          fontSize: 9, color: PdfColors.blue)),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'FNE_${record.clientName}_${DateFormat('yyyyMMdd').format(record.createdAt)}',
    );
  }

  // ── Rapport PDF (liste filtrée) ───────────────────────────────────────────
  Future<void> exportReportPdf(List<FneRecord> records,
      {String title = 'Rapport FNE'}) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final totalCA = records
        .where((r) => r.status == FneStatus.certifiee)
        .fold(0.0, (s, r) => s + r.totalTTC);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(28),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(title,
                    style: pw.TextStyle(
                        fontSize: 16, fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFF036F4F))),
                pw.Text('Généré le ${AppFormatters.date(now)}',
                    style: const pw.TextStyle(
                        fontSize: 9, color: PdfColors.grey600)),
              ],
            ),
            pw.SizedBox(height: 6),
            pw.Row(
              children: [
                _statBox('Total', '${records.length} FNE'),
                pw.SizedBox(width: 12),
                _statBox('Chiffre d\'affaire certifié', _fmtAmount(totalCA)),
              ],
            ),
            pw.SizedBox(height: 10),
            pw.Divider(),
          ],
        ),
        build: (ctx) => [
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1.2),
              2: const pw.FlexColumnWidth(2),
              3: const pw.FlexColumnWidth(1.5),
            },
            children: [
              pw.TableRow(
                decoration:
                    pw.BoxDecoration(color: PdfColor.fromInt(0xFF036F4F)),
                children: [
                  _tableHeader('Client'),
                  _tableHeader('Date'),
                  _tableHeader('Référence FNE'),
                  _tableHeader('Total TTC'),
                ],
              ),
              ...records.map((r) => pw.TableRow(
                    children: [
                      _tableCell(r.clientName),
                      _tableCell(AppFormatters.date(r.createdAt)),
                      _tableCell(r.fneNumber ?? '—'),
                      _tableCell(_fmtAmount(r.totalTTC),
                          align: pw.TextAlign.right),
                    ],
                  )),
            ],
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name: 'Rapport_FNE_${DateFormat('yyyyMMdd').format(now)}',
    );
  }

  // ── Export CSV ────────────────────────────────────────────────────────────
  Future<void> exportCsv(List<FneRecord> records) async {
    final now = DateTime.now();
    final totalCA = records.fold(0.0, (s, r) => s + r.totalTTC);

    // ── Lignes "en-tête rapport" (miroir du PDF) ──────────────────────────────
    final infoRows = <List<String>>[
      ['RAPPORT FNE — FACTURES CERTIFIÉES', '', '', '', '', '', '', ''],
      ['Généré le', AppFormatters.date(now), '', '', '', '', '', ''],
      ['', '', '', '', '', '', '', ''],
      ['Total FNE certifiées', '${records.length}', '', '', '', '', '', ''],
      ["Chiffre d'affaire certifié", _fmtAmount(totalCA), '', '', '', '', '', ''],
      ['', '', '', '', '', '', '', ''],
      // ── En-têtes colonnes ──
      ['Client', 'Date', 'Référence FNE', 'Montant TTC', 'Type', 'Téléphone', 'Email', 'NCC'],
    ];

    // ── Lignes de données ─────────────────────────────────────────────────────
    final dataRows = records.map((r) {
      final inv = r.invoice;
      return [
        r.clientName,
        AppFormatters.date(r.createdAt),
        r.fneNumber ?? '—',
        _fmtAmount(r.totalTTC),
        inv.template,
        inv.clientPhone ?? '',
        inv.clientEmail ?? '',
        inv.clientNcc ?? '',
      ];
    }).toList();

    await to_csv.myCSV(
      ['Client', 'Date', 'Référence FNE', 'Montant TTC', 'Type', 'Téléphone', 'Email', 'NCC'],
      [...infoRows, ...dataRows],
      setHeadersInFirstRow: false,
      includeNoRow: false,
      fileName: 'Rapport_FNE_${DateFormat('yyyyMMdd_HHmm').format(now)}',
    );
  }

  // ── Partage natif d'une FNE ───────────────────────────────────────────────
  Future<void> shareFne(FneRecord record) async {
    final lines = [
      'FNE Express — Facture Normalisée Électronique',
      'Client : ${record.clientName}',
      'Référence : ${record.fneNumber ?? 'N/A'}',
      'Date : ${AppFormatters.date(record.createdAt)}',
      'Total TTC : ${AppFormatters.currency(record.totalTTC)}',
      if (record.qrCode != null) ...[
        '',
        'Vérifier : ${record.qrCode}',
      ],
    ];
    await Share.share(
      lines.join('\n'),
      subject: 'FNE — ${record.clientName}',
    );
  }

  // ── Helpers PDF ───────────────────────────────────────────────────────────
  pw.Widget _tableHeader(String text) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
        child: pw.Text(text,
            style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 8,
                fontWeight: pw.FontWeight.bold)),
      );

  pw.Widget _tableCell(String text,
          {pw.TextAlign align = pw.TextAlign.left}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: pw.Text(text,
            style: const pw.TextStyle(fontSize: 8),
            textAlign: align),
      );

  pw.Widget _totalRow(String label, String value, {bool bold = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(label,
                style: pw.TextStyle(
                    fontSize: 10,
                    color: PdfColors.grey700,
                    fontWeight:
                        bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight:
                        bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          ],
        ),
      );

  pw.Widget _statBox(String label, String value) => pw.Expanded(
        child: pw.Container(
          padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
          decoration: pw.BoxDecoration(
            // color: PdfColor.fromInt(0xFF036F4F).shade(0.1),
            border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
            borderRadius: pw.BorderRadius.circular(4),
          ),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(value,
                  style: pw.TextStyle(
                      fontSize: 11, fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromInt(0xFF036F4F))),
              pw.Text(label,
                  style: const pw.TextStyle(
                      fontSize: 8, color: PdfColors.grey600)),
            ],
          ),
        ),
      );

  String _fmtAmount(double v) =>
      NumberFormat.currency(locale: 'fr_FR', symbol: 'F', decimalDigits: 0)
          .format(v);

  String _formatQty(double q) =>
      q % 1 == 0 ? q.toInt().toString() : q.toStringAsFixed(2);


}
