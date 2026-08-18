import 'package:cakmoji_flutter/core/app_colors.dart';
import 'package:cakmoji_flutter/screens/kontrol_iot/kontrol_iot_live_data.dart';
import 'package:cakmoji_flutter/screens/kontrol_iot/kontrol_status/kontrol_status_page.dart';
import 'package:cakmoji_flutter/services/supabase_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Kontrol IoT screen (Figma → code), rebuilt responsive.
///
/// Sections: plant health header (Pakcoy + health bar), achievements,
/// environment metrics, recent activity timeline and two actions.
class KontrolIotPage extends StatefulWidget {
  const KontrolIotPage({super.key});

  static const Color _ink = Color(0xFF0F172A);
  static const Color _muted = Color(0xFF64748B);
  static const Color _hint = Color(0xFF94A3B8);
  static const Color _line = Color(0xFFF1F5F9);
  static const Color _green = Color(0xFF4ADE80);
  static const Color _primaryGreen = Color(0xFF097004);

  @override
  State<KontrolIotPage> createState() => _KontrolIotPageState();
}

class _KontrolIotPageState extends State<KontrolIotPage> {
  /// When the signed-in user's Supabase `profiles` row was created
  /// (`created_at`). The harvest countdown is measured from here: the plant is
  /// ready to harvest 17 days after the account was created.
  DateTime? _userCreatedAt;

  /// How many days after the user's account creation the plant is ready to
  /// harvest.
  static const int _harvestDays = 17;

  @override
  void initState() {
    super.initState();
    _loadUserCreatedAt();
  }

  /// Fetches the signed-in profile's `created_at` to drive the harvest
  /// countdown. Falls back to `null` (demo value) when offline / uninitialized,
  /// mirroring the guarded access used by the profile screen.
  Future<void> _loadUserCreatedAt() async {
    DateTime? createdAt;
    try {
      final profile = await SupabaseService.instance.fetchProfile();
      final raw = profile?['created_at'];
      if (raw is String) createdAt = DateTime.tryParse(raw);
    } catch (_) {
      createdAt = null;
    }
    if (!mounted || createdAt == null) return;
    setState(() => _userCreatedAt = createdAt);
  }

  /// Days left until harvest: `harvestDays - (now - userCreatedAt)`.
  ///
  /// When no profile date is available it falls back to the full demo duration
  /// so the card keeps showing "17 Hari lagi panen". Returns `0` once the
  /// harvest date has already passed, which signals the ready-to-harvest state.
  int _daysLeftToHarvest() {
    final createdAt = _userCreatedAt;
    if (createdAt == null) return _harvestDays;
    final elapsed = DateTime.now().difference(createdAt).inDays;
    final left = _harvestDays - elapsed;
    return left < 0 ? 0 : left;
  }

  _PlantOption _selectedPlant = _demoPlants.first;

  /// The plant rendered by the UI. Only the first plant (Selada Keriting) is
  /// driven by the live Firebase data (`devices/device1/live`); the other two
  /// gardens keep their static demo values until they are wired up too.
  _PlantOption _effectivePlant(KontrolIotLiveData? live) {
    if (live == null || _selectedPlant != _demoPlants.first) {
      return _selectedPlant;
    }
    return _liveTwin(live);
  }

  /// Live-driven twin of the first demo plant: status, health score and the
  /// matching Emotigrow emoticon all follow the current `final_output`.
  _PlantOption _liveTwin(KontrolIotLiveData live) {
    return _PlantOption(
      name: _demoPlants.first.name,
      status: _statusOf(live.status),
      health: live.healthValue,
      imageAsset: _demoPlants.first.imageAsset,
      emoticonAssetBig: _emoticonBig(live.status),
      emoticonAssetSmall: _emoticonSmall(live.status),
    );
  }

  /// Options rendered by the plant selector, in the same order as
  /// [_demoPlants]: the first entry reflects live data, the rest stay demo.
  List<_PlantOption> _selectorOptions(KontrolIotLiveData? live) => [
    if (live != null) _liveTwin(live) else _demoPlants.first,
    _demoPlants[1],
    _demoPlants[2],
  ];

  _PlantStatus _statusOf(KontrolIotStatus status) => switch (status) {
    KontrolIotStatus.sehat => _PlantStatus.sehat,
    KontrolIotStatus.perhatian => _PlantStatus.perhatian,
    KontrolIotStatus.darurat => _PlantStatus.darurat,
  };

  /// Avatar that matches a live health level (same expressions as the demo
  /// plants: happy → normal → sad).
  String _emoticonBig(KontrolIotStatus status) => switch (status) {
    KontrolIotStatus.sehat => 'assets/images/agrimoji_happy.png',
    KontrolIotStatus.perhatian => 'assets/images/agrimoji_flat.png',
    KontrolIotStatus.darurat => 'assets/images/agrimoji_sad.png',
  };

  /// Dropdown thumbnail that matches a live health level.
  String _emoticonSmall(KontrolIotStatus status) => switch (status) {
    KontrolIotStatus.sehat => 'assets/images/opsi_happy.png',
    KontrolIotStatus.perhatian => 'assets/images/opsi_flat.png',
    KontrolIotStatus.darurat => 'assets/images/opsi_sad.png',
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Appbar with only ios back button
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: KontrolIotPage._ink),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SizedBox.expand(
          child: Stack(
            children: [
              // Live IoT data (`devices/device1/live`) only drives the first
              // plant (Selada Keriting); all parsing lives in
              // kontrol_iot_live_data.dart so this screen stays small.
              StreamBuilder<KontrolIotLiveData?>(
                stream: watchKontrolIotLiveData(),
                builder: (context, snapshot) {
                  final live = snapshot.data;
                  final plant = _effectivePlant(live);
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 560),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Image.asset(
                                    plant.emoticonAssetBig,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Image.asset(
                                    plant.imageAsset,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                            _HealthBar(
                              value: plant.health,
                              label: '${(plant.health * 100).round()}/100',
                            ),
                            const SizedBox(height: 16),
                            _PlantSelector(
                              // `value` stays one of the canonical demo
                              // instances (DropdownButton requires it to be
                              // exactly one of its items); the live-driven
                              // variant is only used for *rendering* via
                              // `options`.
                              selected: _selectedPlant,
                              options: _selectorOptions(live),
                              onChanged: (selection) =>
                                  setState(() => _selectedPlant = selection),
                            ),

                            SizedBox(height: 16),
                            _AchievementsCard(
                              plant: plant,
                              daysLeftToHarvest: _daysLeftToHarvest(),
                            ),
                            SizedBox(height: 20),
                            _SectionTitle(
                              title: 'Lingkungan',
                              svg: 'assets/icons/hotspot.svg',
                              timestamp: live?.timestamp ?? DateTime.now(),
                            ),
                            SizedBox(height: 12),
                            _MetricsGrid(live: live),
                            // SizedBox(height: 20),
                            // _SectionTitle(
                            //   title: 'Aktivitas Terakhir',
                            //   svg: 'assets/icons/history.svg',
                            // ),
                            // SizedBox(height: 16),
                            // _ActivityTimeline(),
                            // SizedBox(
                            //   height: MediaQuery.of(context).size.height * 0.1,
                            // ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              // Positioned(
              //   bottom: 0,
              //   left: 0,
              //   right: 0,
              //   child: Container(
              //     padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              //     color: Colors.white,
              //     child: const _ActionButtons(),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}

// -- Plant status / plant selector -------------------------------------------
enum _PlantStatus {
  sehat('Sehat', Color(0xFF16A34A), Color(0xFFDCFCE7)),
  perhatian('Perhatian', Color(0xFFF59E0B), Color(0xFFFEF3C7)),
  darurat('Darurat', Color(0xFFEF4444), Color(0xFFFEE2E2));

  const _PlantStatus(this.label, this.color, this.bg);

  final String label;
  final Color color;
  final Color bg;
}

class _PlantOption {
  const _PlantOption({
    required this.name,
    required this.status,
    required this.health,
    required this.imageAsset,
    required this.emoticonAssetBig,
    required this.emoticonAssetSmall,
  });

  final String name;
  final _PlantStatus status;
  final double health;
  final String imageAsset;
  final String emoticonAssetBig;
  final String emoticonAssetSmall;
}
// String _emoticonBig(KontrolIotStatus status) => switch (status) {
//   KontrolIotStatus.sehat => 'assets/images/agrimoji_happy.png',
//   KontrolIotStatus.perhatian => 'assets/images/agrimoji_flat.png',
//   KontrolIotStatus.darurat => 'assets/images/agrimoji_sad.png',
// };

// /// Dropdown thumbnail that matches a live health level.
// String _emoticonSmall(KontrolIotStatus status) => switch (status) {
//   KontrolIotStatus.sehat => 'assets/images/opsi_happy.png',
//   KontrolIotStatus.perhatian => 'assets/images/opsi_flat.png',
//   KontrolIotStatus.darurat => 'assets/images/opsi_sad.png',
// };

/// Demo garden plants — replace with data from your backend.
const List<_PlantOption> _demoPlants = [
  _PlantOption(
    name: 'Selada Keriting A',
    status: _PlantStatus.sehat,
    health: 1,
    imageAsset: 'assets/images/selada.png',
    emoticonAssetBig: 'assets/images/agrimoji_happy.png',
    emoticonAssetSmall: 'assets/images/opsi_happy.png',
  ),
  _PlantOption(
    name: 'Selada Keriting B',
    status: _PlantStatus.perhatian,
    health: 0.55,
    imageAsset: 'assets/images/selada.png',
    emoticonAssetBig: 'assets/images/agrimoji_flat.png',
    emoticonAssetSmall: 'assets/images/opsi_flat.png',
  ),
  _PlantOption(
    name: 'Selada Keriting C',
    status: _PlantStatus.darurat,
    health: 0.3,
    imageAsset: 'assets/images/selada.png',
    emoticonAssetBig: 'assets/images/agrimoji_sad.png',
    emoticonAssetSmall: 'assets/images/opsi_sad.png',
  ),
];

/// Bar shown right under the app bar: current plant name + status + a dropdown
/// to switch to another plant.
///
/// The **whole container** is the dropdown trigger, and the menu items reuse
/// the exact same row layout as the selected value (thumbnail + name + status).
class _PlantSelector extends StatelessWidget {
  const _PlantSelector({
    required this.selected,
    required this.onChanged,
    required this.options,
  });

  /// Currently selected garden — must stay one of the [_demoPlants] instances
  /// so the DropdownButton `value` always matches exactly one item.
  final _PlantOption selected;
  final ValueChanged<_PlantOption> onChanged;

  /// Rendered variants in the same order as [_demoPlants]: the first entry is
  /// the live-driven twin of Selada Keriting when live data is available, and
  /// the rest are the demo originals.
  final List<_PlantOption> options;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0x332F7F33), width: 2),
          ),
          child: DropdownButtonHideUnderline(
            // The DropdownButton fills the container, so tapping anywhere on
            // the bar opens the list.
            child: DropdownButton<_PlantOption>(
              value: selected,
              isExpanded: true,
              isDense: false,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              borderRadius: BorderRadius.circular(14),
              menuWidth: width,
              dropdownColor: Colors.white,
              icon: const SizedBox.shrink(),
              selectedItemBuilder: (context) => [
                for (var i = 0; i < _demoPlants.length; i++)
                  _SelectorRow(
                    option: options[i],
                    showChevron: true,
                    isSelected: _demoPlants[i] == selected,
                  ),
              ],
              items: [
                for (var i = 0; i < _demoPlants.length; i++)
                  DropdownMenuItem(
                    // Values stay the canonical demo instances so the widget
                    // assertion "value must be exactly one item" always holds,
                    // even when the *displayed* option is a live-driven twin.
                    value: _demoPlants[i],
                    child: _SelectorRow(
                      option: options[i],
                      showChevron: false,
                      isSelected: _demoPlants[i] == selected,
                    ),
                  ),
              ],
              onChanged: (plant) {
                if (plant != null) onChanged(plant);
              },
            ),
          ),
        );
      },
    );
  }
}

/// The shared row used both as the dropdown's selected value and as each menu
/// item — so the dropdown list looks identical to the selected value.
class _SelectorRow extends StatelessWidget {
  const _SelectorRow({
    required this.option,
    this.showChevron = false,
    this.isSelected = false,
  });

  final _PlantOption option;
  final bool showChevron;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                option.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: KontrolIotPage._ink,
                  fontSize: 15,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.asset(
            option.emoticonAssetSmall,
            width: 40,
            height: 40,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: 40,
              height: 40,
              color: const Color(0xFFE9F3E9),
              child: const Icon(Icons.eco, color: Color(0xFF9CAF88)),
            ),
          ),
        ),
        if (showChevron)
          const Icon(Icons.keyboard_arrow_down, color: KontrolIotPage._ink)
        else if (isSelected)
          Icon(Icons.check_circle, color: option.status.color, size: 20),
      ],
    );
  }
}

class _HealthBar extends StatelessWidget {
  const _HealthBar({required this.value, required this.label});

  final double value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(40),
          child: SizedBox(
            height: 12,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: const Color(0xFFF0EBEB)),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: value.clamp(0.0, 1.0).toDouble(),
                  child: Container(color: const Color(0xFFED2222)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 10,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// -- Achievements card -------------------------------------------------------
class _AchievementsCard extends StatelessWidget {
  const _AchievementsCard({
    required this.plant,
    required this.daysLeftToHarvest,
  });

  final _PlantOption plant;

  /// Days remaining until harvest (0 means the harvest date has passed).
  final int daysLeftToHarvest;

  @override
  Widget build(BuildContext context) {
    // Achievement bullets follow plant health (unchanged behavior).
    final isReadyToHarvest = plant.health >= 1.0;
    // The harvest box is driven by the countdown from the user's `created_at`:
    // once the remaining days hit zero the plant is ready to harvest.
    final isHarvestReady = daysLeftToHarvest <= 0;
    final harvestLabel = isHarvestReady
        ? 'JUAL'
        : '$daysLeftToHarvest Hari lagi panen';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      decoration: BoxDecoration(
        color: isHarvestReady ? AppColors.secondary : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      // height: MediaQuery.of(context).size.height * 0.1,
      width: MediaQuery.of(context).size.width * 0.3,
      child: Center(
        child: Text(
          harvestLabel,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isHarvestReady ? Colors.white : KontrolIotPage._ink,
            fontSize: 16,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _AchievementBullet extends StatelessWidget {
  const _AchievementBullet(this.text, this.isReadyToHarvest);

  final String text;
  final bool isReadyToHarvest;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: KontrolIotPage._muted,
              fontSize: 11,
              fontFamily: 'Inter',
            ),
          ),
        ),
        Icon(
          Icons.circle,
          size: 8,
          color: isReadyToHarvest ? AppColors.secondary : Colors.red,
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

// -- Section title -----------------------------------------------------------
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.svg, this.timestamp});
  final String title;
  final String svg;
  final DateTime? timestamp;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SvgPicture.asset(
          svg,
          width: 20,
          height: 20,
          colorFilter: const ColorFilter.mode(
            KontrolIotPage._primaryGreen,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: KontrolIotPage._ink,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w700,
          ),
        ),
        Spacer(),
        timestamp != null
            // Terakhir diperbarui tanggal/bulan/tahun jam:menit, misal "Terakhir: 06:30"
            ? Text(
                'Terakhir diperbarui ${timestamp!.day.toString().padLeft(2, '0')}/${timestamp!.month.toString().padLeft(2, '0')}/${timestamp!.year} ${timestamp!.hour.toString().padLeft(2, '0')}:${timestamp!.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                  color: KontrolIotPage._muted,
                  fontSize: 10,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
              )
            : const SizedBox.shrink(),
      ],
    );
  }
}

// -- Environment metrics (responsive grid) -----------------------------------
class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({this.live});

  /// Live IoT readings; `null` keeps the static demo values on screen.
  final KontrolIotLiveData? live;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Taller cards on narrow phones so the content never overflows.
        final aspect = constraints.maxWidth < 350 ? 0.72 : 0.92;
        return GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: aspect,
          children: [
            _MetricCard(
              svg: 'assets/icons/suhu.svg',
              icon: Icons.thermostat,
              label: 'SUHU',
              value: live?.tempLabel ?? '24°C',
            ),
            _MetricCard(
              svg: 'assets/icons/cahaya.svg',
              icon: Icons.wb_sunny_outlined,
              label: 'CAHAYA',
              value: live?.luxLabel ?? '60%',
            ),
            _MetricCard(
              svg: 'assets/icons/ph.svg',
              icon: Icons.science_outlined,
              label: 'PH',
              value: live?.phLabel ?? '6.5',
            ),
            _MetricCard(
              svg: 'assets/icons/ec.svg',
              icon: Icons.waves,
              label: 'EC',
              value: live?.ecLabel ?? '700',
            ),
          ],
        );
      },
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.svg,
  });

  final IconData icon;
  final String label;
  final String value;
  final String svg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: KontrolIotPage._line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0C000000),
            blurRadius: 2,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(svg, width: 20, height: 20),
          const SizedBox(height: 6),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: KontrolIotPage._muted,
              fontSize: 9,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: KontrolIotPage._ink,
              fontSize: 15,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// -- Activity timeline -------------------------------------------------------
class _ActivityTimeline extends StatelessWidget {
  const _ActivityTimeline();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        _ActivityTile(
          circleColor: Color(0x194ADE80),
          icon: Icons.qr_code_scanner,
          iconColor: Color(0xFF16A34A),
          title: 'Scan Kesehatan',
          time: '06:00',
          subtitle: 'Hasil scan menunjukkan kondisi daun optimal tanpa hama.',
        ),
        Padding(
          padding: EdgeInsets.only(left: 19),
          child: _TimelineConnector(),
        ),
        _ActivityTile(
          circleColor: Color(0xFFDBEAFE),
          icon: Icons.bug_report_outlined,
          iconColor: Color(0xFF2563EB),
          title: 'Deteksi Penyakit',
          time: 'Kemarin',
          subtitle: 'Hasil scan menunjukkan kondisi daun terjangkit hama.',
        ),
      ],
    );
  }
}

class _TimelineConnector extends StatelessWidget {
  const _TimelineConnector();

  @override
  Widget build(BuildContext context) {
    return Container(width: 2, height: 18, color: KontrolIotPage._line);
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({
    required this.circleColor,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.time,
    required this.subtitle,
  });

  final Color circleColor;
  final IconData icon;
  final Color iconColor;
  final String title;
  final String time;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(color: circleColor, shape: BoxShape.circle),
          child: Icon(icon, size: 20, color: iconColor),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        color: KontrolIotPage._ink,
                        fontSize: 14,
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text(
                    time,
                    style: const TextStyle(
                      color: KontrolIotPage._hint,
                      fontSize: 10,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: KontrolIotPage._muted,
                  fontSize: 12,
                  fontFamily: 'Inter',
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// -- Action buttons ----------------------------------------------------------
class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final narrow = constraints.maxWidth < 360;
        final control = _Button(
          label: 'Control Status',
          icon: Icons.tune,
          filled: false,
          onTap: () {
            // navigate into KontrolStatusPage with a slide transition from right to left using cupertino style by default not using custom
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const KontrolStatusPage(),
              ),
            );
          },
        );
        final flex = _Button(
          label: 'Flex Your Plant',
          icon: Icons.photo_camera,
          filled: true,
        );

        if (narrow) {
          return Column(children: [control, const SizedBox(height: 12), flex]);
        }
        return Row(
          children: [
            Expanded(child: control),
            const SizedBox(width: 12),
            Expanded(child: flex),
          ],
        );
      },
    );
  }
}

class _Button extends StatelessWidget {
  const _Button({
    required this.label,
    required this.icon,
    required this.filled,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  // Custom on tap function that can be added
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
    );
    final labelWidget = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: KontrolIotPage._ink,
        fontSize: 14,
        fontFamily: 'Inter',
        fontWeight: FontWeight.w700,
      ),
    );

    if (!filled) {
      return OutlinedButton.icon(
        onPressed: onTap ?? () {},
        icon: Icon(icon, size: 18, color: KontrolIotPage._ink),
        label: labelWidget,
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 2),
          shape: shape,
          foregroundColor: KontrolIotPage._ink,
        ),
      );
    }
    return FilledButton.icon(
      onPressed: onTap ?? () {},
      icon: Icon(icon, size: 18, color: KontrolIotPage._ink),
      label: labelWidget,
      style: FilledButton.styleFrom(
        backgroundColor: KontrolIotPage._green,
        foregroundColor: KontrolIotPage._ink,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        shape: shape,
        elevation: 0,
      ),
    );
  }
}
