import 'package:flutter/material.dart';
import 'package:untitled22/features/home/presentation/view/widgets/search_bar.dart';

import '../../../../../core/themes/colors.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onMenuPressed;
  final bool isMenuOpen;

  const CustomAppBar({
    Key? key,
    required this.onMenuPressed,
    required this.isMenuOpen,
    required Color backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ColorApp.green_color,
      elevation: 0,
      actions: [Padding(
        padding: const EdgeInsets.only(right: 15,left: 15),
        child: Icon(Icons.grid_view_outlined, color: ColorApp.white_color),
      )],
      leading: IconButton(
        icon: Padding(
          padding: const EdgeInsets.only(right: 8,left: 8),
          child: Icon(Icons.menu, color: ColorApp.white_color),
        ),
        onPressed: onMenuPressed,
      ),
      title: SearchAppBar(),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}
