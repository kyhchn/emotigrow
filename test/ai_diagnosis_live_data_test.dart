import 'package:flutter_test/flutter_test.dart';

import 'package:cakmoji_flutter/screens/ai_diagnosis/ai_diagnosis_live_data.dart';

void main() {
  group('LatestPlantReading.tryFromMap', () {
    test('parses confidence + diagnosis from the latest node', () {
      final reading = LatestPlantReading.tryFromMap({
        'confidence': 0.8178214430809021,
        'diagnosis': 'Shepherd_purse_weeds',
        'timestamp': '2026-08-09T09:59:23.513082+00:00',
      });
      expect(reading, isNotNull);
      expect(reading!.confidence, closeTo(0.8178214430809021, 1e-9));
      expect(reading.diagnosis, 'Shepherd_purse_weeds');
    });

    test('null when confidence is missing', () {
      expect(LatestPlantReading.tryFromMap(<String, Object>{}), isNull);
      expect(
        LatestPlantReading.tryFromMap({
          'diagnosis': 'Healthy',
          'timestamp': '2026-08-07T07:47:38.572Z',
        }),
        isNull,
      );
    });
  });

  group('diagnosisReferenceImageUrl', () {
    test('points at the Supabase public disease reference', () {
      expect(
        diagnosisReferenceImageUrl,
        'https://gyuuswzsioqgyvguzhqx.supabase.co/storage/v1/object/public/'
        'disease-references/diagnosis.jpg',
      );
    });
  });
}
