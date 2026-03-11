import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../core/providers/transaction_provider.dart';
import '../../core/providers/tontine_provider.dart';
import '../../core/models/cotisation_model.dart';
import 'distribution_order_screen.dart';
import 'launch_distribution_screen.dart';

class AdminPaymentTrackingScreen extends StatefulWidget {
  final String tontineName;
  const AdminPaymentTrackingScreen({super.key, required this.tontineName});

  @override
  State<AdminPaymentTrackingScreen> createState() =>
      _AdminPaymentTrackingScreenState();
}

class _AdminPaymentTrackingScreenState extends State<AdminPaymentTrackingScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<CotisationModel> _pendingPayments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this, initialIndex: 2);
    _loadPendingPayments();
  }

  Future<void> _loadPendingPayments() async {
    final provider = context.read<TransactionProvider>();
    final data = await provider.fetchPendingValidations();
    if (mounted) {
      setState(() {
        _pendingPayments = (data as List).map((e) => CotisationModel.fromJson(e)).toList();
        _isLoading = false;
      });
    }
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
          ),
          title: const Text(
            'Administration',
            style: TextStyle(
              color: AppTheme.emeraldDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Symbols.more_vert, color: AppTheme.emeraldDark),
              onPressed: () {},
            ),
          ],
          bottom: TabBar(
            controller: _tabController,
            isScrollable: true,
            indicatorColor: AppTheme.primaryGold,
            labelColor: AppTheme.primaryGold,
            unselectedLabelColor: AppTheme.emeraldDark.withValues(alpha: 0.6),
            tabs: const [
              Tab(text: 'Aperçu'),
              Tab(text: 'Membres'),
              Tab(text: 'Paiements'),
              Tab(text: 'Journal'),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildOverviewTab(),
                  const Center(child: Text('Liste des membres')),
                  _buildPaymentList(),
                  const Center(child: Text('Journal d\'activités')),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: _tabController.index == 2
            ? Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: FloatingActionButton.extended(
                  onPressed: () {},
                  backgroundColor: AppTheme.emeraldDark,
                  foregroundColor: Colors.white,
                  icon: const Icon(Symbols.send, size: 20),
                  label: const Text(
                    'RAPPELER TOUT LE MONDE',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              )
            : null,
        bottomNavigationBar: _buildBottomNav(),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ACTIONS ADMINISTRATEUR',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),

          _buildAdminActionCard(
            title: 'Ordre de distribution',
            subtitle: 'Gérer la séquence de réception',
            icon: Symbols.reorder,
            color: AppTheme.primaryGold,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DistributionOrderScreen(
                  tontineId: context.read<TontineProvider>().currentTontine!.id,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildAdminActionCard(
            title: 'Lancer la distribution',
            subtitle: 'Valider le versement du cycle',
            icon: Symbols.rocket_launch,
            color: AppTheme.emeraldDark,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LaunchDistributionScreen(tontine: context.read<TontineProvider>().currentTontine!),
              ),
            ),
          ),
          const SizedBox(height: 12),
          _buildAdminActionCard(
            title: 'Paramètres du groupe',
            subtitle: 'Modifier règles et montants',
            icon: Symbols.settings,
            color: AppTheme.emeraldDark,
            onTap: () {},
          ),

          const SizedBox(height: 32),

          const Text(
            'STATISTIQUES RAPIDES',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatBox(
                'Total Collecté',
                '600k',
                Symbols.account_balance_wallet,
              ),
              const SizedBox(width: 12),
              _buildStatBox('Taux de succès', '92%', Symbols.trending_up),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdminActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.1)),
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppTheme.textDark,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.grayText,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Symbols.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.emeraldDark.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppTheme.primaryGold, size: 20),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.emeraldDark,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 11, color: AppTheme.grayText),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
    }

    if (_pendingPayments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 100),
            Icon(Symbols.payments, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            const Text('Aucun paiement en attente de validation', style: TextStyle(color: AppTheme.grayText)),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildGlobalStatusCard(),
          const SizedBox(height: 24),
          const Text(
            'COTISATIONS À VALIDER',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 2, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ..._pendingPayments.map((p) => _buildValidationItem(p)),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildValidationItem(CotisationModel cotisation) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(backgroundColor: AppTheme.primaryGold.withValues(alpha: 0.1), child: const Icon(Symbols.person, color: AppTheme.primaryGold)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${cotisation.userName} ${cotisation.userPrenom}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('Via ${cotisation.moyenPaiement} • Exp: ${cotisation.telephoneExpediteur}', style: const TextStyle(fontSize: 12, color: AppTheme.grayText)),
                  ],
                ),
              ),
              Text('${cotisation.montant} FCFA', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.emeraldDark, fontSize: 16)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _handleRejection(cotisation),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('REJETER'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _handleValidation(cotisation),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.emeraldDark,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('VALIDER'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _handleValidation(CotisationModel cotisation) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la validation'),
        content: Text('Voulez-vous valider le paiement de ${cotisation.montant} FCFA de ${cotisation.userName} ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('ANNULER')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.emeraldDark), child: const Text('CONFIRMER')),
        ],
      ),
    );

    if (confirmed == true) {
      await context.read<TransactionProvider>().validateCotisation(cotisation.id);
      _loadPendingPayments(); // Refresh
    }
  }

  Future<void> _handleRejection(CotisationModel cotisation) async {
    final motifController = TextEditingController();
    final motif = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Motif du rejet'),
        content: TextField(
          controller: motifController,
          decoration: const InputDecoration(hintText: 'Ex: Preuve non reçue, Montant incorrect...'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('ANNULER')),
          ElevatedButton(onPressed: () => Navigator.pop(context, motifController.text), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('REJETER')),
        ],
      ),
    );

    if (motif != null && motif.isNotEmpty) {
      await context.read<TransactionProvider>().rejectCotisation(cotisation.id, motif);
      _loadPendingPayments(); // Refresh
    }
  }

  Widget _buildGlobalStatusCard() {
    return Container(
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'CYCLE D\'OCTOBRE',
                    style: TextStyle(
                      color: AppTheme.primaryGold,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '12 / 15 payés',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Objectif: 750,000 CFA',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: 0.8,
                      strokeWidth: 6,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppTheme.primaryGold,
                      ),
                    ),
                  ),
                  const Text(
                    '80%',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(color: Colors.white10),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?u=1',
                    ),
                  ),
                  SizedBox(width: -8),
                  CircleAvatar(
                    radius: 14,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?u=2',
                    ),
                  ),
                  SizedBox(width: -8),
                  CircleAvatar(
                    radius: 14,
                    backgroundImage: NetworkImage(
                      'https://i.pravatar.cc/150?u=3',
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    '+9',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _tabController.animateTo(0),
                child: const Row(
                  children: [
                    Text(
                      'ACTIONS',
                      style: TextStyle(
                        color: AppTheme.primaryGold,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Icon(
                      Symbols.chevron_right,
                      color: AppTheme.primaryGold,
                      size: 14,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberItem({
    required String name,
    required String subtitle,
    required String status,
    required Color statusColor,
    required String imageUrl,
    bool isPaid = false,
    bool isPending = false,
    bool isLate = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: isLate
            ? const Border(left: BorderSide(color: Colors.red, width: 4))
            : Border.all(color: AppTheme.emeraldDark.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(radius: 24, backgroundImage: NetworkImage(imageUrl)),
              if (isPaid)
                Positioned(
                  bottom: -2,
                  right: -2,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Symbols.check,
                      color: Colors.white,
                      size: 10,
                      weight: 700,
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
                    color: AppTheme.emeraldDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: isLate ? Colors.red : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ),
              if (!isPaid) ...[
                const SizedBox(width: 8),
                Container(
                  height: 32,
                  width: 32,
                  decoration: BoxDecoration(
                    color: isLate
                        ? AppTheme.primaryGold
                        : AppTheme.primaryGold.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLate
                        ? Symbols.notifications_active
                        : Symbols.notifications,
                    color: isLate ? Colors.white : AppTheme.primaryGold,
                    size: 16,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: AppTheme.primaryGold.withValues(alpha: 0.1)),
        ),
      ),
      padding: const EdgeInsets.only(top: 8, bottom: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Symbols.home, 'Accueil', false),
          _buildNavItem(Symbols.groups, 'Tontines', false),
          _buildNavItem(Symbols.account_balance_wallet, 'Paiements', true),
          _buildNavItem(Symbols.analytics, 'Stats', false),
          _buildNavItem(Symbols.person, 'Profil', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected) {
    final color = isSelected ? AppTheme.primaryGold : AppTheme.grayText;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, fill: isSelected ? 1 : 0),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: color,
          ),
        ),
      ],
    );
  }
}
