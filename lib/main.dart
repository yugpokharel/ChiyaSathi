import 'package:chiya_sathi/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final appDir = await getApplicationDocumentsDirectory();
  Hive.init(appDir.path);
  
  // Open the auth box
  await Hive.openBox('authBox');
  
  runApp(
    const ProviderScope( 
      child: MyApp(),
    ),
  );
}
