import 'dart:convert';
import 'invoice_item.dart';

/// Codes devise pour l'API FNE
const Map<String, String> kForeignCurrencies = {
  '':    'XOF — Franc CFA (défaut)',
  'USD': 'USD — Dollar Américain',
  'EUR': 'EUR — Euro',
  'JPY': 'JPY — Yen Japonais',
  'CAD': 'CAD — Dollar Canadien',
  'GBP': 'GBP — Livre Sterling',
  'AUD': 'AUD — Dollar Australien',
  'CNH': 'CNH — Yuan Chinois',
  'CHF': 'CHF — Franc Suisse',
  'HKD': 'HKD — Dollar Hong Kong',
  'NZD': 'NZD — Dollar Néo-Zélandais',
};

/// Type de prix détecté sur la facture originale
enum PriceType { ht, ttc }

class ExtractedInvoice {
  String? clientName;
  DateTime? date;
  String? invoiceNumber;
  List<InvoiceItem> items;
  double tvaRate;
  /// Type de prix de la facture d'origine (HT ou TTC)
  PriceType priceType;
  /// Total TTC tel qu'écrit sur la facture originale (pour vérification)
  double? originalTotalTTC;
  // Champs requis par l'API FNE
  String paymentMethod;
  String template;
  String? clientPhone;
  String? clientEmail;
  String? clientNcc;
  bool isRne;
  String? rne;
  /// Code devise étrangère (vide = XOF par défaut). Obligatoire si B2F.
  String foreignCurrency;
  /// Taux de change. Obligatoire si foreignCurrency non vide.
  double foreignCurrencyRate;

  ExtractedInvoice({
    this.clientName,
    this.date,
    this.invoiceNumber,
    List<InvoiceItem>? items,
    this.tvaRate = 0.18,
    this.priceType = PriceType.ht,
    this.originalTotalTTC,
    this.paymentMethod = 'mobile-money',
    this.template = 'B2B',
    this.clientPhone,
    this.clientEmail,
    this.clientNcc,
    this.isRne = false,
    this.rne,
    this.foreignCurrency = '',
    this.foreignCurrencyRate = 0,
  }) : items = items ?? [];

  double get totalHT  => items.fold(0.0, (s, i) => s + i.amountHT);
  double get totalTVA => items.fold(0.0, (s, i) => s + i.amountTVA);
  double get totalTTC => items.fold(0.0, (s, i) => s + i.amountTTC);

  Map<String, dynamic> toJson() => {
        'clientName': clientName,
        'date': date?.toIso8601String(),
        'invoiceNumber': invoiceNumber,
        'items': items.map((i) => i.toJson()).toList(),
        'tvaRate': tvaRate,
        'priceType': priceType.name,
        'originalTotalTTC': originalTotalTTC,
        'paymentMethod': paymentMethod,
        'template': template,
        'clientPhone': clientPhone,
        'clientEmail': clientEmail,
        'clientNcc': clientNcc,
        'isRne': isRne,
        'rne': rne,
        'foreignCurrency': foreignCurrency,
        'foreignCurrencyRate': foreignCurrencyRate,
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

    final tvaRate = toDoubleValue(json['tvaRate'], defaultVal: 0.18);

    PriceType priceType = PriceType.ht;
    final priceTypeRaw = json['priceType']?.toString().toLowerCase() ?? '';
    if (priceTypeRaw.contains('ttc')) priceType = PriceType.ttc;

    return ExtractedInvoice(
      clientName: json['clientName']?.toString(),
      date: parsedDate,
      invoiceNumber: json['invoiceNumber']?.toString(),
      items: items,
      tvaRate: tvaRate,
      priceType: priceType,
      originalTotalTTC: toDoubleValue(json['totalTTC']),
      paymentMethod: json['paymentMethod']?.toString() ?? 'mobile-money',
      template: json['template']?.toString() ?? 'B2B',
      clientPhone: json['clientPhone']?.toString(),
      clientEmail: json['clientEmail']?.toString(),
      clientNcc: json['clientNcc']?.toString(),
      isRne: json['isRne'] == true,
      rne: json['rne']?.toString(),
      foreignCurrency: json['foreignCurrency']?.toString() ?? '',
      foreignCurrencyRate: toDoubleValue(json['foreignCurrencyRate']),
    );
  }

  String toJsonString() => jsonEncode(toJson());

  factory ExtractedInvoice.fromJsonString(String s) =>
      ExtractedInvoice.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
