import 'package:flutter/material.dart';

import '../core/app_colors.dart';

/// A single destination in an [AppBottomNav].
class BottomNavItem {
  const BottomNavItem({this.icon, required this.label, this.customIcon});

  final IconData? icon;
  final String label;
  final Widget? customIcon;
}

/// Reusable bottom navigation bar matching the Cakmoji design:
/// teal background, evenly-spaced destinations, and an optional raised center
/// button (scan/FAB). Every child is `Expanded`, so it resizes with any width.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    this.centerButton,
    this.centerGap = 72,
  });

  final List<BottomNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  /// Optional circular button that floats above the bar in the middle.
  final Widget? centerButton;
  final double centerGap;

  static const double barHeight = 62;

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final centerIndex = items.length ~/ 2;

    final slots = <Widget>[];
    final visibleCount = items.length;
    for (var i = 0; i < visibleCount; i++) {
      if (i == centerIndex && centerButton != null) {
        slots.add(SizedBox(width: centerGap));
      }
      slots.add(
        Expanded(
          child: _NavItem(
            item: items[i],
            selected: i == selectedIndex,
            onTap: () => onTap(i),
          ),
        ),
      );
    }

    return Container(
      height: barHeight + bottomInset,
      decoration: const BoxDecoration(
        color: AppColors.navBar,
        border: Border(top: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      child: Padding(
        padding: EdgeInsets.only(bottom: bottomInset > 0 ? 6 : 0),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.topCenter,
          children: [
            Row(crossAxisAlignment: CrossAxisAlignment.center, children: slots),
            if (centerButton != null)
              Positioned(top: -28, child: centerButton!),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final BottomNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.navActive : Colors.white;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          item.customIcon ?? Icon(item.icon, size: 24, color: color),
          const SizedBox(height: 3),
          Text(
            item.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontFamily: 'Inter',
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
