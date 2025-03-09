import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:math' as math;
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:untitled22/features/home/presentation/view/home_view.dart';

import '../../../../../core/themes/colors.dart';
import '../../../../../core/themes/theme_provider.dart';
import '../../../../auth/presentation/view/login_view.dart';
import '../../../../auth/presentation/view/register_view.dart';
import '../../../../lang/laguage_cubit.dart';
import '../../../../lang/language_manager.dart';
import '../../../../profile/profilepage.dart';

class CustomMenu extends StatefulWidget {
  final bool isMenuOpen;

  const CustomMenu({
    Key? key,
    required this.isMenuOpen,
  }) : super(key: key);

  @override
  State<CustomMenu> createState() => _CustomMenuState();
}

class _CustomMenuState extends State<CustomMenu> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentLanguage = context.watch<LanguageCubit>().state.languageCode;

    return BlocProvider(
        create: (context) => ProfileCubit()..fetchProfile(),
        child:
            BlocBuilder<ProfileCubit, ProfileState>(builder: (context, state) {
          String userName = 'User'; // Default value

          if (state is ProfileLoaded) {
            userName = state.profileData['name'] ?? 'User';
          }

          return Directionality(
            textDirection:
                currentLanguage == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            child: AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: Directionality.of(context) ==
                      TextDirection.ltr // تحديد الجانب بناءً على الاتجاه
                  ? (widget.isMenuOpen ? 0 : -290)
                  : null,
              right: Directionality.of(context) == TextDirection.rtl
                  ? (widget.isMenuOpen ? 0 : -290)
                  : null,
              top: 0,
              bottom: 0,
              child: Material(
                color: themeProvider.isDarkMode
                    ? ColorApp.dark_color
                    : ColorApp.white_color,
                child: Row(
                    mainAxisAlignment:
                        Directionality.of(context) == TextDirection.rtl
                            ? MainAxisAlignment.start
                            : MainAxisAlignment.end, // محاذاة الصف حسب الاتجاه
                    children: [
                      Container(
                        width: 290,
                        color: themeProvider.isDarkMode
                            ? const Color(0xFF1A1A1A)
                            : ColorApp.white_color,
                        child: Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 20.w, vertical: 10),
                              child: BlocBuilder<ProfileCubit, ProfileState>(
                                builder: (context, state) {
                                  String userName = 'User'; // القيمة الافتراضية
                                  String initial = 'U'; // الحرف الافتراضي

                                  if (state is ProfileLoaded) {
                                    userName =
                                        state.profileData['name'] ?? 'User';
                                    initial = userName.isNotEmpty
                                        ? userName[0].toUpperCase()
                                        : 'U';
                                  }

                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    ProfilePage()),
                                          );
                                        },
                                        child: CircleAvatar(
                                          backgroundColor: ColorApp.green_color,
                                          // لون الخلفية
                                          radius: 20,
                                          // حجم الدائرة
                                          child: Text(
                                            initial,
                                            style: TextStyle(
                                              fontSize: 24,
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        'Welcome $userName',
                                        style: TextStyle(
                                          fontSize: 20,
                                          color: ColorApp.green_color,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ),
                            _buildMenuItem(
                              title: AppLocalizations.of(context)!
                                  .translate('login'),
                              icon: Icons.login,
                              onTap: () =>
                                  _showBottomSheet(context, LoginView()),
                              themeProvider: themeProvider,
                            ),
                            _buildMenuItem(
                              title: AppLocalizations.of(context)!
                                  .translate('register'),
                              icon: Icons.person_add,
                              onTap: () => _showBottomSheet(
                                  context, const RegisterView()),
                              themeProvider: themeProvider,
                            ),
                            _buildMenuItem(
                              title: AppLocalizations.of(context)!
                                  .translate('policy'),
                              icon: Icons.privacy_tip,
                              onTap: () {},
                              themeProvider: themeProvider,
                            ),
                            _buildMenuItem(
                              title: AppLocalizations.of(context)!
                                  .translate('logout'),
                              icon: Icons.logout,
                              onTap: () => _showLogoutDialog(context),
                              themeProvider: themeProvider,
                            ),
                            _buildMenuItem(
                              title: AppLocalizations.of(context)!
                                  .translate('lang'),
                              icon: Icons.language,
                              onTap: () => _showLanguageBottomSheet(context),
                              themeProvider: themeProvider,
                            ),
                            _buildDarkModeToggle(themeProvider),
                          ],
                        ),
                      ),
                    ]),
              ),
            ),
          );
        }));
  }

  Widget _buildMenuItem({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
    required ThemeProvider themeProvider,
  }) {
    final bool isRTL = Directionality.of(context) == TextDirection.rtl;

    return ListTile(
      // الأيقونة الرئيسية (تظهر قبل النص دائمًا)
      leading: Icon(
        icon,
        color: themeProvider.isDarkMode ? Colors.white : ColorApp.green_color,
      ),

      // السهم (يظهر في الطرف المعاكس للاتجاه)
      trailing: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(isRTL ? math.pi : 0), // اعكس السهم في RTL
        child: Icon(
          Icons.arrow_forward_ios,
          color: themeProvider.isDarkMode ? Colors.white : ColorApp.green_color,
        ),
      ),

      title: Align(
        alignment: isRTL ? Alignment.topRight : Alignment.topLeft,
        child: Text(
          title,
          style: TextStyle(
            color:
                themeProvider.isDarkMode ? Colors.white : ColorApp.green_color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      onTap: onTap,
    );
  }

  Widget _buildDarkModeToggle(ThemeProvider themeProvider) {
    final bool isRTL = Directionality.of(context) == TextDirection.rtl;

    return ListTile(
      // السويتش يظهر في النهاية دائمًا (trailing)
      trailing: Switch(
        value: themeProvider.isDarkMode,
        onChanged: (value) => themeProvider.toggleTheme(value),
        activeColor: ColorApp.green_color,
        inactiveThumbColor: Colors.grey,
      ),

      // النص يتم محاذاته حسب الاتجاه
      title: Align(
        alignment: isRTL ? Alignment.centerRight : Alignment.centerLeft,
        child: Text(
          AppLocalizations.of(context)!.translate('dark_mode'),
          style: TextStyle(
            color:
                themeProvider.isDarkMode ? Colors.white : ColorApp.green_color,
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _showLanguageBottomSheet(BuildContext context) {
    final currentLanguage = context.read<LanguageCubit>().state.languageCode;
    final bool isRTL = currentLanguage == 'ar';

    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.translate('choose_language'),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                if (isRTL) ...[
                  _buildLanguageTile('ar', 'العربية', Colors.blue),
                  _buildLanguageTile('en', 'English', Colors.green),
                ] else ...[
                  _buildLanguageTile('en', 'English', Colors.green),
                  _buildLanguageTile('ar', 'العربية', Colors.blue),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLanguageTile(String code, String name, Color color) {
    return ListTile(
      leading: Icon(Icons.language, color: color),
      title: Text(name),
      onTap: () {
        context.read<LanguageCubit>().changeLanguage(code);
        Navigator.pop(context);
      },
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final response = await http.post(
      Uri.parse('https://harajalmamlaka.com/api/logout'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      print('قبل الحذف: token = $token');

      // حذف التوكن بعد تسجيل الخروج
      await prefs.remove('token');

      // تأكيد الحذف
      final checkToken = prefs.getString('token');
      print('بعد الحذف: token = $checkToken'); // يجب أن يكون null

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Logout success!'),
          backgroundColor: ColorApp.green_color,
        ),
      );

      // توجيه المستخدم إلى شاشة تسجيل الدخول ومنع الرجوع للخلف
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => LoginView()), // شاشة تسجيل الدخول
            (route) => false, // إزالة كل الشاشات السابقة من الذاكرة
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Logout failed!')),
      );
    }
  }

  void _showBottomSheet(BuildContext context, Widget child) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16.0,
            right: 16.0,
            top: 16.0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 16.0,
          ),
          child: child,
        );
      },
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Align(
          alignment: Alignment.topRight,
          child: Text(
            'تأكيد الخروج',
            style: TextStyle(
              color: ColorApp.green_color,
              fontSize: 24,
            ),
          ),
        ),
        actions: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              TextButton(
                child: Text(
                  AppLocalizations.of(context)!.translate('logout'),
                  style: TextStyle(
                    color: ColorApp.green_color,
                    fontSize: 15,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // ✅ إغلاق الـ Dialog أولًا
                  _logout(context); // ✅ ثم تنفيذ تسجيل الخروج
                },
              ),
              TextButton(
                child: Text(
                  AppLocalizations.of(context)!.translate('cancel'),
                  style: TextStyle(
                    color: ColorApp.green_color,
                    fontSize: 15,
                  ),
                ),
                onPressed: () => Navigator.of(context).pop(), // ✅ إغلاق الـ Dialog فقط
              ),
            ],
          ),
        ],
      ),
    );
  }

}
