import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/app_settings.dart';
import '../models/fne_record.dart';

class StorageService extends GetxService {
  static const String _fneBoxName = 'fne_records';
  static const String _settingsBoxName = 'settings';
  static const String _settingsKey = 'config';
  static const String _welcomeKey = 'has_seen_welcome';

  late Box<String> _fneBox;
  late Box<String> _settingsBox;

  /// Initialise le service et ouvre les boxes Hive.
  /// Appelé via [Get.putAsync] au démarrage de l'app.
  Future<StorageService> init() async {
    _fneBox = await Hive.openBox<String>(_fneBoxName);
    _settingsBox = await Hive.openBox<String>(_settingsBoxName);
    return this;
  }

  AppSettings? getSettings() {
    final json = _settingsBox.get(_settingsKey);
    if (json == null) return null;
    try {
      return AppSettings.fromJsonString(json);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSettings(AppSettings settings) async {
    await _settingsBox.put(_settingsKey, settings.toJsonString());
  }

  Future<void> saveFne(FneRecord record) async {
    await _fneBox.put(record.id, record.toJsonString());
  }

  List<FneRecord> getAllFne() {
    final records = <FneRecord>[];
    for (final key in _fneBox.keys) {
      try {
        final json = _fneBox.get(key.toString());
        if (json != null) records.add(FneRecord.fromJsonString(json));
      } catch (_) {}
    }
    records.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return records;
  }

  Future<void> updateFnePdfPath(String id, String pdfPath) async {
    final record = getFneById(id);
    if (record == null) return;
    await saveFne(FneRecord(
      id: record.id,
      createdAt: record.createdAt,
      clientName: record.clientName,
      totalTTC: record.totalTTC,
      fneNumber: record.fneNumber,
      qrCode: record.qrCode,
      pdfPath: pdfPath,
      invoice: record.invoice,
    ));
  }

  bool get hasSeenWelcome => _settingsBox.get(_welcomeKey) == 'true';

  Future<void> setHasSeenWelcome() async {
    await _settingsBox.put(_welcomeKey, 'true');
  }

  Future<void> deleteFne(String id) async {
    await _fneBox.delete(id);
  }

  FneRecord? getFneById(String id) {
    final json = _fneBox.get(id);
    if (json == null) return null;
    try {
      return FneRecord.fromJsonString(json);
    } catch (_) {
      return null;
    }
  }
}
