import 'dart:convert';
import 'invoice_item.dart';

class ExtractedInvoice {
  String? clientName;
  DateTime? date;
  String? invoiceNumber;
  List<InvoiceItem> items;
  double tvaRate;

  ExtractedInvoice({
    this.clientName,
    this.date,
    this.invoiceNumber,
    List<InvoiceItem>? items,
    this.tvaRate = 0.18,
  }) : items = items ?? [];

  double get totalHT => items.fold(0, (s, i) => s + i.amountHT);
  double get totalTVA => items.fold(0, (s, i) => s + i.amountTVA);
  double get totalTTC => items.fold(0, (s, i) => s + i.amountTTC);

  Map<String, dynamic> toJson() => {
        'clientName': clientName,
        'date': date?.toIso8601String(),
        'invoiceNumber': invoiceNumber,
        'items': items.map((i) => i.toJson()).toList(),
        'tvaRate': tvaRate,
      };

  factory ExtractedInvoice.fromJson(Map<String, dynamic> json) {
    DateTime? parsedDate;
    if (json['date'] != null) {
      try {
        parsedDate = DateTime.parse(json['date'].toString());
      } catch (_) {}
    }
    final rawItems = json['items'];
    List<InvoiceItem> items = [];
    if (rawItems is List) {
      items = rawItems
          .whereType<Map<String, dynamic>>()
          .map((e) => InvoiceItem.fromJson(e))
          .toList();
    }
    return ExtractedInvoice(
      clientName: json['clientName']?.toString(),
      date: parsedDate,
      invoiceNumber: json['invoiceNumber']?.toString(),
      items: items,
      tvaRate: toDoubleValue(json['tvaRate'], defaultVal: 0.18),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory ExtractedInvoice.fromJsonString(String s) =>
      ExtractedInvoice.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
