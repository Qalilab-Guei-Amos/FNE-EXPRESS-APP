import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:googleai_dart/googleai_dart.dart';
import '../models/extracted_invoice.dart';

class GeminiService extends GetxService {
  late GoogleAIClient _client;

  @override
  void onInit() {
    super.onInit();
    _client = GoogleAIClient(
      config: GoogleAIConfig(
        authProvider: ApiKeyProvider(dotenv.env['GEMINI_API_KEY'] ?? ''),
      ),
    );
  }

  @override
  void onClose() {
    _client.close();
    super.onClose();
  }

  String get _model => dotenv.env['GEMINI_MODEL'] ?? 'gemini-1.5-flash';

  static const String _prompt =
      'Tu es un assistant d\'extraction de données de factures. '
      'Analyse cette facture et extrait toutes les informations.\n'
      'Réponds UNIQUEMENT avec un objet JSON valide, sans markdown, '
      'sans explication, avec exactement cette structure:\n'
      '{\n'
      '  "clientName": "nom du magasin client (ex: Auchan, Prosuma, Casino, etc.) ou null si non trouvé",\n'
      '  "date": "date au format YYYY-MM-DD ou null si non trouvée",\n'
      '  "invoiceNumber": "numéro de la facture ou null",\n'
      '  "tvaRate": 0.18,\n'
      '  "items": [\n'
      '    {\n'
      '      "designation": "désignation du produit",\n'
      '      "quantity": 1,\n'
      '      "unitPrice": 0,\n'
      '      "tvaRate": 0.18,\n'
      '      "discount": 0\n'
      '    }\n'
      '  ]\n'
      '}\n'
      'Notes: TVA standard CI = 18% (0.18). Prix en FCFA. '
      'discount = pourcentage décimal. Extrais TOUS les articles.';

  Future<ExtractedInvoice> extractFromBytes(
      Uint8List bytes, String mimeType) async {
    final request = GenerateContentRequest(
      contents: [
        Content.user([
          Part.text(_prompt),
          Part.bytes(bytes, mimeType),
        ]),
      ],
      generationConfig: const GenerationConfig(
        temperature: 0.1,
        topK: 1,
        topP: 0.8,
        maxOutputTokens: 2048,
      ),
    );

    final response = await _client.models.generateContent(
      model: _model,
      request: request,
    );

    final text = response.text ?? '';
    final cleaned = text
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final jsonData = jsonDecode(cleaned) as Map<String, dynamic>;
    return ExtractedInvoice.fromJson(jsonData);
  }
}
