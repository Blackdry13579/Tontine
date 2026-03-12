import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../theme/app_theme.dart';

class CompletedTontineDetailScreen extends StatelessWidget {
  final String tontineId;
  final String tontineName;
  const CompletedTontineDetailScreen({super.key, required this.tontineId, required this.tontineName});

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.emeraldDark,
          elevation: 4,
          leading: IconButton(
            icon: const Icon(Symbols.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            tontineName,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.primaryGold.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppTheme.primaryGold.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                children: [
                  CircleAvatar(
                    radius: 4,
                    backgroundColor: AppTheme.primaryGold,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'AURUM LUXE',
                    style: TextStyle(
                      color: AppTheme.primaryGold,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Hero Status Card
              _buildHeroCard(),

              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Member Payout List
                    _buildSectionHeader(
                      'Membres & Versements',
                      '12 Participants',
                    ),
                    const SizedBox(height: 16),
                    _buildPayoutItem(
                      'Aminata Diop',
                      'Bénéficiaire Janvier',
                      '2,500,000 FCFA',
                      '01',
                    ),
                    _buildPayoutItem(
                      'Koffi Kouamé',
                      'Bénéficiaire Février',
                      '2,500,000 FCFA',
                      '02',
                    ),
                    _buildPayoutItem(
                      'Moussa Koné',
                      'Bénéficiaire Mars',
                      '2,500,000 FCFA',
                      '03',
                    ),

                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: const BorderSide(
                          color: AppTheme.primaryGold,
                          style: BorderStyle.none,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        backgroundColor: AppTheme.primaryGold.withValues(alpha: 0.05),
                      ),
                      child: const Center(
                        child: Text(
                          'VOIR LES 9 AUTRES MEMBRES',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryGold,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Financial Summary
                    _buildSectionHeader('Récapitulatif Financier', null),
                    const SizedBox(height: 16),
                    _buildStatCard(
                      'Cotisation par cycle',
                      '208,333 FCFA',
                      AppTheme.primaryGold.withValues(alpha: 0.1),
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      'Gain par bénéficiaire',
                      '2,500,000 FCFA',
                      AppTheme.primaryGold.withValues(alpha: 0.1),
                    ),
                    const SizedBox(height: 12),
                    _buildStatCard(
                      'Total distribué',
                      '30,000,000 FCFA',
                      AppTheme.primaryGold.withValues(alpha: 0.2),
                    ),

                    const SizedBox(height: 60),

                    // Footer
                    Center(
                      child: Column(
                        children: [
                          Container(
                            height: 1,
                            width: 40,
                            color: AppTheme.primaryGold.withValues(alpha: 0.3),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'AURUM LUXE DIGITAL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                              color: AppTheme.primaryGold,
                            ),
                          ),
                          const Text(
                            'Sécurisé & Garanti par la Communauté',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.grayText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.emeraldDark,
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Symbols.verified, color: Colors.white, size: 14),
                SizedBox(width: 8),
                Text(
                  'TERMINÉE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Montant Total Épargné',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppTheme.grayText,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '2,500,000',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.emeraldDark,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'FCFA',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),
            child: Column(
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Cycle Complété',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '12/12 Mois',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 12,
                  width: double.infinity,
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: AppTheme.emeraldDark.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryGold.withValues(alpha: 0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.emeraldDark.withValues(alpha: 0.05),
              border: Border(
                top: BorderSide(color: AppTheme.emeraldDark.withValues(alpha: 0.1)),
              ),
            ),
            child: Row(
              children: [
                _buildInfoItem('Date de début', '01 Jan. 2023', true),
                _buildInfoItem('Date de clôture', '31 Déc. 2023', true),
                _buildInfoItem('Fréquence', 'MENSUELLE', false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, bool border) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: border
            ? BoxDecoration(
                border: Border(
                  right: BorderSide(
                    color: AppTheme.emeraldDark.withValues(alpha: 0.1),
                  ),
                ),
              )
            : null,
        child: Column(
          children: [
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.bold,
                color: AppTheme.grayText,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: label.contains('clôture')
                    ? AppTheme.primaryGold
                    : AppTheme.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, String? count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 32,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.primaryGold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 12),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.emeraldDark,
              ),
            ),
          ],
        ),
        if (count != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              count,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppTheme.grayText,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPayoutItem(
    String name,
    String subtitle,
    String amount,
    String rank,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.emeraldDark.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppTheme.primaryGold,
                child: Text(
                  name.isNotEmpty ? name[0].toUpperCase() : 'U',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              Positioned(
                top: -2,
                left: -2,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: const BoxDecoration(
                    color: AppTheme.emeraldDark,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      rank,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.grayText,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTheme.emeraldDark,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'PAYÉ',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                amount,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, Color bgColor) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.emeraldDark,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.emeraldDark.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primaryGold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          Icon(
            Symbols.payments,
            color: AppTheme.primaryGold.withValues(alpha: 0.5),
            size: 32,
          ),
        ],
      ),
    );
  }
}
