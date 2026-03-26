/// Converts a dynamic value to double, returning [defaultVal] if null or unparseable.
double toDoubleValue(dynamic val, {double defaultVal = 0.0}) {
  if (val == null) return defaultVal;
  if (val is double) return val;
  if (val is int) return val.toDouble();
  return double.tryParse(val.toString()) ?? defaultVal;
}

/// Codes TVA valides pour l'API FNE
const Map<String, double> kTaxRates = {
  'TVA': 0.18,   // TVA normal 18%
  'TVAB': 0.09,  // TVA réduit 9%
  'TVAC': 0.00,  // TVA exo. convention 0%
  'TVAD': 0.00,  // TVA exo. légal 0% (TEE/RME)
};

const Map<String, String> kTaxLabels = {
  'TVA':  'TVA — 18% (normal)',
  'TVAB': 'TVAB — 9% (réduit)',
  'TVAC': 'TVAC — 0% (exo. conv.)',
  'TVAD': 'TVAD — 0% (exo. légal)',
};

class InvoiceItem {
  String designation;
  double quantity;
  double unitPrice;
  /// Code TVA explicite : 'TVA', 'TVAB', 'TVAC', 'TVAD'
  String taxCode;

  InvoiceItem({
    required this.designation,
    required this.quantity,
    required this.unitPrice,
    this.taxCode = 'TVA',
  });

  double get tvaRate => kTaxRates[taxCode] ?? 0.18;

  double get amountHT  => quantity * unitPrice;
  double get amountTVA => amountHT * tvaRate;
  double get amountTTC => amountHT + amountTVA;

  /// Code TVA pour l'API FNE
  List<String> get taxesCodes => [taxCode];

  Map<String, dynamic> toJson() => {
        'designation': designation,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'taxCode': taxCode,
        'amountHT': amountHT,
        'amountTVA': amountTVA,
        'amountTTC': amountTTC,
      };

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    // Nouveau format : taxCode string
    String code = json['taxCode']?.toString() ?? '';
    if (code.isEmpty || !kTaxRates.containsKey(code)) {
      // Ancien format / extraction Gemini : dériver depuis tvaRate
      final rate = toDoubleValue(json['tvaRate'], defaultVal: 0.18);
      if (rate >= 0.18) {
        code = 'TVA';
      } else if (rate >= 0.09) {
        code = 'TVAB';
      } else {
        code = 'TVAC';
      }
    }
    return InvoiceItem(
      designation: (json['designation'] ?? '').toString(),
      quantity: toDoubleValue(json['quantity']),
      unitPrice: toDoubleValue(json['unitPrice']),
      taxCode: code,
    );
  }

  InvoiceItem copyWith({
    String? designation,
    double? quantity,
    double? unitPrice,
    String? taxCode,
  }) =>
      InvoiceItem(
        designation: designation ?? this.designation,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        taxCode: taxCode ?? this.taxCode,
      );
}
