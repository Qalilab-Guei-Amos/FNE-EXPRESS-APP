import 'dart:convert';

class AppSettings {
  // Identité du vendeur / établissement
  String establishment;
  String pointOfSale;
  String sellerName;
  // Personnalisation de la facture
  String commercialMessage;
  String footer;
  // Préférences de facturation par défaut
  String defaultPaymentMethod;
  String defaultTemplate;

  AppSettings({
    this.establishment = '',
    this.pointOfSale = '',
    this.sellerName = '',
    this.commercialMessage = '',
    this.footer = '',
    this.defaultPaymentMethod = 'mobile-money',
    this.defaultTemplate = 'B2B',
  });

  Map<String, dynamic> toJson() => {
        'establishment': establishment,
        'pointOfSale': pointOfSale,
        'sellerName': sellerName,
        'commercialMessage': commercialMessage,
        'footer': footer,
        'defaultPaymentMethod': defaultPaymentMethod,
        'defaultTemplate': defaultTemplate,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        establishment: json['establishment']?.toString() ?? '',
        pointOfSale: json['pointOfSale']?.toString() ?? '',
        sellerName: json['sellerName']?.toString() ?? '',
        commercialMessage: json['commercialMessage']?.toString() ?? '',
        footer: json['footer']?.toString() ?? '',
        defaultPaymentMethod:
            json['defaultPaymentMethod']?.toString() ?? 'mobile-money',
        defaultTemplate: json['defaultTemplate']?.toString() ?? 'B2B',
      );

  String toJsonString() => jsonEncode(toJson());

  factory AppSettings.fromJsonString(String s) =>
      AppSettings.fromJson(jsonDecode(s) as Map<String, dynamic>);
}
