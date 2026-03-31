import 'dart:convert';
import 'extracted_invoice.dart';
import 'invoice_item.dart';

enum FneStatus { brouillon, echec, certifiee }

class FneRecord {
  final String id;
  final DateTime createdAt;
  final String clientName;
  final double totalTTC;
  final String? fneNumber;
  final String? qrCode;
  final String? pdfPath;
  /// Chemin du fichier source importé (image ou PDF original avant certification)
  final String? sourcePath;
  final ExtractedInvoice invoice;
  final FneStatus status;

  FneRecord({
    required this.id,
    required this.createdAt,
    required this.clientName,
    required this.totalTTC,
    this.fneNumber,
    this.qrCode,
    this.pdfPath,
    this.sourcePath,
    required this.invoice,
    this.status = FneStatus.certifiee,
  });

  FneRecord copyWith({
    String? clientName,
    double? totalTTC,
    String? fneNumber,
    String? qrCode,
    String? pdfPath,
    String? sourcePath,
    FneStatus? status,
    ExtractedInvoice? invoice,
  }) =>
      FneRecord(
        id: id,
        createdAt: createdAt,
        clientName: clientName ?? this.clientName,
        totalTTC: totalTTC ?? this.totalTTC,
        fneNumber: fneNumber ?? this.fneNumber,
        qrCode: qrCode ?? this.qrCode,
        pdfPath: pdfPath ?? this.pdfPath,
        sourcePath: sourcePath ?? this.sourcePath,
        invoice: invoice ?? this.invoice,
        status: status ?? this.status,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'clientName': clientName,
        'totalTTC': totalTTC,
        'fneNumber': fneNumber,
        'qrCode': qrCode,
        'pdfPath': pdfPath,
        'sourcePath': sourcePath,
        'invoice': invoice.toJson(),
        'status': status.name,
      };

  factory FneRecord.fromJson(Map<String, dynamic> json) => FneRecord(
        id: json['id']?.toString() ?? '',
        createdAt: DateTime.parse(json['createdAt'].toString()),
        clientName: json['clientName']?.toString() ?? '',
        totalTTC: toDoubleValue(json['totalTTC']),
        fneNumber: json['fneNumber']?.toString(),
        qrCode: json['qrCode']?.toString(),
        pdfPath: json['pdfPath']?.toString(),
        sourcePath: json['sourcePath']?.toString(),
        invoice: ExtractedInvoice.fromJson(
            (json['invoice'] as Map<String, dynamic>?) ?? {}),
        // Rétrocompat : ancien enregistrement sans statut → certifiée
        status: _statusFromString(json['status']?.toString()),
      );

  static FneStatus _statusFromString(String? s) {
    switch (s) {
      case 'brouillon':
        return FneStatus.brouillon;
      case 'echec':
        return FneStatus.echec;
      default:
        return FneStatus.certifiee;
    }
  }

  String toJsonString() => jsonEncode(toJson());

  factory FneRecord.fromJsonString(String s) =>
      FneRecord.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
