import 'package:fast_timer/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsPage extends StatefulWidget {
  const NotificationSettingsPage({super.key});

  @override
  State<NotificationSettingsPage> createState() =>
      _NotificationSettingsPageState();
}

class _NotificationSettingsPageState extends State<NotificationSettingsPage> {
  bool _notificationEnabled = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSetting();
  }

  Future<void> _loadSetting() async {
    final enabled = await NotificationSettings.getNotificationEnabled();
    setState(() {
      _notificationEnabled = enabled;
      _loading = false;
    });
  }

  Future<void> _toggleNotification(bool value) async {
    setState(() {
      _notificationEnabled = value;
    });
    await NotificationSettings.setNotificationEnabled(value);
    // (선택) 알림이 꺼졌을 때 기존 예약된 알림 취소 등 추가 가능
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('알림 설정')),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                children: [
                  SwitchListTile(
                    title: const Text(
                      '타이머 종료 알림 받기',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    value: _notificationEnabled,
                    onChanged: _toggleNotification,
                    activeColor: AppColor.primaryOrange.of(
                      context,
                    ), // 토글(동그라미) 색
                    activeTrackColor: AppColor.primaryOrange
                        .of(context)
                        .withOpacity(0.5), // 트랙(배경) 색
                  ),

                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      '알림을 끄면 타이머가 종료되어도 알림이 오지 않습니다.',
                      style: TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ),
                ],
              ),
    );
  }
}

class NotificationSettings {
  static const String _key = 'notification_enabled';

  static Future<bool> getNotificationEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? true; // 기본값: 알림 ON
  }

  static Future<void> setNotificationEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, value);
  }
}
