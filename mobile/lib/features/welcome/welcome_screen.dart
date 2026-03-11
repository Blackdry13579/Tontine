import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../theme/app_theme.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Arrière-plan avec motif (simulation bogolan simplifiée)
          Positioned.fill(
            child: Opacity(
              opacity: 0.08,
              child: CustomPaint(painter: BogolanPainter()),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 40.0,
              ),
              child: Column(
                children: [
                  const Spacer(),

                  // Logo Central
                  Column(
                    children: [
                      // Pièce d'or
                      Container(
                        width: 160,
                        height: 160,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: AppTheme.goldGradient,
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryGold.withValues(alpha: 0.3),
                              blurRadius: 50,
                              spreadRadius: 5,
                            ),
                          ],
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                            width: 2,
                          ),
                        ),
                        child: Container(
                          margin: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppTheme.emeraldDark.withValues(alpha: 0.2),
                              width: 1.5,
                            ),
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const Icon(
                                Symbols.monetization_on,
                                size: 80,
                                color: AppTheme.emeraldDark,
                                weight: 300,
                              ),
                              Positioned(
                                bottom: 10,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppTheme.emeraldDark,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: AppTheme.primaryGold.withValues(
                                        alpha: 0.4,
                                      ),
                                    ),
                                  ),
                                  child: const Text(
                                    'PRESTIGE',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 3,
                                      color: AppTheme.primaryGold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Nom de la marque avec Gradient
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppTheme.goldGradient.createShader(bounds),
                        child: const Text(
                          'AURUM',
                          style: TextStyle(
                            fontSize: 56,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -2,
                            color: Colors.white, // Nécessaire pour ShaderMask
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Slogan
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 1,
                            width: 32,
                            color: AppTheme.primaryGold.withValues(alpha: 0.4),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12.0),
                            child: Text(
                              'VOTRE ÉPARGNE, VOTRE COMMUNAUTÉ',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w300,
                                letterSpacing: 2,
                                color: AppTheme.cream,
                              ),
                            ),
                          ),
                          Container(
                            height: 1,
                            width: 32,
                            color: AppTheme.primaryGold.withValues(alpha: 0.4),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const Spacer(),

                  // Boutons d'action
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppTheme.goldGradient,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const RegisterScreen(),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text('CRÉER UN COMPTE'),
                                SizedBox(width: 8),
                                Icon(Symbols.chevron_right),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: OutlinedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LoginScreen(),
                              ),
                            );
                          },
                          child: const Text("J'AI DÉJÀ UN COMPTE"),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Sélecteur de langue (visuel)
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Symbols.public, size: 16, color: AppTheme.cream),
                          SizedBox(width: 8),
                          Text(
                            "FRANÇAIS | AFRIQUE DE L'OUEST",
                            style: TextStyle(
                              fontSize: 10,
                              letterSpacing: 1.5,
                              color: AppTheme.cream,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Dessinateur pour le motif Bogolan
class BogolanPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    const double step = 60;
    for (double x = 0; x < size.width; x += step) {
      for (double y = 0; y < size.height; y += step) {
        final path = Path();
        path.moveTo(x + step / 2, y);
        path.lineTo(x + step, y + step / 2);
        path.lineTo(x + step / 2, y + step);
        path.lineTo(x, y + step / 2);
        path.close();

        // Losange intérieur
        path.moveTo(x + step / 2, y + 10);
        path.lineTo(x + step - 10, y + step / 2);
        path.lineTo(x + step / 2, y + step - 10);
        path.lineTo(x + 10, y + step / 2);
        path.close();

        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
