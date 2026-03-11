import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../theme/app_theme.dart';

class PaymentReceiptScreen extends StatelessWidget {
  const PaymentReceiptScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Symbols.arrow_back, color: AppTheme.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text('Reçu de paiement', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Symbols.more_vert, color: AppTheme.textDark),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Ticket Receipt Card
              _buildTicketCard(),
              
              const SizedBox(height: 32),
              
              // Action Buttons
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Symbols.download),
                  label: const Text('TÉLÉCHARGER PDF', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  onPressed: () {},
                  icon: const Icon(Symbols.share),
                  label: const Text('PARTAGER', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.textDark,
                    side: const BorderSide(color: AppTheme.primaryGold, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              const Text(
                'Ce document sert de preuve de paiement pour votre cotisation. Conservez-le précieusement ou exportez-le en PDF pour vos archives.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppTheme.grayText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTicketCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
        border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: AppTheme.primaryGold.withValues(alpha: 0.1), shape: BoxShape.circle),
                  child: const Icon(Symbols.account_balance_wallet, color: AppTheme.primaryGold, size: 32),
                ),
                const SizedBox(height: 16),
                const Text('REÇU DE COTISATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2, color: AppTheme.primaryGold)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.green.withValues(alpha: 0.2))),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Symbols.check_circle, color: Colors.green, size: 14),
                      SizedBox(width: 8),
                      Text('PAYÉ ✓', style: TextStyle(color: Colors.green, fontSize: 12, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Amount
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 24),
            color: AppTheme.primaryGold.withValues(alpha: 0.05),
            child: const Column(
              children: [
                Text('Montant versé', style: TextStyle(fontSize: 12, color: AppTheme.grayText, fontWeight: FontWeight.w500)),
                SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('25,000', style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                    SizedBox(width: 8),
                    Text('FCFA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: AppTheme.textDark)),
                  ],
                ),
              ],
            ),
          ),
          
          // Details
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildRow('Contributeur', 'Jean Dupont'),
                _buildRow('Groupe', 'Tontine Paris Sud'),
                _buildRow('Date & Heure', '12 Oct 2023, 14:30'),
                _buildRow('Moyen de paiement', 'Mobile Money'),
                _buildRow('ID Transaction', 'TXN-987654321', isMono: true),
                _buildRow('Référence', 'REF-ABC-XYZ'),
              ],
            ),
          ),
          
          // Dashed Line with Ticket Effect
          Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(double.infinity, 1),
                painter: DashedLinePainter(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(height: 20, width: 10, decoration: const BoxDecoration(color: AppTheme.creamLight, borderRadius: BorderRadius.horizontal(right: Radius.circular(10)))),
                  Container(height: 20, width: 10, decoration: const BoxDecoration(color: AppTheme.creamLight, borderRadius: BorderRadius.horizontal(left: Radius.circular(10)))),
                ],
              ),
            ],
          ),
          
          // QR Code
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade100)),
                  child: Image.network('https://api.qrserver.com/v1/create-qr-code/?size=100x100&data=TXN-987654321', width: 100, height: 100),
                ),
                const SizedBox(height: 16),
                const Text('DOCUMENT OFFICIEL • WWW.TONTINEAPP.COM', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, letterSpacing: 1, color: AppTheme.grayText)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRow(String label, String value, {bool isMono = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.grayText)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isMono ? AppTheme.primaryGold : AppTheme.textDark,
              fontFamily: isMono ? 'monospace' : null,
            ),
          ),
        ],
      ),
    );
  }
}

class DashedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade200
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const double dashWidth = 5;
    const double dashSpace = 5;
    double startX = 0;
    while (startX < 400) { // Large arbitrary value to cover width
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), paint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
