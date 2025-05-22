import 'package:fast_timer/data/repository/sql_database.dart';
import 'package:fast_timer/theme/colors.dart';
import 'package:fast_timer/theme/theme.dart';
import 'package:fast_timer/ui/pages/timer_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SQFLite DB 초기화 (앱 실행 시 최초 1회)
  await SqlDatabase.instance.database;

  // 시스템 UI 세팅
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: const Locale('ko', 'KR'),
      supportedLocales: const [Locale('ko', 'KR')],
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      title: '빠른 타이머',
      theme: lightTheme.copyWith(extensions: [AppColors.lightColorScheme]),
      darkTheme: darkTheme.copyWith(
        extensions: [AppColors.darkColorScheme],
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: TimerListPage(), // 또는 TimerListPage()로 대체 가능
    );
  }
}
