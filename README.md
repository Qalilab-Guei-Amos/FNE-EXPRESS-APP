# FNE Express

Application mobile et tablette Flutter permettant de générer des **Factures Normalisées Électroniques (FNE)** en Côte d'Ivoire de manière autonome et instantanée, en remplaçant le recours à un cabinet comptable tiers.

---

## Contexte métier

La cliente fournit des produits de grande consommation à des enseignes majeures de la grande distribution (Auchan, Prosuma, Casino, Jour de Marché, L'hypermarché, etc.). Pour finaliser ses ventes, elle est soumise à l'obligation fiscale de fournir une **Facture Normalisée Électronique** auprès de la DGI (Direction Générale des Impôts) de Côte d'Ivoire.

L'application automatise ce processus grâce à l'intelligence artificielle et une interface de validation intuitive.

---

## Flux principal

```
Import facture (photo/PDF)
        ↓
Extraction IA (Gemini 1.5 Flash)
        ↓
Vérification humaine (formulaire éditable)
        ↓
API FNE — Étape 1 (pré-enregistrement)
        ↓
Confirmation utilisateur
        ↓
API FNE — Étape 2 (génération FNE officielle)
        ↓
Affichage + archivage local
```

---

## Stack technique

| Composant | Technologie |
|---|---|
| Framework | Flutter (mobile + tablette) |
| State management | GetX |
| IA extraction | Gemini 1.5 Flash (`googleai_dart`) |
| Client HTTP | Dio |
| Stockage local | Hive |
| Variables d'env | flutter_dotenv |
| Partage | share_plus |
| Sélection fichiers | file_picker + image_picker |
| Responsive UI | Utilitaire `R` (breakpoints 600 / 900 dp) |

---

## Architecture

```
lib/
├── main.dart                        # Initialisation + enregistrement des services
├── core/
│   ├── theme/app_theme.dart         # Thème (vert #1A6B3C / orange #F7941D)
│   └── utils/
│       ├── formatters.dart          # Formatage FCFA, dates (fr_CI)
│       └── responsive.dart         # Utilitaire responsive R.fs / R.hPad / R.cols
├── models/
│   ├── invoice_item.dart            # Ligne article (HT, TVA, TTC calculés)
│   ├── extracted_invoice.dart       # Facture extraite avec totaux agrégés
│   └── fne_record.dart              # FNE archivée (sérialisée en JSON pour Hive)
├── services/                        # GetxService — un seul cycle de vie
│   ├── gemini_service.dart          # Appel Gemini API (image/PDF → JSON structuré)
│   ├── fne_api_service.dart         # API FNE en 2 étapes + mode mock intégré
│   └── storage_service.dart         # CRUD Hive (Box<String> + sérialisation JSON)
├── controllers/
│   ├── acquisition_controller.dart  # Caméra / galerie / sélecteur de fichiers
│   ├── validation_controller.dart   # Machine à états du workflow complet
│   └── history_controller.dart      # Chargement et suppression de l'historique
└── views/
    ├── home/home_screen.dart         # Accueil + liste/grille des FNE récentes
    ├── acquisition/acquisition_screen.dart  # Import document + prévisualisation
    ├── validation/validation_screen.dart    # Formulaire éditable + split-view tablette
    ├── fne_result/fne_result_screen.dart    # Résultat FNE + QR code + partage
    └── history/history_screen.dart          # Historique complet (swipe/grille)
```

---

## Services GetxService

Les trois services sont enregistrés **une seule fois** au démarrage via GetX et accessibles partout avec `Get.find<T>()`.

```dart
// main.dart
await Get.putAsync<StorageService>(() => StorageService().init()); // async (Hive)
Get.put<GeminiService>(GeminiService());   // onInit → crée le client Gemini
Get.put<FneApiService>(FneApiService());   // onInit → configure Dio
```

### GeminiService
- Envoie l'image ou le PDF en base64 à Gemini 1.5 Flash
- Retourne un `ExtractedInvoice` parsé depuis le JSON généré par le modèle
- Le client `GoogleAIClient` est fermé proprement dans `onClose()`

### FneApiService
- **Mode mock** actif tant que `FNE_API_KEY` vaut `YOUR_FNE_API_KEY`
- **Étape 1** : `POST /factures` → retourne un `draftId`
- **Étape 2** : `POST /factures/{id}/valider` → retourne numéro FNE + QR code

### StorageService
- Box Hive `fne_records` (type `Box<String>`)
- Chaque `FneRecord` est sérialisé en JSON string
- Méthodes : `saveFne`, `getAllFne`, `deleteFne`, `getFneById`

---

## Responsive Design

L'utilitaire `R` (`lib/core/utils/responsive.dart`) adapte automatiquement l'interface selon la largeur d'écran :

| Méthode | Mobile (< 600) | Tablette (≥ 600) | Grande tablette (≥ 900) |
|---|---|---|---|
| `R.hPad(ctx)` | 20 | 36 | 56 |
| `R.fs(ctx, 16)` | 16 | 18.9 | 21.6 |
| `R.btnH(ctx)` | 54 | 64 | 64 |
| `R.cols(ctx)` | 1 | 2 | 3 |

### Comportement par écran

| Écran | Mobile | Tablette |
|---|---|---|
| Accueil | Liste verticale | Grille 2–3 colonnes |
| Acquisition | 3 options empilées | 2 colonnes + 1 pleine largeur |
| Validation | Formulaire seul | Split-view : facture originale ↔ formulaire |
| Articles (validation) | 2 champs par ligne | 4 champs sur une ligne |
| Confirmation | Récap vertical | Récap en 2 colonnes |
| Résultat FNE | Empilé | Bannière+QR à gauche / détails à droite |
| Historique | Liste swipe-to-delete | Grille 2–3 colonnes |

---

## Configuration

Toutes les clés et variables sensibles sont dans le fichier `.env` (non versionné) :

```env
# Clé API Google Gemini
# https://aistudio.google.com/app/apikey
GEMINI_API_KEY=YOUR_GEMINI_API_KEY

# Modèle Gemini
GEMINI_MODEL=gemini-1.5-flash

# API FNE - DGI Côte d'Ivoire
FNE_API_BASE_URL=https://api.fne.dgi.gouv.ci/v1
FNE_API_KEY=YOUR_FNE_API_KEY
FNE_VENDOR_NIF=YOUR_NIF_NUMBER
```

> Le fichier `.env` est déclaré dans `pubspec.yaml` comme asset Flutter et protégé par `.gitignore`.

---

## Installation et lancement

```bash
# 1. Cloner le projet
git clone <repo-url>
cd fne_app

# 2. Configurer les variables d'environnement
cp .env.example .env   # puis remplir les valeurs

# 3. Installer les dépendances
flutter pub get

# 4. Lancer l'application
flutter run
```

### Permissions Android requises

Déclarées dans `android/app/src/main/AndroidManifest.xml` :

```xml
<uses-permission android:name="android.permission.CAMERA"/>
<uses-permission android:name="android.permission.READ_MEDIA_IMAGES"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
<uses-permission android:name="android.permission.INTERNET"/>
```

---

## Dépendances principales

```yaml
get: ^4.7.3                  # State management + navigation + services
googleai_dart: ^3.6.0        # Client Gemini API (multimodal)
dio: ^5.9.2                  # Client HTTP (API FNE)
hive_flutter: ^1.1.0         # Stockage local NoSQL
flutter_dotenv: ^6.0.0       # Variables d'environnement
file_picker: ^10.3.10        # Import PDF/images
image_picker: ^1.1.2         # Caméra et galerie
share_plus: ^10.0.0          # Partage WhatsApp/email/impression
flutter_pdfview: ^1.4.4      # Visionneuse PDF intégrée
flutter_screenutil: ^5.9.3   # Adaptation tailles écrans
toastification: ^3.0.3       # Notifications toast
```

---

## Mode mock

L'application fonctionne entièrement **sans API FNE configurée**. Tant que `FNE_API_KEY=YOUR_FNE_API_KEY` dans `.env`, les réponses de l'API FNE sont simulées localement :

- Étape 1 : délai 1 s → retourne un `draftId` fictif
- Étape 2 : délai 2 s → génère un numéro FNE au format `FNE-CI-YYYY-XXXXXX` avec QR code de vérification

Seule la clé Gemini est obligatoire pour l'extraction IA.
