import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import '../models/extracted_invoice.dart';

class FneApiResult {
  final bool success;
  final String? draftId;
  final String? fneNumber;
  final String? qrCode;
  final String? pdfUrl;
  final String? errorMessage;

  FneApiResult({
    required this.success,
    this.draftId,
    this.fneNumber,
    this.qrCode,
    this.pdfUrl,
    this.errorMessage,
  });
}

class FneApiService extends GetxService {
  late Dio _dio;

  String get _baseUrl =>
      dotenv.env['FNE_API_BASE_URL'] ?? 'https://api.fne.dgi.gouv.ci/v1';
  String get _apiKey => dotenv.env['FNE_API_KEY'] ?? '';
  String get _vendorNif => dotenv.env['FNE_VENDOR_NIF'] ?? '';
  bool get _isMockMode => _apiKey.isEmpty || _apiKey == 'YOUR_FNE_API_KEY';

  @override
  void onInit() {
    super.onInit();
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
    ));
  }

  /// Étape 1 : Soumettre les données de la facture pour pré-validation
  Future<FneApiResult> submitInvoiceStep1(ExtractedInvoice invoice) async {
    if (_isMockMode) {
      await Future.delayed(const Duration(seconds: 1));
      return FneApiResult(
        success: true,
        draftId: 'DRAFT_${DateTime.now().millisecondsSinceEpoch}',
      );
    }

    try {
      final body = {
        'fournisseur': {'nif': _vendorNif},
        'client': {'nom': invoice.clientName ?? 'Client inconnu'},
        'date_facture': invoice.date?.toIso8601String().split('T')[0] ??
            DateTime.now().toIso8601String().split('T')[0],
        'numero_facture_origine': invoice.invoiceNumber,
        'lignes': invoice.items
            .map((item) => {
                  'designation': item.designation,
                  'quantite': item.quantity,
                  'prix_unitaire_ht': item.unitPrice,
                  'taux_tva': item.tvaRate,
                  'remise': item.discount,
                })
            .toList(),
        'total_ht': invoice.totalHT,
        'total_tva': invoice.totalTVA,
        'total_ttc': invoice.totalTTC,
      };

      final response = await _dio.post('/factures', data: body);
      return FneApiResult(
        success: true,
        draftId: response.data['id']?.toString(),
      );
    } on DioException catch (e) {
      return FneApiResult(success: false, errorMessage: _extractError(e));
    } catch (e) {
      return FneApiResult(success: false, errorMessage: 'Erreur inattendue: $e');
    }
  }

  /// Étape 2 : Confirmer le brouillon et générer la FNE officielle
  Future<FneApiResult> confirmAndGenerateStep2(
      String draftId, ExtractedInvoice invoice) async {
    if (_isMockMode) {
      await Future.delayed(const Duration(seconds: 2));
      final ts = DateTime.now().millisecondsSinceEpoch.toString();
      final fneNumber =
          'FNE-CI-${DateTime.now().year}-${ts.substring(ts.length - 6)}';
      return FneApiResult(
        success: true,
        fneNumber: fneNumber,
        qrCode: 'https://fne.dgi.gouv.ci/verify/$fneNumber',
        pdfUrl: null,
      );
    }

    try {
      final response = await _dio.post(
        '/factures/$draftId/valider',
        data: {'confirme': true},
      );
      return FneApiResult(
        success: true,
        fneNumber: response.data['numero_fne']?.toString(),
        qrCode: response.data['qr_code']?.toString(),
        pdfUrl: response.data['pdf_url']?.toString(),
      );
    } on DioException catch (e) {
      return FneApiResult(success: false, errorMessage: _extractError(e));
    } catch (e) {
      return FneApiResult(success: false, errorMessage: 'Erreur inattendue: $e');
    }
  }

  static String _extractError(DioException e) {
    if (e.response?.data is Map) {
      return e.response?.data['message']?.toString() ??
          e.response?.data['error']?.toString() ??
          'Erreur API (${e.response?.statusCode})';
    }
    return 'Erreur réseau: ${e.message}';
  }
}
