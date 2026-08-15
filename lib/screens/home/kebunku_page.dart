import 'package:flutter/material.dart';

/// Kebunku (My Garden) page.
///
/// Plants are organised by health status:
/// - **Sehat**     → emoji `cakmoji_happy.png`, green accent / border.
/// - **Perhatian** → emoji `cakmoji_flat.png`, orange accent / border.
/// - **Darurat**   → emoji `cakmoji_sad.png`, red accent / border + red-tinted bg.
///
/// A "Semua" filter shows every plant.

// ---------------------------------------------------------------------------
// Status model
// ---------------------------------------------------------------------------

enum PlantStatus {
  sehat(
    label: 'Sehat',
    badge: 'SEHAT',
    assetIcon: 'assets/images/opsi_happy.png',
    color: Color(0xFF22C55E),
    badgeTextColor: Color(0xFF15803D),
    badgeBgColor: Color(0xFFDCFCE7),
    badgeIcon: Icons.check_circle_outline,
  ),
  perhatian(
    label: 'Perhatian',
    badge: 'PERHATIAN',
    assetIcon: 'assets/images/opsi_flat.png',
    color: Color(0xFFF97316),
    badgeTextColor: Color(0xFFB45309),
    badgeBgColor: Color(0xFFFEF3C7),
    badgeIcon: Icons.warning_amber_outlined,
  ),
  darurat(
    label: 'Darurat',
    badge: 'DARURAT',
    assetIcon: 'assets/images/opsi_sad.png',
    color: Color(0xFFEF4444),
    badgeTextColor: Color(0xFFB91C1C),
    badgeBgColor: Color(0xFFFEE2E2),
    badgeIcon: Icons.error_outline,
  );

  const PlantStatus({
    required this.label,
    required this.badge,
    required this.assetIcon,
    required this.color,
    required this.badgeTextColor,
    required this.badgeBgColor,
    required this.badgeIcon,
  });

  /// Human-readable label.
  final String label;

  /// Uppercase badge text (e.g. "SEHAT").
  final String badge;

  /// Emoji asset used as the status prefix icon.
  final String assetIcon;

  /// Accent color — used for the card border and active filter styling.
  final Color color;

  final Color badgeTextColor;
  final Color badgeBgColor;
  final IconData? badgeIcon;

  /// Card background: "Darurat" gets a red-tinted background, everything else
  /// (Sehat / Perhatian) stays white.
  Color get cardBackground =>
      this == PlantStatus.darurat ? const Color(0x0FEF4444) : Colors.white;
}

// ---------------------------------------------------------------------------
// Filter model
// ---------------------------------------------------------------------------

enum KebunFilter {
  semua('Semua'),
  sehat('Sehat'),
  perhatian('Perhatian'),
  darurat('Darurat');

  const KebunFilter(this.label);

  final String label;

  /// `semua` matches everything; the others match their own status only.
  bool matches(PlantStatus status) =>
      this == KebunFilter.semua || name == status.name;

  /// The status this filter represents, or `null` for `semua`.
  PlantStatus? get status => switch (this) {
    KebunFilter.semua => null,
    KebunFilter.sehat => PlantStatus.sehat,
    KebunFilter.perhatian => PlantStatus.perhatian,
    KebunFilter.darurat => PlantStatus.darurat,
  };
}

// ---------------------------------------------------------------------------
// Status emoji image
// ---------------------------------------------------------------------------
class _StatusEmoji extends StatelessWidget {
  const _StatusEmoji({required this.path, this.size = 30});

  final String path;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      path,
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, __, ___) => Icon(
        Icons.emoji_emotions,
        size: size,
        color: const Color(0xFF9CA3AF),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Filter bar: Semua + Sehat + Perhatian + Darurat
// ---------------------------------------------------------------------------
class PlantStatusFilter extends StatelessWidget {
  const PlantStatusFilter({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final KebunFilter selected;
  final ValueChanged<KebunFilter> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Row(
          children: [
            for (final filter in KebunFilter.values) ...[
              _FilterChip(
                filter: filter,
                selected: filter == selected,
                onTap: () => onSelected(filter),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.filter,
    required this.selected,
    required this.onTap,
  });

  final KebunFilter filter;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // "Semua" uses the brand green; status filters use their own accent.
    final activeColor = filter.status?.color ?? const Color(0xFF097004);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 36,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: selected
              ? activeColor.withValues(alpha: 0.12)
              : const Color(0xFFF5F8F6),
          borderRadius: BorderRadius.circular(9999),
          border: Border.all(
            color: selected ? activeColor : const Color(0xFFE5E7EB),
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: activeColor.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (filter.status != null)
              _StatusEmoji(path: filter.status!.assetIcon, size: 30)
            else
              Icon(Icons.grid_view_rounded, size: 18, color: activeColor),
            const SizedBox(width: 8),
            Text(
              filter.label,
              style: TextStyle(
                color: selected ? activeColor : const Color(0xFF374151),
                fontSize: 14,
                fontFamily: 'Inter',
                fontWeight: FontWeight.w500,
                height: 1.43,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Plant card (status-aware)
// ---------------------------------------------------------------------------
class PlantCard extends StatelessWidget {
  const PlantCard({
    super.key,
    required this.name,
    required this.detail,
    required this.status,
    this.imageAsset,
    this.temperature = '24°C',
    this.humidity = '65%',
    this.ph = 'pH 6.5',
    this.onTap,
  });

  final String name;
  final String detail;

  /// Health status — drives border, background and badge colours.
  final PlantStatus status;

  /// Optional plant photo. Falls back to a soft placeholder.
  final String? imageAsset;

  final String temperature;
  final String humidity;
  final String ph;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: status.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: status.color, width: 0.5),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
            BoxShadow(color: Color(0xFFF3F4F6), blurRadius: 0, spreadRadius: 1),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PlantThumbnail(
              imageAsset: imageAsset,
              emojiAsset: status.assetIcon,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF111827),
                                fontSize: 16,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w700,
                                height: 1.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              detail,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Color(0xFF6B7280),
                                fontSize: 12,
                                fontFamily: 'Inter',
                                fontWeight: FontWeight.w400,
                                height: 1.33,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusBadge(status: status),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MetricsRow(
                    temperature: temperature,
                    humidity: humidity,
                    ph: ph,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});

  final PlantStatus status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: status.badgeBgColor,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        children: [
          Icon(status.badgeIcon, size: 12, color: status.color),
          SizedBox(width: 4),
          Text(
            status.badge,
            style: TextStyle(
              color: status.badgeTextColor,
              fontSize: 10,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              height: 1.5,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _PlantThumbnail extends StatelessWidget {
  const _PlantThumbnail({this.imageAsset, required this.emojiAsset});

  final String? imageAsset;
  final String emojiAsset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          imageAsset != null
              ? Image.asset(
                  imageAsset!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => const _PlantPlaceholder(),
                )
              : const _PlantPlaceholder(),
          // Positioned(
          //   right: 4,
          //   bottom: 4,
          //   child: _StatusEmoji(path: emojiAsset, size: 34),
          // ),
        ],
      ),
    );
  }
}

class _PlantPlaceholder extends StatelessWidget {
  const _PlantPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE9F3E9),
      child: const Icon(Icons.eco, color: Color(0xFF9CAF88), size: 40),
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({
    required this.temperature,
    required this.humidity,
    required this.ph,
  });

  final String temperature;
  final String humidity;
  final String ph;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(top: 10),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Row(
        children: [
          _Metric(icon: Icons.thermostat, value: temperature),
          const _MetricDivider(),
          _Metric(icon: Icons.water_drop_outlined, value: humidity),
          const _MetricDivider(),
          _Metric(icon: Icons.science_outlined, value: ph),
        ],
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.icon, required this.value});

  final IconData icon;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 18, color: const Color(0xFF6B7280)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: Color(0xFF374151),
              fontSize: 12,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              height: 1.33,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricDivider extends StatelessWidget {
  const _MetricDivider();

  @override
  Widget build(BuildContext context) {
    return Container(width: 1, height: 32, color: const Color(0xFFF3F4F6));
  }
}

// ---------------------------------------------------------------------------
// Page
// ---------------------------------------------------------------------------

class KebunkuPage extends StatefulWidget {
  const KebunkuPage({super.key});

  @override
  State<KebunkuPage> createState() => _KebunkuPageState();
}

class _KebunkuPageState extends State<KebunkuPage> {
  KebunFilter _filter = KebunFilter.semua;

  /// Demo plants — replace with data from your backend.
  static const List<PlantCard> _plants = [
    PlantCard(
      name: 'Selada Keriting',
      detail: 'Dataran tinggi',
      status: PlantStatus.sehat,
      imageAsset: 'assets/images/selada_keriting.png',
    ),
    PlantCard(
      name: 'Pakcoy',
      detail: 'Dataran tinggi/rendah',
      status: PlantStatus.perhatian,
      temperature: '32',
      humidity: '40%',
      ph: 'pH 6.5',
      imageAsset: 'assets/images/pakcoy.png',
    ),
    PlantCard(
      name: 'Cabai Rawit',
      detail: 'Lahan terbuka',
      imageAsset: 'assets/images/cabai.png',
      status: PlantStatus.darurat,
      temperature: '31°C',
      humidity: '54%',
      ph: 'pH 5.9',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final visible = _plants.where((p) => _filter.matches(p.status)).toList();

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        PlantStatusFilter(
          selected: _filter,
          onSelected: (filter) => setState(() => _filter = filter),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: visible.isEmpty
              ? const Center(
                  child: Text(
                    'Tidak ada tanaman',
                    style: TextStyle(
                      color: Color(0xFF6B7280),
                      fontSize: 14,
                      fontFamily: 'Inter',
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  itemCount: visible.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, index) => visible[index],
                ),
        ),
      ],
    );
  }
}
