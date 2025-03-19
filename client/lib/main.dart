import 'package:flutter/material.dart';
import 'package:flutter_fix_warehouse/styles.dart';

import 'pages/home_page.dart';
import 'platform_util.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await PlatformUtil.init();
  runApp(const FixItWarehouseApp());
}

class FixItWarehouseApp extends StatelessWidget {
  const FixItWarehouseApp({super.key});

  @override
  Widget build(BuildContext context) => Builder(
    builder: (context) {
      return MaterialApp(
        title: 'Fix-It Warehouse',
        home: const HomePage(),
        theme: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        ),
        debugShowCheckedModeBanner: false,
      );
    },
  );
}
