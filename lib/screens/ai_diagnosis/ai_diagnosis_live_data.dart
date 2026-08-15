/// Typed access to the latest AI plant reading and the Supabase Storage
/// reference image for the AI Diagnosis screen.
///
/// All Firebase/Supabase mapping lives here so the diagnosis screen stays
/// small: it only renders whatever [LatestPlantReading] exposes and resolves
/// the "Referensi" image via [diagnosisReferenceImageUrl].
///
/// Data sources:
/// - `plant_readings/pi3b-02/latest` → `latest.confidence` (0..1) drives the
///   "X% Keyakinan" meter of the first diagnosis result.
/// - Supabase Storage `disease-references/diagnosis.jpg` → the "Referensi"
///   image shown next to the user's plant photo.
library;

import 'package:firebase_database/firebase_database.dart';

import '../../services/firebase_rtdb_service.dart';

/// Location of the latest AI plant reading for device `pi3b-02`.
const String plantReadingPath = 'plant_readings/pi3b-02/latest';

/// Supabase Storage bucket that holds the disease reference photos.
const String diagnosisReferenceBucket = 'disease-references';

/// Reference image used by the first (live) diagnosis result.
const String diagnosisReferenceImagePath = 'diagnosis.jpg';

/// Base URL of the Supabase project that serves the reference images.
///
/// The storage URL the API uses looks like
/// `https://gyuuswzsioqgyvguzhqx.supabase.co/storage/v1/object/public/...`,
/// so this defaults to that host. If the app's own project
/// (`AppConfig.supabaseUrl`) hosts the files instead, point this at it.
const String supabaseStorageBaseUrl =
    'https://gyuuswzsioqgyvguzhqx.supabase.co';

/// Public URL of the diagnosis reference image, e.g.
/// `https://…/storage/v1/object/public/disease-references/diagnosis.jpg`.
String get diagnosisReferenceImageUrl =>
    '$supabaseStorageBaseUrl/storage/v1/object/public/'
    '$diagnosisReferenceBucket/';

String get ourPlantImageUrl =>
    '$supabaseStorageBaseUrl/storage/v1/object/public/'
    'plant-snapshots/pi3b-02/latest.jpg';

/// Typed snapshot of `plant_readings/pi3b-02/latest`.
class LatestPlantReading {
  const LatestPlantReading({required this.confidence, required this.diagnosis});

  /// AI confidence in the diagnosis, between 0.0 and 1.0.
  final double confidence;

  /// Diagnosis label written by the AI model (e.g. `Shepherd_purse_weeds`).
  final String diagnosis;

  /// Parses a `plant_readings/<device>/latest` [DataSnapshot]; `null` when the
  /// payload is missing or cannot provide a confidence value.
  static LatestPlantReading? tryFromSnapshot(DataSnapshot snapshot) {
    final value = snapshot.value;
    return value is Map ? tryFromMap(value) : null;
  }

  /// Parses the raw database map for a `latest` node.
  static LatestPlantReading? tryFromMap(Map map) {
    final confidence = map['confidence'];
    if (confidence is! num) return null;
    return LatestPlantReading(
      confidence: confidence.toDouble(),
      diagnosis: map['diagnosis']?.toString() ?? '',
    );
  }

  static diagnosisReferenceImageUrlFor(String diagnosis) =>
      '$diagnosisReferenceImageUrl$diagnosis.jpg';

  static ourPlantImageUrlFor() =>
      '$supabaseStorageBaseUrl/storage/v1/object/public/'
      'plant-snapshots/pi3b-02/latest.jpg';
}

/// Streams `plant_readings/pi3b-02/latest` and re-emits on every device
/// update, so the UI stays current without polling. Emits `null` when Firebase
/// isn't ready (e.g. widget tests) or the payload isn't a valid reading, so
/// callers can fall back to their demo values.
Stream<LatestPlantReading?> watchLatestPlantReading({
  String path = plantReadingPath,
}) {
  try {
    return FirebaseRtdbService.instance
        .ref(path)
        .onValue
        .map((event) => LatestPlantReading.tryFromSnapshot(event.snapshot));
  } on Object {
    return Stream.value(null);
  }
}
