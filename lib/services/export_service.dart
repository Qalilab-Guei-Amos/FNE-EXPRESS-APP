import 'dart:io';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import '../models/fne_record.dart';
import '../core/utils/formatters.dart';
import '../views/fne_result/fne_pdf_view_screen.dart';
import '../controllers/settings_controller.dart';

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
                pw.Text(
                  'FACTURE NORMALISÉE ÉLECTRONIQUE',
                  style: pw.TextStyle(
                    color: PdfColors.white,
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 4),
                if (record.fneNumber != null)
                  pw.Text(
                    record.fneNumber!,
                    style: const pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 11,
                    ),
                  ),
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
                    pw.Text(
                      'CLIENT',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      record.clientName,
                      style: pw.TextStyle(
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    if (inv.clientPhone != null)
                      pw.Text(
                        inv.clientPhone!,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    if (inv.clientEmail != null)
                      pw.Text(
                        inv.clientEmail!,
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    if (inv.clientNcc != null && inv.clientNcc!.isNotEmpty)
                      pw.Text(
                        'NCC: ${inv.clientNcc}',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                  ],
                ),
              ),
              pw.SizedBox(width: 20),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'DATE',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Text(
                    AppFormatters.date(record.createdAt),
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                  pw.SizedBox(height: 8),
                  pw.Text(
                    'TYPE',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.Text(
                    inv.template,
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
          pw.SizedBox(height: 20),
          pw.Divider(),
          pw.SizedBox(height: 10),

          // Tableau articles
          pw.Text(
            'ARTICLES',
            style: pw.TextStyle(
              fontSize: 9,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.grey600,
            ),
          ),
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
                  color: PdfColor.fromInt(0xFF036F4F),
                ),
                children: [
                  _tableHeader('Désignation'),
                  _tableHeader('Qté'),
                  _tableHeader('P.U. HT'),
                  _tableHeader('TVA'),
                  _tableHeader('Total TTC'),
                ],
              ),
              // Lignes articles
              ...inv.items.map(
                (item) => pw.TableRow(
                  children: [
                    _tableCell(item.designation),
                    _tableCell(
                      _formatQty(item.quantity),
                      align: pw.TextAlign.left,
                    ),
                    _tableCell(
                      _fmtAmount(item.unitPrice),
                      align: pw.TextAlign.left,
                    ),
                    _tableCell(item.taxCode, align: pw.TextAlign.left),
                    _tableCell(
                      _fmtAmount(item.amountTTC),
                      align: pw.TextAlign.left,
                    ),
                  ],
                ),
              ),
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
                  _totalRow(
                    'Total TTC',
                    _fmtAmount(record.totalTTC),
                    bold: true,
                  ),
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
                  pw.Text(
                    'Vérification FNE',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.grey600,
                    ),
                  ),
                  pw.SizedBox(height: 4),
                  pw.Text(
                    record.qrCode!,
                    style: const pw.TextStyle(
                      fontSize: 9,
                      color: PdfColors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (_) async => pdf.save(),
      name:
          'FNE_${record.clientName}_${DateFormat('yyyyMMdd').format(record.createdAt)}',
    );
  }

  // ── Rapport PDF (liste filtrée) ───────────────────────────────────────────
  Future<void> exportReportPdf(
    List<FneRecord> records, {
    String title = 'RAPPORT FINANCIER',
    String? period,
    bool landscape = true,
  }) async {
    final pdf = pw.Document();
    final now = DateTime.now();
    final settings = Get.find<SettingsController>();

    final totalCA = records
        .where((r) => r.status == FneStatus.certifiee)
        .fold(0.0, (s, r) => s + r.totalTTC);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: landscape ? PdfPageFormat.a4.landscape : PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(35),
        header: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      settings.establishmentCtrl.text.toUpperCase(),
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.grey800,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      title,
                      style: pw.TextStyle(
                        fontSize: 26,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColor.fromInt(0xFF036F4F),
                      ),
                    ),
                    if (period != null) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Période : $period',
                        style: pw.TextStyle(
                          fontSize: 12,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Généré le ${AppFormatters.date(now)}',
                      style: const pw.TextStyle(
                        fontSize: 10,
                        color: PdfColors.grey600,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'Par FNE Express',
                      style: pw.TextStyle(
                        fontSize: 8,
                        color: PdfColors.grey400,
                        fontStyle: pw.FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Row(
              children: [
                _statBox(
                  'Factures certifiées',
                  '${records.length} FNE',
                  size: 14,
                ),
                pw.SizedBox(width: 20),
                _statBox(
                  'CHIFFRE D\'AFFAIRE TOTAL',
                  _fmtAmount(totalCA),
                  size: 14,
                ),
              ],
            ),
            pw.SizedBox(height: 20),
            pw.Divider(thickness: 1.5, color: PdfColor.fromInt(0xFF036F4F)),
            pw.SizedBox(height: 15),
          ],
        ),
        build: (ctx) => [
          pw.Table(
            border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
            columnWidths: {
              0: const pw.FlexColumnWidth(2.5), // Client
              1: const pw.FlexColumnWidth(1.2), // Date
              2: const pw.FlexColumnWidth(2.0), // Référence
              3: const pw.FlexColumnWidth(1.3), // Montant
              4: const pw.FlexColumnWidth(0.6), // Type
              5: const pw.FlexColumnWidth(1.2), // Tél
              6: const pw.FlexColumnWidth(1.8), // Email
              7: const pw.FlexColumnWidth(1.0), // NCC
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromInt(0xFF036F4F),
                ),
                children: [
                  _tableHeader('Client', size: 9),
                  _tableHeader('Date', size: 9),
                  _tableHeader('Référence FNE', size: 9),
                  _tableHeader('Total TTC', size: 9),
                  _tableHeader('Type', size: 9),
                  _tableHeader('Tél', size: 9),
                  _tableHeader('Email', size: 9),
                  _tableHeader('NCC', size: 9),
                ],
              ),
              ...records.map(
                (r) {
                  final inv = r.invoice;
                  return pw.TableRow(
                    children: [
                      _tableCell(r.clientName, size: 7.5),
                      _tableCell(AppFormatters.date(r.createdAt), size: 7.5),
                      _tableCell(r.fneNumber ?? '—', size: 7.5),
                      _tableCell(_fmtAmount(r.totalTTC), size: 7.5),
                      _tableCell(inv.template, size: 7.5),
                      _tableCell(inv.clientPhone ?? '—', size: 7.5),
                      _tableCell(inv.clientEmail ?? '—', size: 7.5),
                      _tableCell(inv.clientNcc ?? '—', size: 7.5),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );

    // ── Enregistrement silencieux et affichage direct ────────────────────────
    try {
      final bytes = await pdf.save();
      final dir = await getTemporaryDirectory();
      final fileName =
          'Rapport_FNE_${DateFormat('yyyyMMdd_HHmm').format(now)}.pdf';
      final file = File('${dir.path}/$fileName');

      await file.writeAsBytes(bytes);

      // Ouvrir l'écran de visualisation PDF interne sans passer par l'aperçu système
      Get.to(
        () =>
            FnePdfViewScreen(path: file.path, title: title, fromHistory: true),
      );
    } catch (e) {
      Get.snackbar(
        'Erreur d\'exportation',
        'Impossible de générer le rapport PDF.',
      );
    }
  }

  // ── Export EXCEL / XLSX ──────────────────────────────────────────────────
  Future<void> exportCsv(List<FneRecord> records, {String title = 'RAPPORT FINANCIER', String? period}) async {
    final now = DateTime.now();
    final settings = Get.find<SettingsController>();
    final totalCA = records.fold(0.0, (s, r) => s + r.totalTTC);

    // ── En-têtes colonnes ──
    final headers = ['Client', 'Date', 'Référence FNE', 'Montant TTC', 'Type', 'Téléphone', 'Email', 'NCC'];

    // ── Lignes de données ──
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



    // ── GÉNÉRATION XLSX (Syncfusion) ──
    try {
      final xlsio.Workbook workbook = xlsio.Workbook();
      final xlsio.Worksheet sheet = workbook.worksheets[0];
      
      // Style en-tête (Vert émeraude FNE)
      final xlsio.Style headerStyle = workbook.styles.add('headerStyle');
      headerStyle.bold = true;
      headerStyle.backColor = '#036F4F';
      headerStyle.fontColor = '#FFFFFF';

      // Ajustement de la largeur des colonnes (en pixels)
      sheet.setColumnWidthInPixels(1, 220); // Client
      sheet.setColumnWidthInPixels(2, 100); // Date
      sheet.setColumnWidthInPixels(3, 180); // Référence
      sheet.setColumnWidthInPixels(4, 135); // Montant
      sheet.setColumnWidthInPixels(5, 80);  // Type
      sheet.setColumnWidthInPixels(6, 130); // Tél
      sheet.setColumnWidthInPixels(7, 250); // Email
      sheet.setColumnWidthInPixels(8, 110); // NCC

      int rowIndex = 1;

      // Infos établissement
      sheet.getRangeByIndex(rowIndex, 1).setText(settings.establishmentCtrl.text.toUpperCase());
      rowIndex++;
      sheet.getRangeByIndex(rowIndex, 1).setText(title);
      rowIndex++;
      if (period != null) {
        sheet.getRangeByIndex(rowIndex, 1).setText('Période : $period');
        rowIndex++;
      }
      sheet.getRangeByIndex(rowIndex, 1).setText('Généré le ${AppFormatters.date(now)} à ${DateFormat('HH:mm').format(now)}');
      rowIndex++;
      sheet.getRangeByIndex(rowIndex, 1).setText('Par FNE Express System');
      rowIndex += 2;

      // Statistiques
      sheet.getRangeByIndex(rowIndex, 1).setText('STATISTIQUES DU RAPPORT');
      rowIndex++;
      sheet.getRangeByIndex(rowIndex, 1).setText('Factures certifiées : ${records.length} FNE');
      rowIndex++;
      sheet.getRangeByIndex(rowIndex, 1).setText('CHIFFRE D\'AFFAIRE TOTAL : ${_fmtAmount(totalCA)}');
      rowIndex += 2;

      // Headers du tableau
      for (int i = 0; i < headers.length; i++) {
        final cell = sheet.getRangeByIndex(rowIndex, i + 1);
        cell.setText(headers[i]);
        cell.cellStyle = headerStyle;
      }
      rowIndex++;

      // Remplissage des données
      for (var r in dataRows) {
        for (int i = 0; i < r.length; i++) {
          sheet.getRangeByIndex(rowIndex, i + 1).setText(r[i]);
        }
        rowIndex++;
      }

      // Sauvegarde physique .xlsx
      final List<int> bytes = workbook.saveAsStream();
      workbook.dispose();

      final dir = await getTemporaryDirectory();
      final fileName = 'Rapport_FNE_${DateFormat('yyyyMMdd').format(now)}.xlsx';
      final file = File('${dir.path}/$fileName');
      await file.writeAsBytes(bytes);

      // ── PARTAGE DIRECT DU FICHIER XLSX ──
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Rapport Financier - ${settings.establishmentCtrl.text}',
      );
    } catch (e) {
      Get.snackbar('Erreur Excel', 'Impossible de générer le fichier .xlsx');
    }
  }

  // ── Partage natif d'une FNE ───────────────────────────────────────────────
  Future<void> shareFne(FneRecord record) async {
    final lines = [
      'FNE Express — Facture Normalisée Électronique',
      'Client : ${record.clientName}',
      'Référence : ${record.fneNumber ?? 'N/A'}',
      'Date : ${AppFormatters.date(record.createdAt)}',
      'Total TTC : ${AppFormatters.currency(record.totalTTC)}',
      if (record.qrCode != null) ...['', 'Vérifier : ${record.qrCode}'],
    ];
    await Share.share(lines.join('\n'), subject: 'FNE — ${record.clientName}');
  }

  // ── Helpers PDF ───────────────────────────────────────────────────────────
  pw.Widget _tableHeader(String text, {double size = 8}) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 5),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        color: PdfColors.white,
        fontSize: size,
        fontWeight: pw.FontWeight.bold,
      ),
    ),
  );

  pw.Widget _tableCell(
    String text, {
    pw.TextAlign align = pw.TextAlign.left,
    double size = 8,
  }) => pw.Padding(
    padding: const pw.EdgeInsets.symmetric(horizontal: 6, vertical: 4),
    child: pw.Text(
      text,
      style: pw.TextStyle(fontSize: size),
      textAlign: align,
    ),
  );

  pw.Widget _totalRow(String label, String value, {bool bold = false}) =>
      pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ],
        ),
      );

  pw.Widget _statBox(String label, String value, {double size = 11}) =>
      pw.Expanded(
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
              pw.Text(
                value,
                style: pw.TextStyle(
                  fontSize: size,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColor.fromInt(0xFF036F4F),
                ),
              ),
              pw.Text(
                label,
                style: pw.TextStyle(
                  fontSize: size - 3,
                  color: PdfColors.grey600,
                ),
              ),
            ],
          ),
        ),
      );

  String _fmtAmount(double v) => NumberFormat.currency(
    locale: 'fr_FR',
    symbol: 'F',
    decimalDigits: 0,
  ).format(v);

  String _formatQty(double q) =>
      q % 1 == 0 ? q.toInt().toString() : q.toStringAsFixed(2);
}
