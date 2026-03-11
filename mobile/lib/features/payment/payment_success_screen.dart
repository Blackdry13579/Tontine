import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../theme/app_theme.dart';
import '../home/home_screen.dart';
import 'payment_receipt_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final String tontineName;
  final String amount;

  const PaymentSuccessScreen({
    super.key,
    required this.tontineName,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        body: Stack(
          children: [
            // Decorative Background Pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: CustomPaint(
                  painter: SuccessPatternPainter(),
                ),
              ),
            ),
            
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Column(
                  children: [
                    const Spacer(),
                    
                    // Success Icon Section
                    Center(
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 160,
                            height: 160,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryGold.withValues(alpha: 0.1),
                            ),
                          ),
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.primaryGold,
                              border: Border.all(color: Colors.white, width: 4),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryGold.withValues(alpha: 0.4),
                                  blurRadius: 30,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: const Icon(Symbols.check, color: Colors.white, size: 64, weight: 700),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Success Message
                    const Text(
                      'PAIEMENT CONFIRMÉ !',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textDark, letterSpacing: 1),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Votre transaction a été traitée avec succès.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: AppTheme.grayText),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Transaction Details Card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.6),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'MONTANT TOTAL',
                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2, color: AppTheme.primaryGold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            amount,
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                          ),
                          const SizedBox(height: 24),
                          _buildDetailRow('Date', '14 Octobre 2024, 14:30'),
                          _buildDetailRow('Tontine', tontineName),
                          _buildDetailRow('ID Transaction', '#TXN-8829-AFR', isId: true),
                          _buildDetailRow('Statut', 'Complété', isStatus: true),
                        ],
                      ),
                    ),
                    
                    const Spacer(),
                    
                    // Action Buttons
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const PaymentReceiptScreen()),
                          );
                        },
                        icon: const Icon(Symbols.download),
                        label: const Text('TÉLÉCHARGER REÇU'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryGold,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const HomeScreen()),
                            (route) => false,
                          );
                        },
                        icon: const Icon(Symbols.home),
                        label: const Text('RETOUR À L\'ACCUEIL'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.textDark,
                          side: BorderSide(color: AppTheme.primaryGold.withValues(alpha: 0.3), width: 2),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isId = false, bool isStatus = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.grayText, fontWeight: FontWeight.w500)),
          if (isStatus)
            Row(
              children: [
                Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.green)),
              ],
            )
          else
            Text(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isId ? AppTheme.primaryGold : AppTheme.textDark,
                fontFamily: isId ? 'monospace' : null,
              ),
            ),
        ],
      ),
    );
  }
}

class SuccessPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryGold
      ..strokeWidth = 1;

    const double spacing = 24;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
