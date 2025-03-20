import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fix_warehouse/pages/home_page.dart';
import 'package:flutter_fix_warehouse/styles.dart';

import 'firebase_options.dart';
import 'platform_util.dart';

String? identityToken;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PlatformUtil.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FixItWarehouseApp());
}

class FixItWarehouseApp extends StatelessWidget {
  const FixItWarehouseApp({super.key});

  @override
  Widget build(BuildContext context) => Builder(
    builder: (context) {
      return MaterialApp(
        title: 'Fix-It Warehouse',
        home: HomePage(),
        theme: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        ),
        debugShowCheckedModeBanner: false,
      );
    },
  );
}
