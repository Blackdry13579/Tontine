import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../../theme/app_theme.dart';
import '../../../core/providers/transaction_provider.dart';
import '../../../core/providers/distribution_provider.dart';
import '../../../core/models/cotisation_model.dart';
import '../../../core/models/distribution_model.dart';

class TontineHistoryTab extends StatefulWidget {
  final String tontineId;
  final String? cycleId;

  const TontineHistoryTab({super.key, required this.tontineId, this.cycleId});

  @override
  State<TontineHistoryTab> createState() => _TontineHistoryTabState();
}

class _TontineHistoryTabState extends State<TontineHistoryTab> {
  List<dynamic> _unifiedHistory = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    if (widget.cycleId == null) {
      setState(() => _isLoading = false);
      return;
    }
    
    final transProvider = context.read<TransactionProvider>();
    final distProvider = context.read<DistributionProvider>();

    try {
      final cotisationsData = await transProvider.fetchCycleCotisations(widget.cycleId!);
      await distProvider.fetchCycleDistributions(widget.cycleId!);
      
      if (mounted) {
        setState(() {
          final List<CotisationModel> cotis = (cotisationsData).map((e) => CotisationModel.fromJson(e)).toList();
          final List<DistributionModel> dists = distProvider.distributions;

          _unifiedHistory = [];
          _unifiedHistory.addAll(cotis);
          _unifiedHistory.addAll(dists);
          
          // Sort by date descending
          _unifiedHistory.sort((a, b) {
            final dateA = a is CotisationModel ? a.dateCreation : a.dateCreation;
            final dateB = b is CotisationModel ? b.dateCreation : b.dateCreation;
            return dateB.compareTo(dateA);
          });

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
    }

    if (_unifiedHistory.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 60),
            Icon(Symbols.history, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text('Aucune activité pour le moment', style: TextStyle(color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Tout', true),
                const SizedBox(width: 8),
                _buildFilterChip('Cotisations', false),
                const SizedBox(width: 8),
                _buildFilterChip('Distributions', false),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Timeline Content
          _buildMonthSection('CYCLE ACTUEL', 
            _unifiedHistory.map((item) {
              if (item is CotisationModel) {
                return _buildTimelineItem(
                  title: 'Cotisation: ${item.userName} ${item.userPrenom}',
                  amount: '${item.montant} FCFA',
                  date: '${item.dateCreation.day}/${item.dateCreation.month}/${item.dateCreation.year}',
                  status: item.statut == 'validee' ? 'Validé' : (item.statut == 'rejetee' ? 'Rejeté' : 'En attente'),
                  icon: item.statut == 'validee' ? Symbols.check_circle : (item.statut == 'rejetee' ? Symbols.cancel : Symbols.pending),
                  iconColor: item.statut == 'validee' ? Colors.green : (item.statut == 'rejetee' ? Colors.red : Colors.orange),
                  isNegative: true,
                );
              } else {
                final dist = item as DistributionModel;
                return _buildTimelineItem(
                  title: 'Distribution: ${dist.beneficiaryName}',
                  amount: '+${dist.montant} FCFA',
                  date: '${dist.dateCreation.day}/${dist.dateCreation.month}/${dist.dateCreation.year}',
                  status: 'EFFECTUÉ',
                  icon: Symbols.payments,
                  iconColor: AppTheme.primaryGold,
                  isNegative: false,
                );
              }
            }).toList()
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryGold : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.2)),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: AppTheme.primaryGold.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.white : AppTheme.textDark,
        ),
      ),
    );
  }

  Widget _buildMonthSection(String month, List<Widget> items) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 1,
                color: AppTheme.primaryGold.withValues(alpha: 0.2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0),
              child: Text(
                month,
                // ignore: deprecated_member_use
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: AppTheme.primaryGold.withValues(alpha: 0.7),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 1,
                color: AppTheme.primaryGold.withValues(alpha: 0.2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Stack(
          children: [
            // Dotted line
            Positioned(
              left: 19,
              top: 20,
              bottom: 20,
              child: CustomPaint(painter: DottedLinePainter()),
            ),
            Column(children: items),
          ],
        ),
      ],
    );
  }

  Widget _buildTimelineItem({
    required String title,
    required String amount,
    required String date,
    required String status,
    required IconData icon,
    required Color iconColor,
    required bool isNegative,
    double opacity = 1.0,
  }) {
    return Opacity(
      opacity: opacity,
      child: Container(
        margin: const EdgeInsets.only(bottom: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor,
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.creamLight, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.3),
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
                  border: Border.all(
                    color: AppTheme.primaryGold.withValues(alpha: 0.05),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
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
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textDark,
                          ),
                        ),
                        Text(
                          amount,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isNegative ? Colors.red : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.primaryGold.withValues(alpha: 0.7),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: iconColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            status.toUpperCase(),
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: iconColor,
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
      ),
    );
  }
}

class DottedLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.primaryGold.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const double dashHeight = 4;
    const double dashSpace = 4;
    double startY = 0;
    while (startY < size.height) {
      canvas.drawLine(Offset(0, startY), Offset(0, startY + dashHeight), paint);
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
