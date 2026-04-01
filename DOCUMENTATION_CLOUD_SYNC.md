# Documentation Technique : Architecture Cloud & Synchro (FNE Express)

Ce document décrit le fonctionnement interne de l'application **FNE Express** suite à l'intégration de la **Phase 3 : Sécurisation Cloud & Synchronisation**.

---

## 1. Vue d'Ensemble de l'Architecture

L'application repose sur un modèle **Offline-First**. Elle privilégie la rapidité locale (Hive) tout en utilisant le Cloud (Supabase) pour la pérennité des données.

### Les 4 Piliers Technologiques :
1. **💾 Base de Données Locale (Hive) :** Stockage instantané et accès hors-ligne total.
2. **🔐 Authentification (Supabase Auth) :** Gestion sécurisée des comptes utilisateurs.
3. **☁️ Cloud Database (PostgreSQL) :** Centralisation sécurisée des factures certifiées.
4. **📂 Cloud Storage (Supabase Storage) :** Archivage des fichiers PDF officiels et images sources.

---

## 2. Cycle de Vie d'une Facture

Désormais, le processus de création suit ce workflow automatisé :

1. **Extraction (Local) :** `GeminiService` analyse l'image/PDF et renvoie les données.
2. **Brouillon (Local) :** La facture est enregistrée localement avec le statut `brouillon`.
3. **Certification (API DGI) :** Envoi vers l'API FNE pour certification.
4. **Passage au Statut Certifiée :** Une fois validée par la DGI, la facture devient **Immuable**.
5. **🔥 Synchronisation Cloud Auto (Background) :**
   - Dès la réussite de la certification, le `SyncService` se lance en arrière-plan.
   - La donnée texte est stockée dans la table `fne_records`.
   - Le fichier PDF est transféré vers le bucket `fne_documents`.
   - Le champ local `isSynced` passe à `true`.

---

## 3. Gestion de la Propriété & Isolation (Multi-Comptes)

L'application est conçue pour être partagée sans risque par plusieurs utilisateurs sur le même appareil :

### Règles d'isolement :
- Chaque facture possède un champ `userId`.
- **Mode Non Connecté :** Vous ne voyez que les factures dont le `userId` est vide (créées localement sans compte).
- **Mode Connecté :** Vous voyez vos propres factures Cloud + les factures locales éventuellement créées sur ce même compte. Les factures des autres utilisateurs stockées sur le téléphone sont **strictement filtrées et invisibles**.
- **Appropriation :** Lorsque vous synchronisez des factures locales orphelines (sans `userId`) vers votre compte, elles sont alors taguées avec votre ID utilisateur Cloud de manière permanente.

---

## 4. Restauration & Fusion Auto (Login Merge) 🔄

C'est ici que la magie de la continuité de service opère. À la connexion réussie, l'application lance une **Fusion Bi-directionnelle Silencieuse** :

1. **Phase 1 (Cloud -> Téléphone) :** `restoreFromCloud()` télécharge tout votre historique distant pour le réinjecter dans le téléphone.
2. **Phase 2 (Téléphone -> Cloud) :** `syncCertifiedRecords()` repère les factures que vous aviez faites en mode hors-ligne sans être connecté, et les envoie immédiatement au Cloud pour les mettre à l'abri sur votre compte.
3. **Appropriation :** Ces factures locales orphelines reçoivent alors officiellement votre ID utilisateur en local.

---

## 5. Composants Logiciels (GetX)

| Nom | Rôle |
| :--- | :--- |
| `SyncService` | Moteur de transfert (Upload/Restore). Supporte un mode `silent` pour les opérations automatiques de fusion. |
| `AuthController` | Gère login/logout et les triggers de fusion automatique au démarrage. |
| `HistoryController` | Gère le filtrage visuel basé sur la propriété des données (`userId`). |
| `ValidationController` | Gère la certification et déclenche la synchro en arrière-plan. |

---

## 6. Sécurité du Cloud (RLS)

La base de données cloud est protégée par des **Policies RLS (Row Level Security)** :
- Un utilisateur ne peut **jamais** lire ou modifier une facture appartenant à un autre `user_id`.
- Ces règles sont appliquées directement sur le serveur Supabase, rendant le piratage via l'application impossible.

---

*Dernière mise à jour : 01 Avril 2026*
