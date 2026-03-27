# API FNE — Documentation de la certification de facture

Documentation technique du processus de certification d'une Facture Normalisée Électronique (FNE) auprès de la DGI (Direction Générale des Impôts) de Côte d'Ivoire.

---

## Vue d'ensemble

La certification FNE se fait en **un seul appel HTTP POST**. L'API reçoit les données de la facture, les certifie auprès de la DGI, et retourne :
- une **référence FNE** (numéro officiel de la facture certifiée)
- un **token** (URL du QR code de vérification)

```
Client  ──POST /external/invoices/sign──►  API FNE (DGI CI)
        ◄── { reference, token } ──────────
```

---

## Endpoint

```
POST {FNE_API_BASE_URL}/external/invoices/sign
```

| Paramètre | Valeur |
|---|---|
| Base URL | `http://54.247.95.108/ws` |
| Méthode | `POST` |
| Content-Type | `application/json` |
| Accept | `application/json` |
| Authorization | `Bearer {FNE_API_KEY}` |

---

## Corps de la requête (Request Body)

```json
{
  "invoiceType": "sale",
  "paymentMethod": "mobile-money",
  "template": "B2B",
  "isRne": false,
  "invoiceNumber": "FAC-2024-001",
  "clientCompanyName": "AUCHAN CI",
  "clientPhone": "+2250707000000",
  "clientEmail": "comptabilite@auchan.ci",
  "clientNcc": "CI-ABJ-2019-B-12345",
  "clientSellerName": "AMANI DIGITAL SERVICES",
  "pointOfSale": "AMANI DIGITAL SERVICES",
  "establishment": "AMANI DIGITAL SERVICES",
  "foreignCurrency": "",
  "foreignCurrencyRate": 0,
  "discount": 0,
  "customTaxes": [],
  "items": [
    {
      "taxes": ["TVA"],
      "customTaxes": [],
      "reference": "",
      "description": "Lait concentré sucré 400g x24",
      "quantity": 10,
      "amount": 15000,
      "discount": 0,
      "measurementUnit": ""
    },
    {
      "taxes": ["TVAD"],
      "customTaxes": [],
      "reference": "",
      "description": "Eau minérale 1,5L x12",
      "quantity": 5,
      "amount": 3600,
      "discount": 0,
      "measurementUnit": ""
    }
  ]
}
```

---

## Description des champs

### Champs racine

| Champ | Type | Obligatoire | Description |
|---|---|---|---|
| `invoiceType` | string | Oui | Type de facture. Toujours `"sale"` pour une vente. |
| `paymentMethod` | string | Oui | Mode de paiement. Voir valeurs possibles ci-dessous. |
| `template` | string | Oui | Type de transaction commerciale (`B2B`, `B2C`, `B2F`). |
| `isRne` | boolean | Oui | `true` si la facture remplace une note d'encaissement (RNE). |
| `rne` | string | Si `isRne=true` | Numéro du reçu à remplacer. |
| `invoiceNumber` | string | Non | Numéro de facture interne du vendeur. Omis si vide. |
| `clientCompanyName` | string | Non | Nom du client / de l'entreprise cliente. |
| `clientPhone` | string | Non | Téléphone du client (format international recommandé). |
| `clientEmail` | string | Non | Email du client. |
| `clientNcc` | string | Si `B2B` | NCC (Numéro de Compte Contribuable) du client. Obligatoire pour les transactions B2B. |
| `clientSellerName` | string | Oui | Nom du vendeur / de l'émetteur de la facture. |
| `pointOfSale` | string | Oui | Nom du point de vente enregistré à la DGI. |
| `establishment` | string | Oui | Nom de l'établissement enregistré à la DGI. |
| `foreignCurrency` | string | Non | Code devise étrangère (ex: `USD`, `EUR`). Vide = XOF par défaut. Obligatoire si `B2F`. |
| `foreignCurrencyRate` | number | Si devise | Taux de change par rapport au XOF. Ex: `655.957` pour EUR. |
| `discount` | number | Oui | Remise globale sur la facture (en XOF). Mettre `0` si aucune. |
| `customTaxes` | array | Oui | Taxes personnalisées. Toujours `[]` dans l'usage courant. |
| `items` | array | Oui | Liste des lignes articles. Au moins 1 article requis. |

---

### Valeurs possibles — `paymentMethod`

| Valeur | Signification |
|---|---|
| `mobile-money` | Paiement par mobile money (Orange Money, Wave, MTN MoMo…) |
| `cash` | Espèces |
| `card` | Carte bancaire |
| `bank-transfer` | Virement bancaire |
| `check` | Chèque |
| `credit` | Crédit / paiement différé |

---

### Valeurs possibles — `template`

| Valeur | Signification | NCC requis |
|---|---|---|
| `B2B` | Business to Business — vente à une entreprise | Oui (`clientNcc`) |
| `B2C` | Business to Consumer — vente à un particulier | Non |
| `B2F` | Business to Foreigner — vente à un client étranger | Non, mais `foreignCurrency` requis |

---

### Champs d'un article (`items[]`)

| Champ | Type | Obligatoire | Description |
|---|---|---|---|
| `taxes` | array | Oui | Liste des codes TVA appliqués à cet article. Ex: `["TVA"]`. |
| `customTaxes` | array | Oui | Taxes personnalisées sur l'article. Toujours `[]`. |
| `reference` | string | Non | Référence interne de l'article (SKU, code…). Peut être vide `""`. |
| `description` | string | Oui | Désignation de l'article ou du service. |
| `quantity` | number | Oui | Quantité. Entier si valeur entière (`10`), décimal sinon (`2.5`). |
| `amount` | number | Oui | Prix unitaire HT en XOF (sans la TVA). |
| `discount` | number | Oui | Remise sur cet article en XOF. Mettre `0` si aucune. |
| `measurementUnit` | string | Non | Unité de mesure (ex: `"kg"`, `"carton"`, `"litre"`). Peut être vide `""`. |

---

### Codes TVA (`taxes[]`)

| Code | Taux | Signification |
|---|---|---|
| `TVA` | 18% | TVA normale — s'applique à la majorité des produits et services |
| `TVAB` | 9% | TVA réduite — certains produits alimentaires de base |
| `TVAC` | 0% | TVA exonérée par convention — produits sous convention fiscale |
| `TVAD` | 0% | TVA exonérée légale — produits exonérés par la loi (eau, médicaments…) |

> Un article peut cumuler plusieurs codes si nécessaire : `["TVA", "TVAB"]`, mais dans la pratique un seul code par article est la norme.

---

### Devises étrangères (`foreignCurrency`)

Utilisées uniquement pour le template `B2F` :

| Code | Devise |
|---|---|
| *(vide)* | XOF — Franc CFA (défaut) |
| `USD` | Dollar Américain |
| `EUR` | Euro |
| `GBP` | Livre Sterling |
| `JPY` | Yen Japonais |
| `CAD` | Dollar Canadien |
| `AUD` | Dollar Australien |
| `CNH` | Yuan Chinois |
| `CHF` | Franc Suisse |
| `HKD` | Dollar Hong Kong |
| `NZD` | Dollar Néo-Zélandais |

---

## Exemple complet — Requête B2B

**Contexte :** Vente de 10 cartons de lait (TVA 18%) et 5 packs d'eau (exo. légal) à l'entreprise AUCHAN CI, payés par mobile money.

```json
POST http://54.247.95.108/ws/external/invoices/sign
Authorization: Bearer cda2nsJE5RKcDFKjOc6GEHRXihd3OZgd
Content-Type: application/json

{
  "invoiceType": "sale",
  "paymentMethod": "mobile-money",
  "template": "B2B",
  "isRne": false,
  "invoiceNumber": "FAC-2024-00142",
  "clientCompanyName": "AUCHAN CI",
  "clientPhone": "+2250707123456",
  "clientEmail": "comptabilite@auchan.ci",
  "clientNcc": "CI-ABJ-2019-B-12345",
  "clientSellerName": "AMANI DIGITAL SERVICES",
  "pointOfSale": "AMANI DIGITAL SERVICES",
  "establishment": "AMANI DIGITAL SERVICES",
  "discount": 0,
  "customTaxes": [],
  "items": [
    {
      "taxes": ["TVA"],
      "customTaxes": [],
      "reference": "REF-001",
      "description": "Lait concentré sucré 400g x24",
      "quantity": 10,
      "amount": 15000,
      "discount": 0,
      "measurementUnit": "carton"
    },
    {
      "taxes": ["TVAD"],
      "customTaxes": [],
      "reference": "",
      "description": "Eau minérale 1,5L x12",
      "quantity": 5,
      "amount": 3600,
      "discount": 0,
      "measurementUnit": "pack"
    }
  ]
}
```

**Calculs article 1 :** 10 × 15 000 = 150 000 HT → TVA 18% = 27 000 → TTC = 177 000 XOF
**Calculs article 2 :** 5 × 3 600 = 18 000 HT → TVA 0% = 0 → TTC = 18 000 XOF
**Total TTC :** 195 000 XOF

---

## Exemple complet — Requête B2F (devise étrangère)

```json
{
  "invoiceType": "sale",
  "paymentMethod": "card",
  "template": "B2F",
  "isRne": false,
  "clientCompanyName": "JOHN DOE",
  "clientPhone": "+33612345678",
  "clientEmail": "johndoe@email.com",
  "clientSellerName": "AMANI DIGITAL SERVICES",
  "pointOfSale": "AMANI DIGITAL SERVICES",
  "establishment": "AMANI DIGITAL SERVICES",
  "foreignCurrency": "EUR",
  "foreignCurrencyRate": 655.957,
  "discount": 0,
  "customTaxes": [],
  "items": [
    {
      "taxes": ["TVA"],
      "customTaxes": [],
      "reference": "",
      "description": "Consultation conseil export",
      "quantity": 1,
      "amount": 50000,
      "discount": 0,
      "measurementUnit": ""
    }
  ]
}
```

---

## Réponse de l'API (succès)

La réponse complète contient 6 champs racine, dont un objet `invoice` détaillé.

```json
{
  "ncc": "CI-ABJ-2019-B-12345",
  "reference": "9606123E25000000019",
  "token": "http://54.247.95.108/fr/verification/9606123E25000000019",
  "warning": null,
  "balance_sticker": 142,
  "invoice": { ... }
}
```

### Champs racine de la réponse

| Champ | Type | Description | Utilisé dans l'app |
|---|---|---|---|
| `ncc` | string | NCC (identifiant contribuable) du vendeur enregistré à la DGI | Non |
| `reference` | string | **Numéro officiel de la FNE** attribué par la DGI. Format : `9606123E25000000019`. À imprimer sur la facture. | Oui → `fneNumber` |
| `token` | string | **URL de vérification** de la FNE. Encodée dans le QR code. Permet au client ou à l'administration de vérifier l'authenticité sur le portail DGI. | Oui → `qrCode` |
| `warning` | string\|null | Alerte sur le stock de stickers fiscaux restants. Non null quand le stock est bas. | Non |
| `balance_sticker` | int | Nombre de stickers fiscaux restants sur le compte vendeur. | Non |
| `invoice` | object | Objet complet de la facture telle qu'enregistrée par la DGI. | Non (partiel) |

---

### Objet `invoice`

```json
{
  "id": "e2b2d8da-a532-4c08-9182-f5b428ca468d",
  "parentId": null,
  "parentReference": null,
  "token": "019465c1-3f61-766c-9652-706e32dfb436",
  "reference": "9606123E25000000019",
  "type": "invoice",
  "subtype": "normal",
  "date": "2025-01-14T16:59:11.016Z",
  "paymentMethod": "mobile-money",
  "amount": 852660,
  "vatAmount": 172260,
  "fiscalStamp": 0,
  "discount": 10,
  "clientNcc": "9502363N",
  "clientCompanyName": "KPMG FRANCE",
  "clientPhone": "0709080765",
  "clientEmail": "info@kpmg.ci",
  "clientTerminal": "9090876543",
  "clientMerchantName": null,
  "clientRccm": "ci 083 abj 23",
  "clientSellerName": "Ali Hassan",
  "clientEstablishment": "Orange Riviera Mpouto",
  "clientPointOfSale": "23",
  "status": "paid",
  "template": "B2F",
  "description": "Soyez les bienvenus",
  "footer": null,
  "commercialMessage": "Toujours là pour votre bonheur",
  "foreignCurrency": "Euro",
  "foreignCurrencyRate": 655,
  "isRne": false,
  "rne": null,
  "source": "api",
  "createdAt": "2025-01-14T16:59:11.016Z",
  "updatedAt": "2025-01-14T16:59:11.125Z",
  "items": [ ... ],
  "customTaxes": [ ... ]
}
```

#### Description des champs de `invoice`

| Champ | Type | Description |
|---|---|---|
| `id` | string (UUID) | Identifiant unique de la facture dans le système DGI |
| `parentId` | string\|null | UUID de la facture parente (pour les avoirs/notes de crédit) |
| `parentReference` | string\|null | Référence de la facture parente |
| `token` | string | Token interne de la facture (différent du token racine) |
| `reference` | string | Numéro FNE officiel (identique au champ racine `reference`) |
| `type` | string | Type de document — toujours `"invoice"` pour une facture |
| `subtype` | string | Sous-type — `"normal"` pour une facture standard |
| `date` | string (ISO 8601) | Date et heure de certification UTC |
| `paymentMethod` | string | Mode de paiement tel qu'envoyé dans la requête |
| `amount` | int | **Montant HT total** en XOF (sans la TVA) |
| `vatAmount` | int | **Montant TVA total** en XOF |
| `fiscalStamp` | int | Timbre fiscal en XOF (0 si non applicable) |
| `discount` | int | Remise globale appliquée en XOF |
| `clientNcc` | string | NCC du client |
| `clientCompanyName` | string | Nom de l'entreprise cliente |
| `clientPhone` | string | Téléphone du client |
| `clientEmail` | string | Email du client |
| `clientTerminal` | string | Identifiant terminal du client (attribué par la DGI) |
| `clientMerchantName` | string\|null | Nom commercial du client (si applicable) |
| `clientRccm` | string | RCCM du client (Registre du Commerce) |
| `clientSellerName` | string | Nom du vendeur émetteur |
| `clientEstablishment` | string | Nom de l'établissement vendeur |
| `clientPointOfSale` | string | Identifiant du point de vente (attribué par la DGI) |
| `status` | string | Statut de la facture — `"paid"` une fois certifiée |
| `template` | string | Type de transaction — `B2B`, `B2C` ou `B2F` |
| `description` | string | Description ou message personnalisé de la facture |
| `footer` | string\|null | Pied de page personnalisé |
| `commercialMessage` | string\|null | Message commercial affiché sur la facture |
| `foreignCurrency` | string\|null | Devise étrangère utilisée (ex : `"Euro"`) |
| `foreignCurrencyRate` | int\|null | Taux de change utilisé pour la conversion |
| `isRne` | boolean | `true` si la FNE remplace une note d'encaissement |
| `rne` | string\|null | Numéro de la note d'encaissement remplacée |
| `source` | string | Origine de la création — `"api"` pour une création via l'API |
| `createdAt` | string (ISO 8601) | Date de création UTC |
| `updatedAt` | string (ISO 8601) | Date de dernière modification UTC |
| `items` | array | Lignes d'articles de la facture (voir ci-dessous) |
| `customTaxes` | array | Taxes personnalisées au niveau de la facture (ex : DTD) |

---

### Objet `items[]` dans `invoice`

```json
{
  "id": "bf9cc241-9b5f-4d26-a570-aa8e682a759e",
  "quantity": 30,
  "reference": "ref009",
  "description": "sac de riz Dinor 5 x 5",
  "amount": 20000,
  "discount": 10,
  "measurementUnit": "pcs",
  "createdAt": "2025-01-14T16:59:11.016Z",
  "updatedAt": "2025-01-14T16:59:11.016Z",
  "invoiceId": "e2b2d8da-a532-4c08-9182-f5b428ca468d",
  "parentId": null,
  "taxes": [
    {
      "invoiceItemId": "bf9cc241-9b5f-4d26-a570-aa8e682a759e",
      "vatRateId": "cdb6c5b2-5f35-407d-b5f6-c712a0792451",
      "amount": 18,
      "name": "TVA normal - TVA sur HT 18,00% - A",
      "shortName": "TVA",
      "createdAt": "2025-01-14T16:59:11.016Z",
      "updatedAt": "2025-01-14T16:59:11.016Z"
    }
  ],
  "customTaxes": [
    {
      "id": "55349f9c-b1df-43d8-9277-33fc6f5ccc8d",
      "invoiceItemId": "bf9cc241-9b5f-4d26-a570-aa8e682a759e",
      "amount": 5,
      "name": "GRA",
      "createdAt": "2025-01-14T16:59:11.016Z",
      "updatedAt": "2025-01-14T16:59:11.016Z"
    }
  ]
}
```

#### Description des champs de `items[]`

| Champ | Type | Description |
|---|---|---|
| `id` | string (UUID) | Identifiant unique de la ligne article |
| `quantity` | int | Quantité |
| `reference` | string | Référence interne de l'article |
| `description` | string | Désignation de l'article |
| `amount` | int | Prix unitaire HT en XOF |
| `discount` | int | Remise sur cet article en XOF |
| `measurementUnit` | string | Unité de mesure |
| `invoiceId` | string (UUID) | UUID de la facture parente |
| `parentId` | string\|null | UUID de l'article parent (avoirs) |
| `taxes` | array | Taxes TVA appliquées à cet article |
| `customTaxes` | array | Taxes personnalisées appliquées à cet article (ex : GRA, AIRSI) |

#### Description des champs de `taxes[]` (dans un article)

| Champ | Type | Description |
|---|---|---|
| `invoiceItemId` | string (UUID) | UUID de l'article auquel appartient cette taxe |
| `vatRateId` | string (UUID) | UUID du taux de TVA dans le référentiel DGI |
| `amount` | int | Taux de TVA en pourcentage (ex : `18` pour 18%, `0` pour exonéré) |
| `name` | string | Libellé complet de la taxe (ex : `"TVA normal - TVA sur HT 18,00% - A"`) |
| `shortName` | string | Code court — `TVA`, `TVAB`, `TVAC` ou `TVAD` |

#### Description des champs de `customTaxes[]` (dans un article)

Les taxes personnalisées sont des prélèvements additionnels définis par la DGI selon la nature du produit.

| Champ | Type | Description |
|---|---|---|
| `id` | string (UUID) | Identifiant unique de la taxe personnalisée |
| `invoiceItemId` | string (UUID) | UUID de l'article concerné |
| `amount` | int | Taux ou montant de la taxe |
| `name` | string | Code de la taxe (ex : `GRA`, `AIRSI`, `DTD`…) |

**Exemples de taxes personnalisées rencontrées :**

| Code | Signification probable |
|---|---|
| `GRA` | Taxe sur les Grands Revenus / redevance sur produits alimentaires |
| `AIRSI` | Acompte sur Impôt sur le Revenu des Salariés et Indépendants |
| `DTD` | Droit de Timbre Digital (niveau facture entière) |

> Ces taxes sont calculées et appliquées **automatiquement par la DGI** en fonction de la nature des articles. Il n'est pas nécessaire de les envoyer dans la requête — elles apparaissent uniquement dans la réponse.

---

### Objet `customTaxes[]` au niveau de la facture

```json
{
  "id": "7e8ef5cc-8ab1-4334-ad1c-dc9cdfc229aa",
  "invoiceId": "e2b2d8da-a532-4c08-9182-f5b428ca468d",
  "amount": 5,
  "name": "DTD",
  "createdAt": "2025-01-14T16:59:11.016Z",
  "updatedAt": "2025-01-14T16:59:11.016Z"
}
```

Taxes appliquées à la facture entière (pas à un article spécifique).

| Champ | Type | Description |
|---|---|---|
| `id` | string (UUID) | Identifiant de la taxe |
| `invoiceId` | string (UUID) | UUID de la facture |
| `amount` | int | Montant ou taux de la taxe |
| `name` | string | Code de la taxe (ex : `DTD` — Droit de Timbre Digital) |

---

## Ce que l'application utilise réellement

Sur l'ensemble de la réponse, l'application FNE Express n'exploite que deux champs :

```dart
final ref   = response.data['reference']?.toString();  // → fneNumber
final token = response.data['token']?.toString();       // → qrCode (URL)
```

Les autres champs (`invoice`, `ncc`, `warning`, `balance_sticker`) sont ignorés mais disponibles pour des implémentations plus complètes (affichage du récapitulatif certifié, alertes stock, etc.).

---

## Réponse de l'API (erreur)

En cas d'erreur, l'API retourne un code HTTP 4xx ou 5xx avec un corps JSON :

```json
{
  "message": "Le champ clientNcc est requis pour le template B2B",
  "error": "VALIDATION_ERROR",
  "statusCode": 400
}
```

ou

```json
{
  "error": "Unauthorized",
  "statusCode": 401
}
```

### Codes HTTP courants

| Code | Signification |
|---|---|
| `200` / `201` | Succès — FNE certifiée |
| `400` | Données invalides (champ manquant, format incorrect…) |
| `401` | Clé API invalide ou absente |
| `403` | Point de vente / établissement non autorisé |
| `422` | Entité non traitable (NCC client introuvable, montants incohérents…) |
| `500` | Erreur serveur DGI |

---

## En-têtes HTTP requis

```
Authorization: Bearer {FNE_API_KEY}
Content-Type: application/json
Accept: application/json
```

---

## Variables d'environnement à configurer

| Variable | Description | Exemple |
|---|---|---|
| `FNE_API_BASE_URL` | URL de base de l'API DGI | `http://54.247.95.108/ws` |
| `FNE_API_KEY` | Clé API fournie par la DGI | `cda2nsJE5RKcDFKjOc6GEHRXihd3OZgd` |
| `FNE_POINT_OF_SALE` | Nom du point de vente enregistré à la DGI | `AMANI DIGITAL SERVICES` |
| `FNE_ESTABLISHMENT` | Nom de l'établissement enregistré à la DGI | `AMANI DIGITAL SERVICES` |

> `FNE_POINT_OF_SALE` et `FNE_ESTABLISHMENT` doivent correspondre exactement aux informations enregistrées lors de l'inscription à la plateforme FNE de la DGI.

---

## Règles métier importantes

1. **`amount` est toujours le prix unitaire HT** (hors taxes). L'API calcule elle-même la TVA selon le code fourni dans `taxes[]`.

2. **`quantity` entier vs décimal** : envoyer `10` (int) si la valeur est entière, `2.5` (float) si décimale. Éviter `10.0` pour les entiers.

3. **`clientNcc` obligatoire en B2B** : sans NCC valide, l'API rejette la requête. Le NCC est le numéro d'identification fiscale de l'entreprise cliente en Côte d'Ivoire.

4. **`foreignCurrency` + `foreignCurrencyRate` en B2F** : les deux champs sont indissociables. Si `foreignCurrency` est renseigné, `foreignCurrencyRate` doit être > 0.

5. **`isRne: true`** : utilisé quand la FNE remplace une note d'encaissement déjà émise. Le champ `rne` doit alors contenir le numéro de la note.

6. **Un seul appel suffit** : contrairement à certaines APIs fiscales, ici il n'y a pas de pré-enregistrement ni de confirmation en deux étapes. L'appel est atomique — succès ou échec.

7. **Pas de montant total à envoyer** : l'API calcule elle-même les totaux HT, TVA et TTC à partir des articles. Ne pas envoyer de champ `totalTTC` ou `totalHT`.

