import 'dart:convert';
import 'extracted_invoice.dart';
import 'invoice_item.dart';

class FneRecord {
  final String id;
  final DateTime createdAt;
  final String clientName;
  final double totalTTC;
  final String? fneNumber;
  final String? qrCode;
  final String? pdfPath;
  final ExtractedInvoice invoice;

  FneRecord({
    required this.id,
    required this.createdAt,
    required this.clientName,
    required this.totalTTC,
    this.fneNumber,
    this.qrCode,
    this.pdfPath,
    required this.invoice,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'clientName': clientName,
        'totalTTC': totalTTC,
        'fneNumber': fneNumber,
        'qrCode': qrCode,
        'pdfPath': pdfPath,
        'invoice': invoice.toJson(),
      };

  factory FneRecord.fromJson(Map<String, dynamic> json) => FneRecord(
        id: json['id']?.toString() ?? '',
        createdAt: DateTime.parse(json['createdAt'].toString()),
        clientName: json['clientName']?.toString() ?? '',
        totalTTC: toDoubleValue(json['totalTTC']),
        fneNumber: json['fneNumber']?.toString(),
        qrCode: json['qrCode']?.toString(),
        pdfPath: json['pdfPath']?.toString(),
        invoice: ExtractedInvoice.fromJson(
            (json['invoice'] as Map<String, dynamic>?) ?? {}),
      );

  String toJsonString() => jsonEncode(toJson());

  factory FneRecord.fromJsonString(String s) =>
      FneRecord.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
