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
  final bool isSynced;
  final String? userId;

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
    this.isSynced = false,
    this.userId,
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
    bool? isSynced,
    String? userId,
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
        isSynced: isSynced ?? this.isSynced,
        userId: userId ?? this.userId,
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
        'isSynced': isSynced,
        'userId': userId,
      };

  factory FneRecord.fromJson(Map<String, dynamic> json) => FneRecord(
        id: json['id']?.toString() ?? '',
        createdAt: DateTime.parse((json['createdAt'] ?? json['created_at']).toString()),
        clientName: (json['clientName'] ?? json['client_name'])?.toString() ?? '',
        totalTTC: toDoubleValue(json['totalTTC'] ?? json['total_ttc']),
        fneNumber: (json['fneNumber'] ?? json['fne_number'])?.toString(),
        qrCode: (json['qrCode'] ?? json['qr_code'])?.toString(),
        pdfPath: (json['pdfPath'] ?? json['pdf_path'])?.toString(),
        sourcePath: (json['sourcePath'] ?? json['source_path'])?.toString(),
        userId: (json['userId'] ?? json['user_id'])?.toString(),
        invoice: ExtractedInvoice.fromJson(
            (json['invoice'] as Map<String, dynamic>?) ?? {}),
        // Rétrocompat : ancien enregistrement sans statut → certifiée
        status: _statusFromString(json['status']?.toString()),
        isSynced: json['isSynced'] == true,
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
