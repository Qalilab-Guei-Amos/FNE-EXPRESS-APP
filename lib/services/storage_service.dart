import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/fne_record.dart';

class StorageService extends GetxService {
  static const String _fneBoxName = 'fne_records';
  late Box<String> _fneBox;

  /// Initialise le service et ouvre la box Hive.
  /// Appelé via [Get.putAsync] au démarrage de l'app.
  Future<StorageService> init() async {
    _fneBox = await Hive.openBox<String>(_fneBoxName);
    return this;
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
