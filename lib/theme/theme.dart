import 'package:flutter/material.dart';

final ThemeData lightTheme = ThemeData(
  // 기본 색상 설정
  primaryColor: Color(0xFF007AFF),
  scaffoldBackgroundColor: Color(0xFFF1F1F1), // 부드러운 밝은 배경색

  // 디바이더 색상 설정
  dividerTheme: DividerThemeData(
    color: Colors.grey.withValues(alpha: 0.2),
    thickness: 1,
  ),

  tabBarTheme: TabBarTheme(
    dividerColor: Colors.grey.withValues(alpha: 0.2),
  ),

  // 앱 바 설정
  appBarTheme: AppBarTheme(
    titleTextStyle: TextStyle(color: Color(0xFF333333), fontSize: 18),
    backgroundColor: Colors.white,
    scrolledUnderElevation: 0,
  ),

  // 팝업메뉴 설정
  popupMenuTheme: PopupMenuThemeData(
      color: Colors.white,
      textStyle: TextStyle(color: Color(0xFF333333)),
      labelTextStyle:
          WidgetStateProperty.all(TextStyle(color: Color(0xFF333333)))),

  // 카드 설정
  cardTheme: CardTheme(
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(0),
      ),
      clipBehavior: Clip.none),

  // 바텀시트 설정
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
  ),

  // 플로팅 액션 버튼 설정
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Color(0xFF007AFF), // 파란색 배경
    foregroundColor: Colors.white, // 하얀색 아이콘 및 글씨
  ),

  // 텍스트 관련 설정
  textTheme: TextTheme(
    bodyLarge: TextStyle(
      color: Color(0xFF333333),
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ), // 어두운 회색 텍스트
    bodyMedium: TextStyle(
      color: Color(0xFF333333),
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ), // 어두운 회색 텍스트
    bodySmall: TextStyle(
      color: Color(0xFF555555),
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ), // 조금 더 연한 회색
  ),

  // 아이콘 색상 설정
  iconTheme: IconThemeData(
    color: Color(0xFF333333), // 어두운 회색 아이콘
  ),

  // 아이콘 버튼 설정
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      foregroundColor:
          WidgetStateProperty.all<Color>(Color(0xFF333333)), // 어두운 회색
    ),
  ),

  // 리스트타일 설정
  listTileTheme: ListTileThemeData(
    iconColor: Color(0xFF333333),
    textColor: Color(0xFF333333),
  ),
);

final ThemeData darkTheme = ThemeData(
  primaryColor: Color(0xFF7CA7D5),
  scaffoldBackgroundColor: Color(0xFF121212), // 다크 배경

  // 디바이더 색상 설정
  dividerTheme: DividerThemeData(
    color: const Color.fromARGB(255, 36, 36, 36).withValues(alpha: 0.1),
    thickness: 1,
  ),

  tabBarTheme: TabBarTheme(
    dividerColor: Colors.grey.withValues(alpha: 0.2),
  ),

  // 앱 바 설정
  appBarTheme: AppBarTheme(
    titleTextStyle: TextStyle(color: Colors.white, fontSize: 18),
    backgroundColor: Color(0xFF1E1E1E),
    scrolledUnderElevation: 0,
  ),

// 팝업메뉴 설정
  popupMenuTheme: PopupMenuThemeData(
      color: Color(0xFF1E1E1E),
      textStyle: TextStyle(color: Colors.white),
      labelTextStyle: WidgetStateProperty.all(TextStyle(color: Colors.white))),

  // 카드 설정
  cardTheme: CardTheme(
    color: Color(0xFF1E1E1E),
  ),

  // 바텀시트 설정
  bottomSheetTheme: BottomSheetThemeData(
    backgroundColor: Color(0xFF1E1E1E),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(
        top: Radius.circular(20),
      ),
    ),
  ),

  // 플로팅 액션 버튼 설정
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.white, // 파란색 배경
    foregroundColor: Color(0xFF7CA7D5), // 하얀색 아이콘 및 글씨
  ),

  bottomNavigationBarTheme: BottomNavigationBarThemeData(),
  // 텍스트 관련 설정
  textTheme: TextTheme(
    bodyLarge: TextStyle(
      color: Color(0xFFDDDDDD),
      fontSize: 16,
      fontWeight: FontWeight.bold,
    ), // 어두운 회색 텍스트
    bodyMedium: TextStyle(
      color: Color(0xFFDDDDDD),
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ), // 어두운 회색 텍스트
    bodySmall: TextStyle(
      color: Color(0xFFBBBBBB),
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ), // 조금 더 연한 회색
  ),

  // 아이콘 색상 설정
  iconTheme: IconThemeData(
    color: Color(0xFFDDDDDD), // 부드러운 흰색 아이콘
  ),

  // 아이콘 버튼 설정
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      foregroundColor:
          WidgetStateProperty.all<Color>(Color(0xFFDDDDDD)), // 부드러운 흰색
    ),
  ),

  // 리스트타일 설정
  listTileTheme: ListTileThemeData(
    iconColor: Color(0xFFDDDDDD),
    textColor: Color(0xFFDDDDDD),
  ),
);
