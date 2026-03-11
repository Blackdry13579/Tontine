import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../core/providers/transaction_provider.dart';
import '../../theme/app_theme.dart';
import 'package:intl/intl.dart';
import 'history_screen.dart';
import '../../shared/widgets/app_bottom_nav.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TransactionProvider>().fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamLight,
      appBar: AppBar(
        title: const Text('Mon Portefeuille', style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.emeraldDark)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 2),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.history.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
          }

          final resume = provider.resume;
          final history = provider.history;

          return RefreshIndicator(
            onRefresh: () => provider.fetchHistory(),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildBalanceCard(resume),
                  ),
                ),
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'HISTORIQUE DES TRANSACTIONS',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const HistoryScreen()),
                        );
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        alignment: Alignment.centerLeft,
                      ),
                      child: const Text(
                        'VOIR L\'HISTORIQUE COMPLET',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                      ),
                    ),
                  ),
                ),
                if (history.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Symbols.history, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          const Text('Aucune transaction pour le moment', style: TextStyle(color: AppTheme.grayText)),
                        ],
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final tx = history[index];
                        return _buildTransactionItem(tx);
                      },
                      childCount: history.length,
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(Map<String, dynamic>? resume) {
    if (resume == null) return const SizedBox.shrink();

    final totalValide = double.tryParse(resume['total_valide']?.toString() ?? '0') ?? 0.0;
    final totalEnAttente = double.tryParse(resume['total_en_attente']?.toString() ?? '0') ?? 0.0;
    final devise = resume['devise'] ?? 'FCFA';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.emeraldDark, Color(0xFF065F46)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.emeraldDark.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('SOLDE DISPONIBLE', style: TextStyle(color: AppTheme.primaryGold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              Icon(Symbols.account_balance_wallet, color: AppTheme.primaryGold.withValues(alpha: 0.5)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '$totalValide $devise',
            style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
          ),
          if (totalEnAttente > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Symbols.pending, color: AppTheme.primaryGold, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'En attente: $totalEnAttente $devise',
                    style: const TextStyle(color: AppTheme.primaryGold, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionItem(dynamic tx) {
    // tx is TransactionModel
    final isCredit = tx.type == 'cotisation';
    final statusColor = tx.statut == 'valide' ? Colors.green : (tx.statut == 'rejete' ? Colors.red : Colors.orange);
    final dateStr = DateFormat('dd MMM yyyy, HH:mm').format(tx.dateCreation);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (isCredit ? Colors.green : Colors.blue).withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isCredit ? Symbols.arrow_upward : Symbols.arrow_downward,
              color: isCredit ? Colors.green : Colors.blue,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tx.tontineNom ?? (isCredit ? 'Cotisation' : 'Distribution'),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(dateStr, style: const TextStyle(color: AppTheme.grayText, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? "+" : "-"}${tx.montant} FCFA',
                style: TextStyle(fontWeight: FontWeight.w900, color: isCredit ? AppTheme.emeraldDark : Colors.blue, fontSize: 15),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(
                  tx.statut.toUpperCase(),
                  style: TextStyle(color: statusColor, fontSize: 8, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
