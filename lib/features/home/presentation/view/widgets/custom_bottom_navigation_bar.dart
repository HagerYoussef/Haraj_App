import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/themes/colors.dart';
import '../../../../lang/language_manager.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigationBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      elevation: 15,
      color: theme.bottomAppBarTheme.color, // لون الخلفية حسب الثيم
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Container(
          padding:  EdgeInsets.symmetric(vertical: 10.h, horizontal: 20.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNavItem(
                context,
                icon: Icons.email_sharp,
                label:  AppLocalizations.of(context)!.translate('message'),
                index: 2,
              ),
              _buildNavItem(
                context,
                icon: Icons.favorite,
                label:  AppLocalizations.of(context)!.translate('fav'),
                index: 1,
              ),
              const SizedBox(width: 5),
              _buildNavItem(
                context,
                icon: Icons.home,
                label:  AppLocalizations.of(context)!.translate('haraj'),
                index: 0,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
      BuildContext context, {
        required IconData icon,
        required String label,
        required int index,
      }) {
    final isSelected = index == currentIndex;
    final theme = Theme.of(context);

    Color getIconColor() {
      if (isSelected) {
        return theme.brightness == Brightness.dark
            ? ColorApp.green_color.withOpacity(0.9)
            : ColorApp.green_color;
      }
      return theme.iconTheme.color ?? Colors.grey;
    }

    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: getIconColor(),
          ),
           SizedBox(height: 4.h),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: getIconColor(),
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}