/// Typed access to the plant's live IoT snapshot in Firebase Realtime
/// Database.
///
/// All Firebase mapping lives here so the Kontrol IoT screen stays small: it
/// only renders whatever [KontrolIotLiveData] exposes.
///
/// Data source: `devices/device1/live`
///
/// - `final_output.plant_health` / `emoji_score` → plant status
///   (`bad` → darurat, `neutral` → perhatian, `good` → sehat)
/// - `sensors.ec` → EC
/// - `sensors.ph` → PH
/// - `sensors.temp` → suhu
/// - `sensors.lux` → cahaya (shown as a percentage)
/// - every number is rounded to one decimal place
library;

import 'package:firebase_database/firebase_database.dart';

import '../../services/firebase_rtdb_service.dart';

/// Location of the device's live sensor snapshot.
const String kontrolIotLivePath = 'devices/device1/live';

/// Plant health level, mapped from the device's `final_output`:
/// `good` → [KontrolIotStatus.sehat], `neutral` → [KontrolIotStatus.perhatian],
/// `bad` → [KontrolIotStatus.darurat].
enum KontrolIotStatus { sehat, perhatian, darurat }

/// Typed snapshot of `devices/device1/live`.
class KontrolIotLiveData {
  const KontrolIotLiveData({
    required this.status,
    required this.ec,
    required this.ph,
    required this.temp,
    required this.lux,
  });

  final KontrolIotStatus status;
  final double ec;
  final double ph;
  final double temp;
  final double lux;

  /// Health-bar score (0..1) derived from [status] — mirrors the demo plants
  /// (sehat 100, perhatian 55, darurat 30).
  double get healthValue => switch (status) {
    KontrolIotStatus.sehat => 1,
    KontrolIotStatus.perhatian => 0.55,
    KontrolIotStatus.darurat => 0.3,
  };

  /// e.g. `100/100`, shown right under the health bar.
  String get healthLabel => '${(healthValue * 100).round()}/100';

  /// Suhu — from `sensors.temp`, e.g. `24.0°C`.
  String get tempLabel => '${temp.toStringAsFixed(1)}°C';

  /// Cahaya — from `sensors.lux`, shown as a percentage, e.g. `80.0%`.
  String get luxLabel => '${lux.toStringAsFixed(1)}%';

  /// PH — from `sensors.ph`, e.g. `6.0`.
  String get phLabel => ph.toStringAsFixed(1);

  /// EC — from `sensors.ec`, e.g. `700.0`.
  String get ecLabel => ec.toStringAsFixed(1);

  /// Parses a `devices/device1/live` [DataSnapshot]; `null` when the payload
  /// has no usable live data (empty node / permission denied).
  static KontrolIotLiveData? tryFromSnapshot(DataSnapshot snapshot) {
    final value = snapshot.value;
    return value is Map ? tryFromMap(value) : null;
  }

  /// Parses the raw database map for a live node.
  static KontrolIotLiveData? tryFromMap(Map map) {
    final finalOutput = map['final_output'];
    final sensors = map['sensors'];
    if (finalOutput is! Map || sensors is! Map) return null;

    final status = _statusFromOutput(finalOutput);
    final ec = _measurementFrom(sensors['ec']);
    final ph = _measurementFrom(sensors['ph']);
    final temp = _measurementFrom(sensors['temp']);
    final lux = _measurementFrom(sensors['lux']);
    if (status == null ||
        ec == null ||
        ph == null ||
        temp == null ||
        lux == null) {
      return null;
    }

    return KontrolIotLiveData(
      status: status,
      ec: ec,
      ph: ph,
      temp: temp,
      lux: lux,
    );
  }

  /// Reads `final_output.plant_health` first, falls back to `emoji_score`.
  static KontrolIotStatus? _statusFromOutput(Map output) {
    final plantHealth = output['plant_health'];
    if (plantHealth is String) {
      final mapped = _statusFromKey(plantHealth);
      if (mapped != null) return mapped;
    }
    final emojiScore = output['emoji_score'];
    if (emojiScore is String) return _statusFromKey(emojiScore);
    return null;
  }

  /// Accepts the health keywords as well as the emoji glyphs the device
  /// actually writes (`:(`, `😄`).
  static KontrolIotStatus? _statusFromKey(String raw) {
    switch (raw.toLowerCase()) {
      case 'good':
        return KontrolIotStatus.sehat;
      case 'sehat':
        return KontrolIotStatus.sehat;
      case '😄':
        return KontrolIotStatus.sehat;
      case 'neutral':
        return KontrolIotStatus.perhatian;
      case 'perhatian':
        return KontrolIotStatus.perhatian;
      case 'bad':
        return KontrolIotStatus.darurat;
      case 'darurat':
        return KontrolIotStatus.darurat;
      case ':(':
        return KontrolIotStatus.darurat;
      case '🙁':
        return KontrolIotStatus.darurat;
      default:
        return null;
    }
  }

  /// Reads the numeric `value` out of a `{ status, value }` sensor entry.
  static double? _measurementFrom(Object? entry) {
    if (entry is Map) {
      final raw = entry['value'];
      if (raw is num) return raw.toDouble();
    }
    return null;
  }
}

/// Streams `devices/device1/live` and re-emits on every device update, so the
/// UI stays current without polling. Emits `null` when Firebase isn't ready
/// (e.g. widget tests) or the payload isn't a valid snapshot, so callers can
/// fall back to their demo values.
Stream<KontrolIotLiveData?> watchKontrolIotLiveData({
  String path = kontrolIotLivePath,
}) {
  try {
    return FirebaseRtdbService.instance
        .ref(path)
        .onValue
        .map((event) => KontrolIotLiveData.tryFromSnapshot(event.snapshot));
  } on Object {
    return Stream.value(null);
  }
}
