import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fix_warehouse/styles.dart';
import 'package:flutter_fix_warehouse/widgets/gt_button.dart';

import 'firebase_options.dart';
import 'pages/home_page.dart';
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
        home: AuthGuard(),
        theme: Theme.of(context).copyWith(
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        ),
        debugShowCheckedModeBanner: false,
      );
    },
  );
}

class AuthGuard extends StatefulWidget {
  const AuthGuard({super.key});

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return HomePage();
        }

        return Scaffold(
          body: Column(
            children: [
              GtButton(
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signInWithEmailAndPassword(
                      email: 'ewindmill@google.com',
                      password: 'cloud_next_2025',
                    );
                  } on FirebaseAuthException catch (e) {
                    if (e.code == 'user-not-found') {
                      print('No user found for that email.');
                    } else if (e.code == 'wrong-password') {
                      print('Wrong password provided for that user.');
                    } else {
                      print(e);
                    }
                  } on Exception catch (e) {
                    print(e);
                  }
                },
                child: Text("Sign in"),
              ),
            ],
          ),
        );
      },
    );
  }
}
