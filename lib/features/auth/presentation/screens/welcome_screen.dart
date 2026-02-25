import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/constants/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      body: Stack(children: [
        Positioned(top: -100, right: -100,
          child: Container(width: 350, height: 350,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(.06)))),
        Positioned(bottom: 150, left: -80,
          child: Container(width: 220, height: 220,
            decoration: BoxDecoration(shape: BoxShape.circle,
              color: AppColors.primary.withOpacity(.04)))),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(children: [
              const Spacer(flex: 2),
              RichText(text: TextSpan(children: [
                TextSpan(text: 'M', style: GoogleFonts.syne(
                  fontSize: 80, fontWeight: FontWeight.w800, color: AppColors.primary)),
                TextSpan(text: 'ina', style: GoogleFonts.syne(
                  fontSize: 80, fontWeight: FontWeight.w800, color: AppColors.white)),
              ])),
              const SizedBox(height: 12),
              Text('Réseau professionnel par cellules',
                style: GoogleFonts.syne(
                  fontSize: 14, fontWeight: FontWeight.w500,
                  color: AppColors.greyMuted, letterSpacing: .3)),
              const Spacer(flex: 3),
              ElevatedButton(
                onPressed: () => context.go('/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  minimumSize: const Size(double.infinity, 54),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: Text('Créer un compte',
                  style: GoogleFonts.syne(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/login'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.white,
                  minimumSize: const Size(double.infinity, 54),
                  side: BorderSide(color: AppColors.white.withOpacity(.2)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: Text('Se connecter',
                  style: GoogleFonts.syne(fontWeight: FontWeight.w700, fontSize: 15)),
              ),
              const SizedBox(height: 40),
            ]),
          ),
        ),
      ]),
    );
  }
}