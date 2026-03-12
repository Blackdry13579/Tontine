import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../core/providers/transaction_provider.dart';
import '../../core/models/transaction_model.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  String _activeFilter = 'Tout';

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
        backgroundColor: AppTheme.creamLight.withValues(alpha: 0.8),
        elevation: 0,
        centerTitle: true,
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.1)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Symbols.arrow_back, color: AppTheme.primaryGold, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ),
        title: const Text(
          'Mon Historique',
          style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark, fontSize: 18),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.1)),
              ),
              child: IconButton(
                icon: const Icon(Symbols.search, color: AppTheme.primaryGold, size: 20),
                onPressed: () {},
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: _buildFilterChips(),
        ),
      ),
      body: Consumer<TransactionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.history.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
          }

          final filteredHistory = _getFilteredHistory(provider.history);
          if (filteredHistory.isEmpty) {
            return const Center(child: Text('Aucune transaction trouvée'));
          }

          final groupedHistory = _groupTransactionsByMonth(filteredHistory);

          return RefreshIndicator(
            onRefresh: () => provider.fetchHistory(),
            color: AppTheme.primaryGold,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              itemCount: groupedHistory.length,
              itemBuilder: (context, index) {
                final month = groupedHistory.keys.elementAt(index);
                final transactions = groupedHistory[month]!;
                return _buildMonthSection(month, transactions);
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = ['Tout', 'Cotisations', 'Distributions'];
    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isActive = _activeFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(filter),
              selected: isActive,
              onSelected: (selected) {
                if (selected) {
                  setState(() => _activeFilter = filter);
                }
              },
              selectedColor: AppTheme.primaryGold,
              labelStyle: TextStyle(
                color: isActive ? Colors.white : AppTheme.textDark,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(color: isActive ? AppTheme.primaryGold : AppTheme.primaryGold.withValues(alpha: 0.1)),
              ),
              showCheckmark: false,
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthSection(String month, List<TransactionModel> transactions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Row(
            children: [
              Expanded(child: Container(height: 1, color: AppTheme.primaryGold.withValues(alpha: 0.2))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  month.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGold,
                    letterSpacing: 2,
                  ),
                ),
              ),
              Expanded(child: Container(height: 1, color: AppTheme.primaryGold.withValues(alpha: 0.2))),
            ],
          ),
        ),
        Stack(
          children: [
            Positioned(
              left: 19,
              top: 0,
              bottom: 0,
              child: _buildDashedLine(),
            ),
            Column(
              children: transactions.map((tx) => _buildTransactionItem(tx)).toList(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDashedLine() {
    return CustomPaint(
      painter: DashedLinePainter(
        color: AppTheme.primaryGold.withValues(alpha: 0.3),
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel tx) {
    final bool isDebit = tx.type == 'cotisation' || tx.type == 'versement' || tx.type == 'frais';
    final IconData icon = isDebit ? Symbols.check_circle : Symbols.south_west;
    final String sign = isDebit ? '-' : '+';
    final String statusLabel = isDebit ? 'PAYÉ' : 'REÇU';

    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDebit ? Colors.green : AppTheme.primaryGold,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (isDebit ? Colors.green : AppTheme.primaryGold).withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.05)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          tx.type == 'cotisation' ? 'Cotisation Tontine' : 'Distribution',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '$sign${NumberFormat('#,###', 'fr_FR').format(double.tryParse(tx.montant.toString()) ?? 0.0)} FCFA',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: isDebit ? Colors.red : AppTheme.emeraldDark),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        DateFormat('dd MMMM yyyy', 'fr_FR').format(tx.dateCreation),
                        style: TextStyle(fontSize: 12, color: AppTheme.primaryGold.withValues(alpha: 0.7)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (isDebit ? Colors.green : AppTheme.primaryGold).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          statusLabel,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDebit ? Colors.green : AppTheme.primaryGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TransactionModel> _getFilteredHistory(List<TransactionModel> history) {
    if (_activeFilter == 'Tout') return history;
    if (_activeFilter == 'Cotisations') {
      return history.where((tx) => tx.type == 'cotisation' || tx.type == 'versement').toList();
    }
    if (_activeFilter == 'Distributions') {
      return history.where((tx) => tx.type == 'distribution' || tx.type == 'gain').toList();
    }
    return history;
  }

  Map<String, List<TransactionModel>> _groupTransactionsByMonth(List<TransactionModel> history) {
    final Map<String, List<TransactionModel>> groups = {};
    for (var tx in history) {
      final month = DateFormat('MMMM yyyy', 'fr_FR').format(tx.dateCreation);
      if (!groups.containsKey(month)) {
        groups[month] = [];
      }
      groups[month]!.add(tx);
    }
    return groups;
  }
}

class DashedLinePainter extends CustomPainter {
  final Color color;
  DashedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    double dashHeight = 5, dashSpace = 3, startY = 0;
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
