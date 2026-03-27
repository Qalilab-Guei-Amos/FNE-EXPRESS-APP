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

  /// Liste ordonnée des modèles à essayer, lue depuis GEMINI_MODELS dans .env.
  /// Ex : "gemini-2.5-flash,gemini-2.0-flash,gemini-1.5-flash"
  List<String> get _models {
    final raw = dotenv.env['GEMINI_MODELS'] ?? '';
    final list = raw
        .split(',')
        .map((m) => m.trim())
        .where((m) => m.isNotEmpty)
        .toList();
    return list.isNotEmpty ? list : ['gemini-1.5-flash'];
  }

  static const String _prompt = '''
Tu es un expert en extraction de données de factures commerciales en Côte d'Ivoire.
Analyse attentivement cette facture (manuscrite ou imprimée) et extrais TOUTES les informations ci-dessous.

══════════════════════════════════════════════
RÈGLES SUR LES PRIX
══════════════════════════════════════════════
1. Identifie le type de colonne prix : "PU TTC" / "Prix TTC" → priceType = "TTC"
                                        "PU HT"  / "Prix HT"  → priceType = "HT"
2. unitPrice doit TOUJOURS être en HT :
   - Si colonne TTC  → unitPrice = valeur ÷ (1 + tvaRate)
   - Si colonne HT   → unitPrice = valeur telle quelle
3. taxCode par article selon les indications sur la facture :
   - "TVA"  : taux 18% (normal)
   - "TVAB" : taux 9% (réduit)
   - "TVAC" : taux 0% (exonéré convention)
   - "TVAD" : taux 0% (exonéré légal — TEE, RME) - par défaut si non précisé

══════════════════════════════════════════════
RÈGLES SUR LE CLIENT
══════════════════════════════════════════════
4. clientName   : nom de l'entreprise ou de la personne cliente (champ "Client", "Acheteur", "Vendu à", etc.)
5. clientPhone  : numéro de téléphone du client (cherche "Tél", "Tel", "N° Tel" "Mobile", "Contact")
6. clientEmail  : adresse e-mail du client (cherche "@")
7. clientNcc    : NCC / numéro fiscal du client (cherche "NCC", "CC N°", "CC:", "N° fiscal", "NIF", "Identifiant fiscal")

══════════════════════════════════════════════
RÈGLES SUR LE TYPE DE FACTURATION (template)
══════════════════════════════════════════════
8. Détermine le template selon le contexte :
   - "B2B" : vente à une entreprise (NCC présent, ou nom d'entreprise évident) — par défaut
   - "B2C" : vente à un particulier (nom de personne physique, pas de NCC)
   - "B2G" : vente à un organisme gouvernemental / public
   - "B2F" : vente internationale (devise étrangère présente ou client étranger)

10. Si template = "B2F" ou devise étrangère détectée :
   - foreignCurrency : code devise ("USD", "EUR", "JPY", "CAD", "GBP", "AUD", "CNH", "CHF", "HKD", "NZD"). Vide si FCFA.
   - foreignCurrencyRate : taux de change (ex: 655 pour EUR/XOF). 0 si non précisé ou FCFA.

══════════════════════════════════════════════
RÈGLES SUR LE MODE DE PAIEMENT (paymentMethod)
══════════════════════════════════════════════
9. Déduis le mode de paiement si mentionné sur la facture :
   - "mobile-money" : Mobile Money, MoMo, Orange Money, Wave, MTN Money
   - "cash"         : Espèces, Cash, Comptant
   - "card"         : Carte bancaire, CB, Visa, Mastercard
   - "check"        : Chèque
   - "transfer"     : Virement, Virement bancaire
   - "deferred"     : À terme, Crédit, Différé
   Par défaut → "mobile-money"

══════════════════════════════════════════════
FORMAT DE RÉPONSE
══════════════════════════════════════════════
Réponds UNIQUEMENT avec un objet JSON valide, sans markdown, sans explication :
{
  "clientName": "nom du client ou null",
  "clientPhone": "numéro de téléphone ou null",
  "clientEmail": "email ou null",
  "clientNcc": "NCC/NIF du client ou null",
  "date": "YYYY-MM-DD ou null",
  "invoiceNumber": "numéro de facture ou null",
  "priceType": "TTC ou HT",
  "tvaRate": 0.18,
  "totalTTC": 0,
  "template": "B2B ou B2C ou B2G ou B2F",
  "paymentMethod": "mobile-money ou cash ou card ou check ou transfer ou deferred",
  "foreignCurrency": "code devise ou chaine vide si FCFA",
  "foreignCurrencyRate": 0,
  "items": [
    {
      "designation": "désignation exacte du produit",
      "quantity": 1,
      "unitPrice": 0,
      "taxCode": "TVA ou TVAB ou TVAC ou TVAD"
    }
  ]
}

RAPPELS CRITIQUES :
- unitPrice = TOUJOURS en HT, converti si la facture affiche des prix TTC
- Extrais ABSOLUMENT TOUS les articles du tableau, sans en omettre aucun
- Les montants sont en FCFA sauf si devise étrangère détectée
- clientPhone : extrais uniquement les chiffres ou le format local (ex: "0709080765")
- taxCode par défaut = "TVA" si non précisé sur la facture
''';

  Future<ExtractedInvoice> extractFromBytes(
      Uint8List bytes, String mimeType) async {
    print('[Extraction] Démarrage — mimeType: $mimeType, taille: ${bytes.length} octets');

    final models = _models;
    Exception? lastError;

    for (int i = 0; i < models.length; i++) {
      final model = models[i];
      print('[Extraction] Tentative ${i + 1}/${models.length} avec le modèle: $model');
      try {
        return await _extractWithModel(model, bytes, mimeType);
      } on Exception catch (e) {
        print('[Extraction] Échec avec $model: $e');
        lastError = e;
      }
    }

    throw lastError ?? Exception('Extraction échouée — aucun modèle disponible.');
  }

  Future<ExtractedInvoice> _extractWithModel(
      String model, Uint8List bytes, String mimeType) async {
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
        maxOutputTokens: 8192,
        responseMimeType: 'application/json',
      ),
    );

    final response = await _client.models.generateContent(
      model: model,
      request: request,
    );

    final text = response.text ?? '';
    // print('[Extraction] Réponse brute reçue (${text.length} chars):\n$text');

    final cleaned = text
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    if (cleaned.isEmpty) {
      throw Exception('Réponse vide du modèle $model.');
    }

    Map<String, dynamic> jsonData;
    try {
      jsonData = jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (e) {
      print('[Extraction] JSON malformé avec $model: $e');
      throw Exception('Réponse IA invalide (JSON malformé) avec $model.');
    }
    // print('[Extraction] JSON parsé: $jsonData');

    final invoice = ExtractedInvoice.fromJson(jsonData);
    print('[Extraction] Facture construite — client: ${invoice.clientName}, '
        '${invoice.items.length} article(s), totalTTC: ${invoice.totalTTC}');
    for (int i = 0; i < invoice.items.length; i++) {
      final item = invoice.items[i];
      print('[Extraction]   Article $i: ${item.designation} '
          '× ${item.quantity} × ${item.unitPrice} HT '
          '= ${item.amountTTC} TTC');
    }

    return invoice;
  }
}
