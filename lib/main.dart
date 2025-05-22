import 'package:fast_timer/theme/colors.dart';
import 'package:fast_timer/theme/theme.dart';
import 'package:fast_timer/ui/pages/home/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: Colors.transparent, 
    systemNavigationBarIconBrightness: Brightness.dark,
  ));

  // SQL 사용을 위한 세팅
  WidgetsFlutterBinding.ensureInitialized();
  // SqlDatabase();
  runApp(ProviderScope(child: const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode;
    return MaterialApp(
      locale: Locale('ko', 'KR'), 
      supportedLocales: [
        Locale('ko', 'KR'),
      ],
      localizationsDelegates: [
        // GlobalMaterialLocalizations.delegate,
        // GlobalWidgetsLocalizations.delegate,
        // GlobalCupertinoLocalizations.delegate,
      ],
      title: '빠른 타이머',
      theme: lightTheme.copyWith(
        extensions: [AppColors.lightColorScheme],
      ), 
      // darkTheme: darkTheme.copyWith(
      //   extensions: [AppColors.darkColorScheme],
      // ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

