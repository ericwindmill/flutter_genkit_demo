import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../styles.dart';
import '../widgets/app_navigation_bar.dart';
import '../widgets/gt_button.dart';
import '../widgets/sparkle_leaf.dart';
import 'wizard_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.appBackground,
    appBar: AppBar(
      backgroundColor: AppColors.primary,
      toolbarHeight: AppLayout.appBarHeight,
      title: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text('Fix-It Warehouse', style: AppTextStyles.title),
                const Spacer(),
                Icon(Icons.search, color: AppColors.appBackground),
                SizedBox(width: AppLayout.defaultPadding),
                IconButton(
                  icon: Icon(Icons.shopping_cart),
                  color: AppColors.appBackground,
                  onPressed: () {
                    FirebaseAuth.instance.signOut();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(32),
        child: Padding(
          padding: const EdgeInsets.only(
            left: AppLayout.defaultPadding,
            right: AppLayout.defaultPadding,
            bottom: 8,
          ),
          child: Row(
            children: [
              Icon(
                Icons.location_on,
                color: AppColors.appBackground,
                size: AppLayout.smallIconSize,
              ),
              SizedBox(width: 4),
              Text('Valley Stream - 10pm', style: AppTextStyles.subtitle),
              const Spacer(),
              Row(
                children: [
                  Icon(
                    Icons.local_shipping,
                    color: AppColors.appBackground,
                    size: AppLayout.smallIconSize,
                  ),
                  SizedBox(width: 4),
                  Text('11581', style: AppTextStyles.subtitle),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppLayout.defaultPadding,
            vertical: 8,
          ),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              'Home / DIY Projects & Ideas / Outdoor Living',
              style: AppTextStyles.breadcrumb,
            ),
          ),
        ),
        SizedBox(height: AppLayout.defaultPadding),
        Center(
          child: Text('Garden Ideas & Projects', style: AppTextStyles.heading),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: AppLayout.defaultPadding,
                  ),
                  child: Image.asset(
                    'assets/woman-gardening.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(height: AppLayout.defaultPadding),
                Text(
                  'Looking for gardening help?',
                  style: AppTextStyles.subheading,
                ),
                SizedBox(height: AppLayout.largePadding),
                GtButton(
                  style: GtButtonStyle.elevated,
                  onPressed: () async {
                    final identityToken =
                        await FirebaseAuth.instance.currentUser!.getIdToken();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) =>
                                WizardPage(identityToken: identityToken!),
                      ),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SparkleLeaf(
                        size: 24,
                        leafSize: 20,
                        sparkleSize: 10,
                      ),
                      SizedBox(width: 8),
                      Text('Try GreenThumb', style: AppTextStyles.button),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const AppNavigationBar(),
      ],
    ),
  );
}
