import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../navigation/navigation_bloc.dart';
import '../navigation/navigation_event.dart';
import '../navigation/navigation_state.dart';
import '../theme/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardSurface = AppTheme.getCardSurface(context);
    final borderColor = AppTheme.getBorderColor(context);
    final activeColor = AppTheme.getGainColor(context);
    final mutedColor = AppTheme.getTextMuted(context);

    return BlocBuilder<NavigationBloc, NavigationState>(
      builder: (context, navState) {
        return Container(
          decoration: BoxDecoration(
            color: cardSurface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, -4),
              ),
            ],
            border: Border(
              top: BorderSide(color: borderColor, width: 0.8),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    context: context,
                    index: 0,
                    currentIndex: navState.currentIndex,
                    label: 'Explore',
                    outlinedIcon: Icons.explore_outlined,
                    activeIcon: Icons.explore,
                    activeColor: activeColor,
                    mutedColor: mutedColor,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 1,
                    currentIndex: navState.currentIndex,
                    label: 'Watchlist',
                    outlinedIcon: Icons.bookmark_outline,
                    activeIcon: Icons.bookmark,
                    activeColor: activeColor,
                    mutedColor: mutedColor,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 2,
                    currentIndex: navState.currentIndex,
                    label: 'Holdings',
                    outlinedIcon: Icons.pie_chart_outline,
                    activeIcon: Icons.pie_chart,
                    activeColor: activeColor,
                    mutedColor: mutedColor,
                  ),
                  _buildNavItem(
                    context: context,
                    index: 3,
                    currentIndex: navState.currentIndex,
                    label: 'Orders',
                    outlinedIcon: Icons.receipt_long_outlined,
                    activeIcon: Icons.receipt_long,
                    activeColor: activeColor,
                    mutedColor: mutedColor,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required int currentIndex,
    required String label,
    required IconData outlinedIcon,
    required IconData activeIcon,
    required Color activeColor,
    required Color mutedColor,
  }) {
    final bool isSelected = index == currentIndex;

    return GestureDetector(
      onTap: () {
        context.read<NavigationBloc>().add(SelectTabEvent(index));
      },
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.15) : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              alignment: Alignment.topRight,
              children: [
                Icon(
                  isSelected ? activeIcon : outlinedIcon,
                  color: isSelected ? activeColor : mutedColor,
                  size: 24,
                ),
                if (isSelected)
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: activeColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                color: isSelected ? activeColor : mutedColor,
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                letterSpacing: 0.2,
              ),
              child: Text(label),
            ),
          ],
        ),
      ),
    );
  }
}
