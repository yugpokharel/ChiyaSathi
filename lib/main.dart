import 'package:chiya_sathi/app/app.dart';
import 'package:chiya_sathi/core/services/notification_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);
  
  await Hive.openBox('authBox');

  // Initialize notifications
  await NotificationService().init();
  
  runApp(
    const ProviderScope( 
      child: MyApp(),
    ),
  );
}
