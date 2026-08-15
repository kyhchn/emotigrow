import 'package:cakmoji_flutter/core/app_colors.dart';
import 'package:cakmoji_flutter/screens/ai_diagnosis/ai_diagnosis_live_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

// ---------------------------------------------------------------------------
// Model
// ---------------------------------------------------------------------------

/// Mood of a diagnosis result. "Happy"/"Normal" → show "Saran Ke Depan";
/// "Sad" → show "Gejala Utama" and "Dampak Potensial" instead.
enum _DiagnosisMood {
  happy('HAPPY', Color(0xFF16A34A), Color(0xFFDCFCE7)),
  normal('NORMAL', Color(0xFFF59E0B), Color(0xFFFEF3C7)),
  sad('SAD', Color(0xFFEF4444), Color(0xFFFEE2E2));

  const _DiagnosisMood(this.label, this.color, this.bg);

  final String label;
  final Color color;
  final Color bg;

  bool get isGood =>
      this == _DiagnosisMood.happy || this == _DiagnosisMood.normal;
}

class _DiagnosisResult {
  const _DiagnosisResult({
    required this.name,
    required this.mood,
    required this.fotoImage,
    required this.referensiImage,
    required this.confident,
    this.diseaseName,
    this.emoticonAsset,
  });

  final String name;
  final _DiagnosisMood mood;

  /// The user's plant photo.
  final String fotoImage;

  /// The reference / comparison image.
  final String referensiImage;

  /// AI confidence between 0.0 and 1.0 (0.96 → "96% Keyakinan").
  final double confident;

  final String? diseaseName;

  /// Small emoticon shown inside the dropdown row.
  final String? emoticonAsset;
}

/// Demo diagnosis results — replace with data from your backend.
const List<_DiagnosisResult> _demoResults = [
  _DiagnosisResult(
    name: 'Selada Keriting',
    mood: _DiagnosisMood.normal,
    diseaseName: 'Selada Sehat',
    fotoImage: 'assets/images/ai_selada_own.png',
    referensiImage: 'assets/images/ai_selada_reference.png',
    confident: 0.96,
    emoticonAsset: 'assets/images/opsi_happy.png',
  ),
  _DiagnosisResult(
    name: 'Pakcoy',
    mood: _DiagnosisMood.sad,
    fotoImage: 'assets/images/pakcoy.png',
    diseaseName: 'Pakcoy Terinfeksi',
    referensiImage: 'assets/images/kontrol_iot_banner_top.png',
    confident: 0.78,
    emoticonAsset: 'assets/images/opsi_sad.png',
  ),
  _DiagnosisResult(
    name: 'Tomat',
    mood: _DiagnosisMood.happy,
    fotoImage: 'assets/images/tomat.png',
    referensiImage: 'assets/images/cakmoji.png',
    confident: 0.99,
    diseaseName: 'Tomat Sehat',
    emoticonAsset: 'assets/images/opsi_happy.png',
  ),
];

class AiDiagnosisScreen extends StatefulWidget {
  const AiDiagnosisScreen({super.key});

  @override
  State<AiDiagnosisScreen> createState() => _AiDiagnosisScreenState();
}

class _AiDiagnosisScreenState extends State<AiDiagnosisScreen> {
  _DiagnosisResult _selected = _demoResults.first;
  final Map<String, String> diseaseLabels = {
    'bacterial.jpg': 'Penyakit Bakteri',
    'downy_mildew_on_lettuce.jpg': 'Embun Bulu pada Selada',
    'healthy.jpg': 'Sehat (tidak sakit)',
    'powdery_mildew_on_lettuce.jpg': 'Embun Tepung pada Selada',
    'septoria_blight_on_lettuce.jpg': 'Hawar Septoria pada Selada',
    'shepherd_purse_weeds.jpg': 'Gulma',
    'viral.jpg': 'Penyakit Virus',
    'wilt_and_leaf_blight_on_lettuce.jpg': 'Layu dan Hawar Daun pada Selada',
  };

  /// Live-driven twin of the first demo result (Selada Sehat): the confidence
  /// comes from `plant_readings/pi3b-02/latest` and the Referensi image from
  /// Supabase Storage (`disease-references/diagnosis.jpg`).
  _DiagnosisResult _liveResult(LatestPlantReading reading) {
    return _DiagnosisResult(
      name: _demoResults.first.name,
      mood: _demoResults.first.mood,
      fotoImage: LatestPlantReading.ourPlantImageUrlFor(),
      referensiImage: LatestPlantReading.diagnosisReferenceImageUrlFor(
        reading.diagnosis,
      ),
      confident: reading.confidence,
      emoticonAsset: _demoResults.first.emoticonAsset,
      diseaseName:
          diseaseLabels['${reading.diagnosis.toLowerCase()}.jpg'] ??
          reading
              .diagnosis, // Use the label if available, otherwise fallback to the raw diagnosis
      // diseaseName: _selected.diseaseName ?? _demoResults.first.diseaseName,
    );
  }

  /// The result rendered by the UI. Only the first result (Selada Sehat) is
  /// driven by the live reading; the other two keep their demo data.
  _DiagnosisResult _effectiveResult(LatestPlantReading? reading) {
    if (reading == null || _selected != _demoResults.first) {
      return _selected;
    }
    return _liveResult(reading);
  }

  /// Options rendered by the diagnosis selector, in the same order as
  /// [_demoResults]: the first entry reflects the live reading, the rest stay
  /// demo. Values themselves remain the canonical [_demoResults] instances so
  /// the DropdownButton `value` always matches exactly one item.
  List<_DiagnosisResult> _selectorOptions(LatestPlantReading? reading) => [
    if (reading != null) _liveResult(reading) else _demoResults.first,
    _demoResults[1],
    _demoResults[2],
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Appbar with only ios back button
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Center(
          child: const Text(
            'Hasil Diagnosis',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        actions: [
          // share button
          IconButton(
            icon: const Icon(Icons.share_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: StreamBuilder<LatestPlantReading?>(
          stream: watchLatestPlantReading(),
          builder: (context, snapshot) {
            final reading = snapshot.data;
            final result = _effectiveResult(reading);
            print('AiDiagnosisScreen.build: reading=$reading, result=$result');
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 24),
                  // Dropdown to switch between diagnosis results — same pattern
                  // as the plant selector on the Kontrol IoT page.
                  _DiagnosisSelector(
                    selected: _selected,
                    options: _selectorOptions(reading),
                    onChanged: (selection) =>
                        setState(() => _selected = selection),
                  ),
                  const SizedBox(height: 24),
                  // Foto + referensi images, driven by the selected result.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      diagnosisImage(context, result.fotoImage, false),
                      diagnosisImage(context, result.referensiImage, true),
                    ],
                  ),
                  const SizedBox(height: 32),
                  plantStatus(result),
                  const SizedBox(height: 32),
                  // Happy/Normal → "Saran Ke Depan"; Sad → Gejala + Dampak.
                  if (result.mood.isGood) ...[
                    goodSuggestion(),
                  ] else ...[
                    const MainSymptomCard(),
                    const SizedBox(height: 32),
                    mainImpact(),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Container mainImpact() {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.warning_amber_outlined,
                  color: Colors.red,
                  size: 24,
                ),
              ),
              SizedBox(width: 16),
              Text(
                'DAMPAK UTAMA',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Muncul bintik-bintik kuning kecil yang basah pada pinggiran daun. Seiring waktu, bintik ini akan berubah menjadi coklat tua dengan lingkaran kuning di sekelilingnya.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  Container goodSuggestion() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.max,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  'assets/icons/thunder.svg',
                  colorFilter: const ColorFilter.mode(
                    AppColors.primary,
                    BlendMode.srcIn,
                  ),
                  width: 24,
                  height: 24,
                ),
              ),
              SizedBox(width: 16),
              Text(
                'SARAN KE DEPAN',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Tanaman sehat dan tumbuh optimal. Pertahankan perawatan rutin agar kondisinya tetap prima.',
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
          //numbering with the bullet color is container circle with color primary and text white
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '1',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Lakukan penyiraman secara rutin, terutama pada pagi dan sore hari.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '2',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Pastikan tanaman mendapatkan cukup sinar matahari, namun hindari paparan langsung yang berlebihan.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text(
                        '3',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Gunakan pupuk organik secara berkala untuk menjaga kesuburan tanah dan kesehatan tanaman.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container plantStatus(_DiagnosisResult result) {
    final confident = result.confident;
    final accuracyLevel = confident >= 0.9
        ? 'SANGAT TINGGI'
        : confident >= 0.7
        ? 'TINGGI'
        : 'RENDAH';
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  result.diseaseName ?? 'Nama Penyakit Tidak Diketahui',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Container with % keyakinan
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  '${(confident * 100).round()}% Keyakinan',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 42),
          // Status bar On the left is Tingkat keakuratan ai, on the right is the indicator SANGAT TINGGI TINGGI OR RENDAH
          // THE TEXT IS ON THE TOP
          // AND THE BAR IS ON THE OTTOM OF THE TEXT
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  'TINGKAT KEAKURATAN AI',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                accuracyLevel,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // The bar is a container with 100% width and 8 height, with a border
          // radius of 999, and a gradient from red to yellow to green.
          // It is reactive: the fill width follows the AI confidence.
          _ConfidenceBar(confident: confident),
        ],
      ),
    );
  }

  SizedBox diagnosisImage(
    BuildContext context,
    String imagePath,
    bool isReference,
  ) {
    print('diagnosisImage: $imagePath, isReference: $isReference');
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.45,
      height: MediaQuery.of(context).size.width * 0.45,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!, width: 1.5),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: imagePath.startsWith('http')
                  ? Image.network(
                      imagePath,
                      fit: BoxFit.cover,
                      // errorBuilder: (_, __, ___) => Image.asset(
                      //   'assets/images/daftar_kebun.png',
                      //   fit: BoxFit.cover,
                      // ),
                    )
                  : Image.asset(imagePath, fit: BoxFit.cover),
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              width: double.infinity,
              decoration: BoxDecoration(
                color: isReference
                    ? Colors.black.withValues(alpha: 0.60)
                    : AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  isReference ? 'REFERENSI' : 'FOTO ANDA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MainSymptomCard extends StatelessWidget {
  const MainSymptomCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.yellow.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SvgPicture.asset(
                  'assets/icons/eye.svg',
                  colorFilter: ColorFilter.mode(
                    Colors.yellow[800]!,
                    BlendMode.srcIn,
                  ),
                  width: 24,
                  height: 24,
                ),
              ),
              SizedBox(width: 16),
              Text(
                'GEJALA UTAMA',
                style: TextStyle(
                  color: Colors.black,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  height: 1.50,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            'Muncul bintik-bintik kuning kecil yang basah pada pinggiran daun. Seiring waktu, bintik ini akan berubah menjadi coklat tua dengan lingkaran kuning di sekelilingnya.',
            style: TextStyle(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
// ---------------------------------------------------------------------------
// Diagnosis dropdown (same pattern as the Kontrol IoT plant selector)
// ---------------------------------------------------------------------------

/// Dropdown to switch between diagnosis results.
///
/// The **whole container** is the trigger and the menu items reuse the exact
/// same row layout as the selected value.
class _DiagnosisSelector extends StatelessWidget {
  const _DiagnosisSelector({
    required this.selected,
    required this.onChanged,
    required this.options,
  });

  /// Currently selected result — must stay one of the [_demoResults] instances
  /// so the DropdownButton `value` always matches exactly one item.
  final _DiagnosisResult selected;
  final ValueChanged<_DiagnosisResult> onChanged;

  /// Rendered variants in the same order as [_demoResults]: the first entry is
  /// the live-driven twin of Selada Sehat when a reading is available, and the
  /// rest are the demo originals.
  final List<_DiagnosisResult> options;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.15),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButtonHideUnderline(
            // The DropdownButton fills the container, so tapping anywhere on
            // the bar opens the list.
            child: DropdownButton<_DiagnosisResult>(
              value: selected,
              isExpanded: true,
              isDense: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              borderRadius: BorderRadius.circular(14),
              menuWidth: width,
              dropdownColor: Colors.white,
              icon: const SizedBox.shrink(),
              selectedItemBuilder: (context) => [
                for (var i = 0; i < _demoResults.length; i++)
                  _DiagnosisRow(
                    result: options[i],
                    showChevron: true,
                    isSelected: _demoResults[i] == selected,
                  ),
              ],
              items: [
                for (var i = 0; i < _demoResults.length; i++)
                  DropdownMenuItem(
                    // Values stay the canonical demo instances so the widget
                    // assertion "value must be exactly one item" always holds,
                    // even when the *displayed* option is a live-driven twin.
                    value: _demoResults[i],
                    child: _DiagnosisRow(
                      result: options[i],
                      showChevron: false,
                      isSelected: _demoResults[i] == selected,
                    ),
                  ),
              ],
              onChanged: (result) {
                if (result != null) onChanged(result);
              },
            ),
          ),
        );
      },
    );
  }
}

/// Shared row used both as the dropdown's selected value and as each menu
/// item — so the whole list looks identical to the selected value.
class _DiagnosisRow extends StatelessWidget {
  const _DiagnosisRow({
    required this.result,
    this.showChevron = false,
    this.isSelected = false,
  });

  final _DiagnosisResult result;
  final bool showChevron;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            result.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 15,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: result.emoticonAsset != null
              ? Image.asset(
                  result.emoticonAsset!,
                  width: 40,
                  height: 40,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _EmoticonPlaceholder(),
                )
              : const _EmoticonPlaceholder(),
        ),
        if (showChevron)
          const Icon(Icons.keyboard_arrow_down, color: Colors.black54)
        else if (isSelected)
          Icon(Icons.check_circle, color: result.mood.color, size: 20),
      ],
    );
  }
}

class _EmoticonPlaceholder extends StatelessWidget {
  const _EmoticonPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      color: const Color(0xFFE9F3E9),
      child: const Icon(Icons.emoji_emotions, color: Color(0xFF9CAF88)),
    );
  }
}
// ---------------------------------------------------------------------------
// Confidence bar (reactive to the AI confidence level)
// ---------------------------------------------------------------------------

/// A red → yellow → green bar that fills proportionally to [confident]
/// (0.0 – 1.0) and animates smoothly when the value changes.
class _ConfidenceBar extends StatelessWidget {
  const _ConfidenceBar({required this.confident});

  final double confident;

  static const List<Color> _gradient = [
    Color(0xFFEF4444),
    Color(0xFFFACC15),
    Color(0xFF22C55E),
  ];

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: confident.clamp(0.0, 1.0).toDouble()),
      duration: const Duration(milliseconds: 700),
      curve: Curves.easeOutCubic,
      builder: (context, value, _) {
        return SizedBox(
          width: double.infinity,
          height: 8,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Track.
                Container(color: Colors.grey.withValues(alpha: 0.25)),
                // Fill — width follows the confidence value.
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: _gradient,
                        stops: [0.0, 0.5, 1.0],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
