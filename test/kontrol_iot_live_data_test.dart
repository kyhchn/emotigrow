import 'package:flutter_test/flutter_test.dart';

import 'package:cakmoji_flutter/screens/kontrol_iot/kontrol_iot_live_data.dart';

Map<String, Object?> livePayload({
  String? plantHealth = 'good',
  String? emojiScore,
  double ec = 1100,
  double ph = 6,
  double temp = 24,
  double lux = 80,
}) => {
  'final_output': {
    if (plantHealth != null) 'plant_health': plantHealth,
    if (emojiScore != null) 'emoji_score': emojiScore,
  },
  'sensors': {
    'ec': {'status': 'good', 'value': ec},
    'ph': {'status': 'good', 'value': ph},
    'temp': {'status': 'good', 'value': temp},
    'lux': {'status': 'good', 'value': lux},
  },
};

void main() {
  group('KontrolIotLiveData.tryFromMap', () {
    test('good → sehat (100/100) with labels rounded to one decimal', () {
      final data = KontrolIotLiveData.tryFromMap(livePayload());
      expect(data, isNotNull);
      expect(data!.status, KontrolIotStatus.sehat);
      expect(data.healthValue, 1);
      expect(data.healthLabel, '100/100');
      expect(data.ecLabel, '1100.0');
      expect(data.phLabel, '6.0');
      expect(data.tempLabel, '24.0°C');
      expect(data.luxLabel, '80.0%');
    });

    test('neutral → perhatian', () {
      final data = KontrolIotLiveData.tryFromMap(
        livePayload(plantHealth: 'neutral'),
      );
      expect(data!.status, KontrolIotStatus.perhatian);
      expect(data.healthLabel, '55/100');
    });

    test('bad → darurat, values rounded to one decimal', () {
      final data = KontrolIotLiveData.tryFromMap(
        livePayload(
          plantHealth: 'bad',
          ec: 0.15972,
          ph: 42.32088,
          temp: 27.25,
          lux: 0.00667,
        ),
      );
      expect(data!.status, KontrolIotStatus.darurat);
      expect(data.healthLabel, '30/100');
      expect(data.ecLabel, '0.2');
      expect(data.phLabel, '42.3');
      expect(data.tempLabel, '27.3°C');
      expect(data.luxLabel, '0.0%');
    });

    test('emoji_score fallback (:( → darurat, 😄 → sehat)', () {
      expect(
        KontrolIotLiveData.tryFromMap(
          livePayload(plantHealth: null, emojiScore: ':('),
        )!.status,
        KontrolIotStatus.darurat,
      );
      expect(
        KontrolIotLiveData.tryFromMap(
          livePayload(plantHealth: null, emojiScore: '😄'),
        )!.status,
        KontrolIotStatus.sehat,
      );
    });

    test(
      'parses the real devices/device1/live snapshot from rtdb_example.json',
      () {
        final data = KontrolIotLiveData.tryFromMap({
          'final_output': {'emoji_score': ':(', 'plant_health': 'bad'},
          'sensors': {
            'ec': {'status': 'bad', 'value': 0.15972},
            'lux': {'status': 'bad', 'value': 0.00667},
            'ph': {'status': 'bad', 'value': 42.32088},
            'tds': {'status': 'bad', 'value': 79.85906},
            'temp': {'status': 'neutral', 'value': 27.25},
          },
          'timestamp': '19:10:52',
          'vision': {'confidence': 0.9, 'disease': 'healthy'},
        });
        expect(data, isNotNull);
        expect(data!.status, KontrolIotStatus.darurat);
        expect(data.healthLabel, '30/100');
        expect(data.ecLabel, '0.2');
        expect(data.phLabel, '42.3');
        expect(data.tempLabel, '27.3°C');
        expect(data.luxLabel, '0.0%');
      },
    );

    test('null when required payload is missing', () {
      expect(
        KontrolIotLiveData.tryFromMap({'final_output': {}, 'sensors': {}}),
        isNull,
      );
      expect(KontrolIotLiveData.tryFromMap({}), isNull);
      expect(
        KontrolIotLiveData.tryFromMap({
          'final_output': {'plant_health': 'good'},
          'sensors': {
            'ec': {'value': 1},
            'ph': {'value': 2},
          },
        }),
        isNull,
      );
    });
  });
}
