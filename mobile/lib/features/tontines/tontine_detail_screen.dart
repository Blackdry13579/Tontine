import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import '../../core/providers/tontine_provider.dart';
import '../../core/models/tontine_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/distribution_provider.dart';
import '../../core/providers/transaction_provider.dart';
import '../../theme/app_theme.dart';
import 'widgets/tontine_members_tab.dart';
import 'widgets/tontine_history_tab.dart';
import '../payment/payment_screen.dart';
import 'create_tontine_screen.dart';
import '../activities/launch_distribution_screen.dart';
import 'members_list_screen.dart';

class TontineDetailScreen extends StatefulWidget {
  final String tontineId;
  final String tontineName;
  
  const TontineDetailScreen({
    super.key, 
    required this.tontineId,
    required this.tontineName,
  });

  @override
  State<TontineDetailScreen> createState() => _TontineDetailScreenState();
}

class _TontineDetailScreenState extends State<TontineDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<dynamic> _currentCycleCotisations = [];
  bool _fetchingStats = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    final tontineProvider = context.read<TontineProvider>();
    final transactionProvider = context.read<TransactionProvider>();
    final distributionProvider = context.read<DistributionProvider>();

    await tontineProvider.fetchTontineById(widget.tontineId);
    final tontine = tontineProvider.currentTontine;

    if (tontine?.currentCycleId != null) {
      if (mounted) setState(() => _fetchingStats = true);
      
      final cotis = await transactionProvider.fetchCycleCotisations(tontine!.currentCycleId!);
      await distributionProvider.fetchCycleDistributions(tontine.currentCycleId!);
      
      if (mounted) {
        setState(() {
          _currentCycleCotisations = cotis as List;
          _fetchingStats = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppTheme.creamLight.withValues(alpha: 0.8),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Symbols.arrow_back, color: AppTheme.emeraldDark),
            onPressed: () => Navigator.pop(context),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white,
              shadowColor: Colors.black.withValues(alpha: 0.05),
              elevation: 2,
            ),
          ),
          title: Text(
            widget.tontineName,
            style: const TextStyle(
              color: AppTheme.emeraldDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            Consumer<TontineProvider>(
              builder: (context, provider, _) {
                final tontine = provider.currentTontine;
                if (tontine != null && tontine.organisateurId == context.read<AuthProvider>().user?.id) {
                  return IconButton(
                    icon: const Icon(Symbols.settings, color: AppTheme.emeraldDark),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateTontineScreen(tontine: tontine),
                        ),
                      );
                    },
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                      shadowColor: Colors.black.withValues(alpha: 0.05),
                      elevation: 2,
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Consumer<TontineProvider>(
          builder: (context, provider, child) {
            final tontine = provider.currentTontine;
            
            if (provider.isLoading && tontine == null) {
              return const Center(child: CircularProgressIndicator());
            }

            if (tontine == null) {
              return Center(child: Text(provider.error ?? 'Tontine non trouvée'));
            }

            return Column(
              children: [
                // Custom Tab Bar
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: SizedBox(
                    height: 40,
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicator: BoxDecoration(
                        color: AppTheme.primaryGold,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.primaryGold.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: Colors.white,
                      unselectedLabelColor: AppTheme.emeraldDark.withValues(alpha: 0.6),
                      labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                      tabs: const [
                        Tab(text: 'Aperçu'),
                        Tab(text: 'Membres'),
                        Tab(text: 'Historique'),
                        Tab(text: 'Règlement'),
                      ],
                    ),
                  ),
                ),

                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOverviewTab(tontine),
                      _buildMembersTab(tontine),
                      TontineHistoryTab(
                        tontineId: tontine.id, 
                        cycleId: tontine.currentCycleId,
                      ),
                      const Center(child: Text('Règles de la tontine')),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        bottomNavigationBar: Consumer<TontineProvider>(
          builder: (context, provider, _) {
            if (provider.currentTontine == null) return const SizedBox.shrink();
            return _buildBottomAction(provider.currentTontine!);
          },
        ),
      ),
    );
  }

  Widget _buildMembersTab(TontineModel tontine) {
    return Column(
      children: [
        Expanded(child: TontineMembersTab()),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => MembersListScreen(tontineId: widget.tontineId)
            )),
            child: const Text('VOIR TOUS LES MEMBRES'),
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab(TontineModel tontine) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Hero Card - Cagnotte
          _buildCagnotteCard(tontine),

          const SizedBox(height: 24),

          // Next Beneficiary
          Consumer<DistributionProvider>(
            builder: (context, distProvider, _) {
              if (distProvider.distributions.isEmpty) {
                return _buildNoBeneficiaryCard();
              }
              final distribution = distProvider.distributions.first;
              return _buildNextBeneficiaryCard(tontine, distribution);
            },
          ),

          const SizedBox(height: 24),
          
          if (tontine.codeInvitation != null) ...[
            _buildInvitationCard(tontine),
            const SizedBox(height: 24),
          ],

          // Payment Status
          const Text(
            'Statut des paiements (Cycle Actuel)',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppTheme.emeraldDark,
            ),
          ),
          const SizedBox(height: 12),
          
          if (_fetchingStats)
            const Center(child: Padding(
              padding: EdgeInsets.all(20.0),
              child: CircularProgressIndicator(),
            ))
          else if (_currentCycleCotisations.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('Aucun paiement soumis pour ce cycle', style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey)),
            )
          else
            ..._currentCycleCotisations.map((c) {
              final isMe = c['user_id'] == context.read<AuthProvider>().user?.id;
              final dateStr = c['date_paiement'] ?? c['created_at'];
              DateTime? date;
              if (dateStr != null) {
                try {
                  date = DateTime.parse(dateStr);
                } catch (_) {}
              }
              
              Color statusColor;
              String statusText;
              
              switch (c['statut']) {
                case 'validee':
                  statusColor = Colors.green;
                  statusText = 'CONFIRMÉ';
                  break;
                case 'rejetee':
                  statusColor = Colors.red;
                  statusText = 'REJETÉ';
                  break;
                default:
                  statusColor = AppTheme.primaryGold;
                  statusText = 'EN ATTENTE';
              }

              return _buildMemberPaymentTile(
                name: '${c['user_prenom'] ?? 'Membre'} ${c['user_nom'] ?? ''}',
                subtitle: date != null 
                    ? (c['statut'] == 'validee' ? 'Payé le ${date.day}/${date.month}' : 'Soumis le ${date.day}/${date.month}')
                    : 'Statut : $statusText',
                status: statusText,
                statusColor: statusColor,
                isMe: isMe,
              );
            }).toList(),

          const SizedBox(height: 80), // Space for bottom button
        ],
      ),
    );
  }

  Widget _buildCagnotteCard(TontineModel tontine) {
    final double totalGoal = tontine.montantCotisation * tontine.nombreMembresMax;
    final double currentCollected = tontine.montantCotisation * tontine.nombreMembresActuels;
    final double progress = tontine.nombreMembresMax > 0 ? tontine.nombreMembresActuels / tontine.nombreMembresMax : 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.emeraldDark,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.emeraldDark.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryGold.withValues(alpha: 0.1),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'CAGNOTTE TOTALE',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    totalGoal.toStringAsFixed(0),
                    style: const TextStyle(
                      color: AppTheme.primaryGold,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'FCFA',
                    style: TextStyle(
                      color: Color(0xCCF1D374),
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Progression de la collecte',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      color: AppTheme.primaryGold,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              LinearProgressIndicator(
                value: progress,
                backgroundColor: Colors.white10,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.primaryGold,
                ),
                borderRadius: BorderRadius.circular(10),
                minHeight: 10,
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  '${currentCollected.toStringAsFixed(0)} / ${totalGoal.toStringAsFixed(0)} FCFA collectés',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNextBeneficiaryCard(TontineModel tontine, dynamic distribution) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.1)),
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
              const Text(
                'Bénéficiaire du Cycle',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.emeraldDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'DISTRIBUÉ',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGold,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryGold.withValues(alpha: 0.2),
                    width: 2,
                  ),
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundColor: AppTheme.emeraldDark,
                  child: Text(
                    ((distribution['prenomBeneficiaire'] as String?)?[0] ?? 'U') + 
                    ((distribution['nomBeneficiaire'] as String?)?[0] ?? 'N'),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${distribution.prenomBeneficiaire} ${distribution.nomBeneficiaire}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.emeraldDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text.rich(
                      TextSpan(
                        text: 'Montant perçu : ',
                        style: const TextStyle(
                          fontSize: 13,
                          color: Colors.black54,
                        ),
                        children: [
                          TextSpan(
                            text: '${distribution.montant} FCFA',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.emeraldDark,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Symbols.payments,
                color: AppTheme.primaryGold,
                size: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoBeneficiaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: const Center(
        child: Text(
          'Aucun bénéficiaire désigné pour ce cycle',
          style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
        ),
      ),
    );
  }

  Widget _buildMemberPaymentTile({
    required String name,
    required String subtitle,
    required String status,
    required Color statusColor,
    String? imageUrl,
    bool isMe = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isMe ? AppTheme.primaryGold.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: isMe
            ? Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.2))
            : null,
        boxShadow: isMe
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.02),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          isMe
              ? Container(
                  width: 40,
                  height: 40,
                  decoration: const BoxDecoration(
                    color: AppTheme.emeraldDark,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Text(
                      'VOUS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              : CircleAvatar(
                  radius: 20,
                  backgroundImage: imageUrl != null
                      ? NetworkImage(imageUrl)
                      : null,
                ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppTheme.emeraldDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppTheme.emeraldDark.withValues(alpha: 0.5),
                    fontStyle: isMe ? FontStyle.italic : null,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(TontineModel tontine) {
    final userId = context.read<AuthProvider>().user?.id;
    final isOrganisateur = tontine.organisateurId == userId;

    if (tontine.statut == 'en_attente') {
      if (!isOrganisateur) return const SizedBox.shrink();
      return _buildActionContainer(
        onPressed: () => context.read<TontineProvider>().updateTontineStatus(tontine.id, 'active').then((_) => _refreshData()),
        label: 'LANCER LA TONTINE',
        color: AppTheme.emeraldDark,
      );
    }

    if (tontine.statut == 'active') {
      // Logic for "Lancer la Distribution" vs "Voir Cotisations"
      final validatedCount = _currentCycleCotisations.where((c) => c['statut'] == 'validee').length;
      final everyonePaid = validatedCount >= tontine.nombreMembresActuels && tontine.nombreMembresActuels > 0;

      if (isOrganisateur && everyonePaid) {
        return _buildActionContainer(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => LaunchDistributionScreen(tontine: tontine)),
          ).then((_) => _refreshData()),
          label: 'LANCER LA DISTRIBUTION',
          color: AppTheme.emeraldDark,
        );
      }

      // If not yet distributed or not everyone paid
      // Organizers see "Voir les cotisations", Members see "Payer ma part"
      if (isOrganisateur) {
        return _buildActionContainer(
          onPressed: () => _tabController.animateTo(2), // Switch to history tab
          label: 'VOIR LES COTISATIONS ($validatedCount/${tontine.nombreMembresActuels})',
          color: AppTheme.emeraldDark,
        );
      }

      // For normal members:
      final myCotis = _currentCycleCotisations.any((c) => c['user_id'] == userId && c['statut'] == 'validee');
      if (myCotis) {
        return _buildActionContainer(
          onPressed: () => _tabController.animateTo(2),
          label: 'COTISATION VALIDÉE',
          color: Colors.green,
          icon: Symbols.check_circle,
        );
      }

      return _buildActionContainer(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PaymentScreen(
              tontineName: tontine.nom,
              amount: '${tontine.montantCotisation.toStringAsFixed(0)} FCFA',
              cycleId: tontine.currentCycleId ?? '',
            ),
          ),
        ).then((_) => _refreshData()),
        label: 'PAYER MA PART - ${tontine.montantCotisation.toStringAsFixed(0)} FCFA',
        color: AppTheme.primaryGold,
        icon: Symbols.account_balance_wallet,
      );
    }

    if (tontine.statut == 'terminee') {
      return _buildActionContainer(
        onPressed: () => _tabController.animateTo(2),
        label: 'VOIR L\'HISTORIQUE',
        color: AppTheme.emeraldDark,
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildActionContainer({
    required VoidCallback onPressed,
    required String label,
    required Color color,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          elevation: 15,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon), const SizedBox(width: 12)],
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
          ],
        ),
      ),
    );
  }

  Widget _buildInvitationCard(TontineModel tontine) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Text('CODE D\'INVITATION', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryGold, letterSpacing: 1)),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(tontine.codeInvitation!, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.emeraldDark, letterSpacing: 4)),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Symbols.content_copy, color: AppTheme.emeraldDark),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: tontine.codeInvitation!));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Code copié dans le presse-papiers')),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
