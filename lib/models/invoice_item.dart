/// Converts a dynamic value to double, returning [defaultVal] if null or unparseable.
double toDoubleValue(dynamic val, {double defaultVal = 0.0}) {
  if (val == null) return defaultVal;
  if (val is double) return val;
  if (val is int) return val.toDouble();
  return double.tryParse(val.toString()) ?? defaultVal;
}

class InvoiceItem {
  String designation;
  double quantity;
  double unitPrice;
  double tvaRate;
  double discount;

  InvoiceItem({
    required this.designation,
    required this.quantity,
    required this.unitPrice,
    this.tvaRate = 0.18,
    this.discount = 0.0,
  });

  double get amountHT => quantity * unitPrice * (1 - discount);
  double get amountTVA => amountHT * tvaRate;
  double get amountTTC => amountHT + amountTVA;

  Map<String, dynamic> toJson() => {
        'designation': designation,
        'quantity': quantity,
        'unitPrice': unitPrice,
        'tvaRate': tvaRate,
        'discount': discount,
      };

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
        designation: (json['designation'] ?? '').toString(),
        quantity: toDoubleValue(json['quantity']),
        unitPrice: toDoubleValue(json['unitPrice']),
        tvaRate: toDoubleValue(json['tvaRate'], defaultVal: 0.18),
        discount: toDoubleValue(json['discount']),
      );

  InvoiceItem copyWith({
    String? designation,
    double? quantity,
    double? unitPrice,
    double? tvaRate,
    double? discount,
  }) =>
      InvoiceItem(
        designation: designation ?? this.designation,
        quantity: quantity ?? this.quantity,
        unitPrice: unitPrice ?? this.unitPrice,
        tvaRate: tvaRate ?? this.tvaRate,
        discount: discount ?? this.discount,
      );
}
