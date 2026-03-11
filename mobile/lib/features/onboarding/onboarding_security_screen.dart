import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../theme/app_theme.dart';
import '../welcome/welcome_screen.dart'; // Pour BogolanPainter
import '../auth/login_screen.dart';

class OnboardingSecurityScreen extends StatelessWidget {
  const OnboardingSecurityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arrière-plan Bogolan
          Positioned.fill(
            child: Opacity(
              opacity: 0.05,
              child: CustomPaint(
                painter: BogolanPainter(),
              ),
            ),
          ),
          
          // Décorations abstraites (Glows)
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGold.withValues(alpha: 0.05),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Barre de navigation supérieure
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Symbols.shield_lock,
                        size: 32,
                        color: AppTheme.primaryGold,
                      ),
                      Text(
                        'SÉCURITÉ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: AppTheme.cream.withValues(alpha: 0.6),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                          );
                        },
                        child: Text(
                          'Passer',
                          style: TextStyle(
                            color: AppTheme.cream.withValues(alpha: 0.8),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Illustration centrale
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Glow
                    Container(
                      width: 250,
                      height: 250,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.primaryGold.withValues(alpha: 0.1),
                      ),
                    ),
                    
                    // Bouclier stylisé
                    Container(
                      width: 180,
                      height: 240,
                      decoration: BoxDecoration(
                        gradient: const RadialGradient(
                          center: Alignment(-0.4, -0.4),
                          radius: 1.2,
                          colors: [
                            Color(0xFFF1D374),
                            Color(0xFFC9A326),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(100),
                        border: Border.all(
                          color: AppTheme.primaryGold.withValues(alpha: 0.5),
                          width: 4,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Icon(
                          Symbols.verified_user,
                          size: 100,
                          color: AppTheme.emeraldDark,
                          weight: 300,
                        ),
                      ),
                    ),
                    
                    // Éléments flottants
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGold.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Symbols.lock, color: AppTheme.primaryGold, size: 20),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: -10,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGold.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.4)),
                        ),
                        child: const Icon(Symbols.key, color: AppTheme.primaryGold, size: 18),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 48),
                
                // Texte
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: const TextSpan(
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.cream,
                            fontFamily: 'Space Grotesk',
                          ),
                          children: [
                            TextSpan(text: 'Votre argent en '),
                            TextSpan(
                              text: 'sécurité',
                              style: TextStyle(color: AppTheme.primaryGold),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Finis les carnets papier. Toutes vos cotisations sont tracées et sécurisées.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          height: 1.5,
                          color: AppTheme.cream.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Footer
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      // Points de pagination
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 32,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.primaryGold,
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryGold.withValues(alpha: 0.5),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.cream.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppTheme.cream.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Bouton Suivant
                      SizedBox(
                        width: double.infinity,
                        height: 60,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const LoginScreen()),
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('SUIVANT'),
                              SizedBox(width: 8),
                              Icon(Symbols.arrow_forward),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
