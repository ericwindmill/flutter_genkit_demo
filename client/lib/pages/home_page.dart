import 'package:flutter/material.dart';
import 'package:flutter_fix_warehouse/pages/wizard_page.dart';
import 'package:flutter_fix_warehouse/views/app_navigation_bar.dart';
import 'package:google_fonts/google_fonts.dart';

import '../views/gt_button.dart';
import '../views/sparkle_leaf.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: Color(0xff4CAF50),
      toolbarHeight: 64,
      title: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Text(
                  'Fix-It Warehouse',
                  style: GoogleFonts.jua(
                    fontSize: 32,
                    fontWeight: FontWeight.normal,
                    letterSpacing: 0,
                    foreground:
                        Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 1
                          ..color = Colors.white,
                  ),
                ),
                const Spacer(),
                Icon(Icons.search, color: Colors.white),
                SizedBox(width: 16),
                Icon(Icons.shopping_cart, color: Colors.white),
              ],
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(32),
        child: Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child: Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 20),
              const SizedBox(width: 4),
              Text(
                'Valley Stream - 10pm',
                style: GoogleFonts.notoSans(color: Colors.white, fontSize: 12),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(
                    Icons.local_shipping,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '11581',
                    style: GoogleFonts.notoSans(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              'Home / DIY Projects & Ideas / Outdoor Living',
              style: GoogleFonts.notoSans(
                color: Color(0xFF666666),
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            'Garden Ideas & Projects',
            style: GoogleFonts.notoSans(
              color: Colors.black,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Image.asset(
                    'assets/woman-gardening.png',
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Looking for gardening help?',
                  style: GoogleFonts.notoSans(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                GtButton(
                  backgroundColor: const Color(0xFF2E7D32),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WizardPage(),
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
                      const SizedBox(width: 8),
                      Text(
                        'Try GreenThumb',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.2,
                          color: Colors.white,
                        ),
                      ),
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
