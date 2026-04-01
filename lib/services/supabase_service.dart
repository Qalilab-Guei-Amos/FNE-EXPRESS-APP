import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService extends GetxService {
  final SupabaseClient client = Supabase.instance.client;

  // Accesseurs pratiques pour la suite (Auth, DB, Storage)
  GoTrueClient get auth => client.auth;
  SupabaseStorageClient get storage => client.storage;

  // Utilisateur actuellement connecté
  User? get currentUser => client.auth.currentUser;
  
  // Raccourci pour savoir si un utilisateur est connecté
  bool get isAuthenticated => currentUser != null;
}
