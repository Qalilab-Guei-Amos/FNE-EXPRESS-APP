import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import '../models/extracted_invoice.dart';

class FneApiResult {
  final bool success;
  final String? fneNumber;
  final String? qrCode;
  final String? errorMessage;

  FneApiResult({
    required this.success,
    this.fneNumber,
    this.qrCode,
    this.errorMessage,
  });
}

// Données vendeur fixes pour la v1
const String kPointOfSale   = 'AMANI DIGITAL SERVICES';
const String kEstablishment = 'AMANI DIGITAL SERVICES';
const String kSellerName    = 'AMANI DIGITAL SERVICES';

class FneApiService extends GetxService {
  late Dio _dio;

  String get _baseUrl =>
      dotenv.env['FNE_API_BASE_URL'] ?? 'http://54.247.95.108/ws';

  String get _apiKey => dotenv.env['FNE_API_KEY'] ?? '';

  bool get _isMockMode => _apiKey.isEmpty || _apiKey == 'YOUR_FNE_API_KEY';

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 60),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );
    // Intercepteur : baseUrl et token lus dynamiquement depuis les settings
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          options.baseUrl = _baseUrl;
          options.headers['Authorization'] = 'Bearer $_apiKey';
          handler.next(options);
        },
      ),
    );
  }

  /// Certification de la facture — POST /external/invoices/sign
  Future<FneApiResult> signInvoice(ExtractedInvoice invoice) async {
    if (_isMockMode) {
      print('[FneApi] Mode mock actif — simulation de la certification');
      await Future.delayed(const Duration(seconds: 2));
      final ts = DateTime.now().millisecondsSinceEpoch.toString();
      final ref =
          'FNE-CI-${DateTime.now().year}-${ts.substring(ts.length - 6)}';
      final token = 'http://54.247.95.108/fr/verification/mock-$ref';
      print('[FneApi] Mock réponse — reference: $ref, token: $token');
      return FneApiResult(success: true, fneNumber: ref, qrCode: token);
    }

    try {
      final body = {
        'invoiceType': 'sale',
        'paymentMethod': invoice.paymentMethod,
        'template': invoice.template,
        'isRne': invoice.isRne,
        if (invoice.isRne && invoice.rne != null && invoice.rne!.isNotEmpty)
          'rne': invoice.rne,
        if (invoice.invoiceNumber != null && invoice.invoiceNumber!.isNotEmpty)
          'invoiceNumber': invoice.invoiceNumber,
        if (invoice.template == 'B2B' &&
            invoice.clientNcc != null &&
            invoice.clientNcc!.isNotEmpty)
          'clientNcc': invoice.clientNcc,
        if (invoice.clientName != null && invoice.clientName!.isNotEmpty)
          'clientCompanyName': invoice.clientName,
        if (invoice.clientPhone != null && invoice.clientPhone!.isNotEmpty)
          'clientPhone': invoice.clientPhone,
        if (invoice.clientEmail != null && invoice.clientEmail!.isNotEmpty)
          'clientEmail': invoice.clientEmail,
        'clientSellerName': kSellerName,
        'pointOfSale': kPointOfSale,
        'establishment': kEstablishment,
        if (invoice.foreignCurrency.isNotEmpty) ...{
          'foreignCurrency': invoice.foreignCurrency,
          'foreignCurrencyRate': invoice.foreignCurrencyRate,
        },
        'items': invoice.items
            .map(
              (item) => {
                'taxes': item.taxesCodes,
                'customTaxes': [],
                'reference': '',
                'description': item.designation,
                'quantity': item.quantity % 1 == 0
                    ? item.quantity.toInt()
                    : item.quantity,
                'amount': item.unitPrice,
                'discount': 0,
                'measurementUnit': '',
              },
            )
            .toList(),
        'customTaxes': [],
        'discount': 0,
      };

      print('[FneApi] Envoi de la requête de certification');
      print('[FneApi] Body: $body');

      final response = await _dio.post('/external/invoices/sign', data: body);

      print(
        '[FneApi] Réponse reçue (${response.statusCode}): ${response.data}',
      );

      final ref = response.data['reference']?.toString();
      final token = response.data['token']?.toString();

      return FneApiResult(success: true, fneNumber: ref, qrCode: token);
    } on DioException catch (e) {
      final msg = _extractError(e);
      print('[FneApi] Erreur DioException: $msg');
      return FneApiResult(success: false, errorMessage: msg);
    } catch (e) {
      print('[FneApi] Erreur inattendue: $e');
      return FneApiResult(
        success: false,
        errorMessage: 'Erreur inattendue: $e',
      );
    }
  }

  static String _extractError(DioException e) {
    final data = e.response?.data;
    print(
      '[FneApi] Réponse erreur complète (${e.response?.statusCode}): $data',
    );
    if (data is Map) {
      final msg =
          data['message']?.toString() ??
          data['error']?.toString() ??
          data['errors']?.toString();
      if (msg != null) return '$msg (${e.response?.statusCode})';
      return 'Erreur API (${e.response?.statusCode}): $data';
    }
    if (data is String && data.isNotEmpty) {
      return 'Erreur API (${e.response?.statusCode}): $data';
    }
    return 'Erreur réseau: ${e.message}';
  }
}
