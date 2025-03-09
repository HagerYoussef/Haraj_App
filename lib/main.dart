import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'core/themes/theme_provider.dart';
import 'features/details/presentation/view/details_view.dart';
import 'features/home/presentation/view/home_view.dart';
import 'features/lang/laguage_cubit.dart';
import 'features/lang/language_manager.dart';
import 'features/splash/presentation/view/splash_view.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // تحميل المتغيرات من .env


  // تهيئة Firebase
  try {
    await Firebase.initializeApp();
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }


  // تحميل إعدادات الوضع الليلي من SharedPreferences
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  print('isDarkMode: $isDarkMode');

  // تهيئة Pusher

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ThemeProvider()..initialize(isDarkMode),
        ),
        BlocProvider(create: (_) => LanguageCubit()),
        BlocProvider(create: (_) => ConnectivityCubit()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        supportedLocales: [
          Locale('en', ''),
          Locale('ar', ''),
        ],
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: InternetCheckWrapper(),
      ),
    ),
  );
}


enum ConnectivityStatus { connected, disconnected }

class ConnectivityCubit extends Cubit<ConnectivityStatus> {
  final Connectivity _connectivity = Connectivity();
  final InternetConnectionChecker _internetChecker =
  InternetConnectionChecker.createInstance();

  ConnectivityCubit() : super(ConnectivityStatus.connected) {
    _monitorConnectivity();
  }

  void _monitorConnectivity() {
    _connectivity.onConnectivityChanged.listen((result) async {
      bool hasInternet = await _internetChecker.hasConnection;
      if (hasInternet) {
        emit(ConnectivityStatus.connected);
      } else {
        emit(ConnectivityStatus.disconnected);
      }
    });
  }
}

class InternetCheckWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectivityCubit, ConnectivityStatus>(
      builder: (context, state) {
        if (state == ConnectivityStatus.disconnected) {
          return _NoInternetScreen();
        }
        return MyApp(); // Main app if connected
      },
    );
  }
}

class _NoInternetScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            const Text('No Internet Connection', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              child: const Text('Retry'),
              onPressed: () {
                  },
            ),
          ],
        ),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return BlocBuilder<LanguageCubit, Locale>(
      builder: (context, locale) {
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              locale: context.watch<LanguageCubit>().state,
              supportedLocales: const [
                Locale('en'),
                Locale('ar'),
              ],
              localizationsDelegates: const [
                AppLocalizations.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              theme: ThemeData(
                textTheme: TextTheme(
                  bodyLarge: TextStyle(fontFamily: 'Tajawal'),
                ),
                brightness: themeProvider.isDarkMode
                    ? Brightness.dark
                    : Brightness.light,
              ),

              routes: {
                SplashView.routeName: (_) => const SplashView(),
                HomeView.routeName: (_) => HomeView(),
                ProductDetailsPage.routeName: (ctx) =>
                    ProductDetailsPage(productId: 0,),
              },
              initialRoute: SplashView.routeName,
            );
          },
        );
      },
    );
  }
}
