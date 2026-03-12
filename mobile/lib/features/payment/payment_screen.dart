import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../core/providers/transaction_provider.dart';
import '../../core/providers/auth_provider.dart';
import 'payment_success_screen.dart';

class PaymentScreen extends StatefulWidget {
  final String tontineName;
  final String amount;
  final String cycleId;
  
  const PaymentScreen({
    super.key, 
    required this.tontineName, 
    required this.amount,
    required this.cycleId,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedMethod = 'orange_money';
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-fill with user info if available
    final user = context.read<AuthProvider>().user;
    if (user != null) {
      _nameController.text = '${user.nom} ${user.prenom}';
      _phoneController.text = user.telephone;
    }
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IconButton(
              icon: const Icon(Symbols.arrow_back, color: AppTheme.textDark),
              onPressed: () => Navigator.pop(context),
              style: IconButton.styleFrom(
                backgroundColor: Colors.white,
                shadowColor: Colors.black.withValues(alpha: 0.05),
                elevation: 2,
              ),
            ),
          ),
          title: const Text(
            'Nouveau paiement',
            style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        extendBodyBehindAppBar: true,
        body: Stack(
          children: [
            // Background Pattern
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: CustomPaint(
                  painter: PaymentPatternPainter(),
                ),
              ),
            ),
            
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Summary Card
                      _buildSummaryCard(),
                      
                      const SizedBox(height: 24),

                      // Sender Info
                      _buildSenderInfoForm(),
                      
                      const SizedBox(height: 24),
                      
                      // Payment Methods Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Moyen de paiement',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                          ),
                          Text(
                            '3 options disponibles',
                            style: TextStyle(fontSize: 12, color: AppTheme.primaryGold, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Payment Methods List
                      _buildPaymentMethodOption(
                        id: 'orange_money',
                        title: 'Orange Money',
                        subtitle: 'Paiement mobile sécurisé',
                        icon: Symbols.smartphone,
                        iconColor: Colors.orange,
                        iconBg: Colors.orange.withValues(alpha: 0.1),
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentMethodOption(
                        id: 'wave',
                        title: 'Wave',
                        subtitle: 'Paiement instantané',
                        icon: Symbols.payments,
                        iconColor: Colors.blue,
                        iconBg: Colors.blue.withValues(alpha: 0.1),
                      ),
                      const SizedBox(height: 12),
                      _buildPaymentMethodOption(
                        id: 'moov_money',
                        title: 'Moov Money',
                        subtitle: 'Paiement mobile',
                        icon: Symbols.account_balance,
                        iconColor: Colors.blue.shade900,
                        iconBg: Colors.blue.withValues(alpha: 0.1),
                      ),
                      
                      const SizedBox(height: 32),
                      
                      // Security Info
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Symbols.lock, size: 14, color: AppTheme.grayText),
                          const SizedBox(width: 8),
                          Text(
                            'Paiement sécurisé par cryptage SSL',
                            style: TextStyle(fontSize: 12, color: AppTheme.grayText, fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Confirm Button
                      Consumer<TransactionProvider>(
                        builder: (context, provider, _) {
                          return SizedBox(
                            width: double.infinity,
                            height: 64,
                            child: ElevatedButton(
                              onPressed: provider.isLoading ? null : () async {
                                if (_phoneController.text.isEmpty || _nameController.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Veuillez remplir vos informations d\'expéditeur')),
                                  );
                                  return;
                                }

                                await provider.submitCotisation({
                                  'cycle_id': widget.cycleId,
                                  'moyen_paiement': _selectedMethod,
                                  'telephone_expediteur': _phoneController.text,
                                  'nom_expediteur': _nameController.text.split(' ').first,
                                  'prenom_expediteur': _nameController.text.contains(' ') ? _nameController.text.split(' ').sublist(1).join(' ') : ' ',
                                });

                                if (!context.mounted) return;
                                if (provider.error == null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PaymentSuccessScreen(
                                        tontineName: widget.tontineName,
                                        amount: widget.amount,
                                      ),
                                    ),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(provider.error!)),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryGold,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                                elevation: 10,
                                shadowColor: AppTheme.primaryGold.withValues(alpha: 0.4),
                              ),
                              child: provider.isLoading 
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('Confirmer le paiement', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                                      SizedBox(width: 12),
                                      Icon(Symbols.arrow_forward),
                                    ],
                                  ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryGold.withValues(alpha: 0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: const Center(
              child: Icon(Symbols.account_balance_wallet, size: 48, color: AppTheme.primaryGold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'RÉCAPITULATIF',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2, color: AppTheme.primaryGold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.amount,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGold.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Mars 2024',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                      ),
                    ),
                  ],
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Divider(height: 1),
                ),
                Row(
                  children: [
                    const Icon(Symbols.groups, size: 18, color: AppTheme.grayText),
                    const SizedBox(width: 8),
                    Text(
                      widget.tontineName,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: AppTheme.grayText),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodOption({
    required String id,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    bool isWallet = false,
  }) {
    final isSelected = _selectedMethod == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = id),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGold.withValues(alpha: 0.05) : Colors.white.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGold : Colors.white.withValues(alpha: 0.5),
            width: 2,
          ),
          boxShadow: isSelected ? [BoxShadow(color: AppTheme.primaryGold.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 8))] : null,
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: iconColor),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12, 
                      color: isWallet ? AppTheme.primaryGold : AppTheme.grayText,
                      fontWeight: isWallet ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Container(
                width: 24,
                height: 24,
                decoration: const BoxDecoration(color: AppTheme.primaryGold, shape: BoxShape.circle),
                child: const Icon(Symbols.check, color: Colors.white, size: 14),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSenderInfoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Informations de l\'expéditeur',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _nameController,
          decoration: InputDecoration(
            labelText: 'Nom Complet (sur le compte de paiement)',
            prefixIcon: const Icon(Symbols.person),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Numéro de téléphone expéditeur',
            prefixIcon: const Icon(Symbols.phone_iphone),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }
}

class PaymentPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryGold
      ..strokeWidth = 1;

    const double spacing = 10;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 0.5, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
