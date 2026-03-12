import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../theme/app_theme.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/transaction_provider.dart';
import '../../core/providers/tontine_provider.dart';
import '../../core/models/tontine_model.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../tontines/tontine_detail_screen.dart';
import '../tontines/tontine_list_screen.dart';
import '../tontines/create_tontine_screen.dart';
import '../tontines/invite_members_screen.dart';
import '../payment/payment_screen.dart';
import '../../core/providers/notification_provider.dart';
import '../profile/notification_screen.dart';

class DashboardMembreScreen extends StatefulWidget {
  const DashboardMembreScreen({super.key});

  @override
  State<DashboardMembreScreen> createState() => _DashboardMembreScreenState();
}

class _DashboardMembreScreenState extends State<DashboardMembreScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().fetchProfile();
      context.read<TransactionProvider>().fetchHistory();
      context.read<TontineProvider>().fetchTontines();
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamLight,
      body: Consumer3<AuthProvider, TransactionProvider, TontineProvider>(
        builder: (context, auth, tx, tontine, _) {
          final user = auth.user;
          final resumeRaw = tx.resume?['total_valide'];
          final balance = double.tryParse(resumeRaw?.toString() ?? '0') ?? 0.0;
          final activeTontines = tontine.tontines.where((t) => t.statut == 'active').toList();

          return RefreshIndicator(
            onRefresh: () async {
              await auth.fetchProfile();
              await tx.fetchHistory();
              await tontine.fetchTontines();
              if (!context.mounted) return;
              await context.read<NotificationProvider>().fetchNotifications();
            },
            color: AppTheme.primaryGold,
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundColor: AppTheme.primaryGold,
                                  child: Text(user?.prenom?.isNotEmpty == true ? user!.prenom![0].toUpperCase() : 'U', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                                ),
                                Positioned(
                                  bottom: 0,
                                  right: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      shape: BoxShape.circle,
                                      border: Border.all(color: AppTheme.creamLight, width: 2),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BIENVENUE',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey.shade500,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Text(
                                  'Bonjour, ${user?.prenom ?? "Ami"}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.emeraldDark,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        Consumer<NotificationProvider>(
                          builder: (context, notif, _) {
                            final count = notif.unreadCount;
                            return GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const NotificationScreen()),
                              ),
                              child: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 2)),
                                      ],
                                    ),
                                    child: const Icon(Symbols.notifications, color: AppTheme.emeraldDark),
                                  ),
                                  if (count > 0)
                                    Positioned(
                                      right: 0,
                                      top: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Text(
                                          count > 9 ? '9+' : '$count',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 8,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                // Balance Card
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppTheme.emeraldDark,
                        borderRadius: BorderRadius.circular(20),
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
                          const Text(
                            'SOLDE TOTAL',
                            style: TextStyle(
                              color: AppTheme.primaryGold,
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 2,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            '${NumberFormat('#,###', 'fr_FR').format(balance)} FCFA',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Text(
                                  '+12% ce mois',
                                  style: TextStyle(color: AppTheme.primaryGold, fontSize: 10, fontWeight: FontWeight.bold),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'Dernière mise à jour: Aujourd\'hui',
                                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 10),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Quick Actions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickAction(
                          icon: Symbols.add_card,
                          label: 'Verser',
                          color: AppTheme.primaryGold,
                          onTap: () {
                            final firstTontine = activeTontines.isNotEmpty ? activeTontines.first : null;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => PaymentScreen(
                                  tontineName: firstTontine?.nom ?? 'Ma Tontine',
                                  amount: firstTontine?.montantCotisation.toString() ?? '0',
                                  cycleId: '', // Ideally fetch from provider but for now placeholder to fix compile
                                ),
                              ),
                            );
                          },
                        ),
                        _buildQuickAction(
                          icon: Symbols.person_add,
                          label: 'Créer',
                          color: Colors.white,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTontineScreen())),
                        ),
                        _buildQuickAction(
                          icon: Symbols.share,
                          label: 'Inviter',
                          color: Colors.white,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InviteMembersScreen(tontineName: 'Ma Tontine'))),
                        ),
                      ],
                    ),
                  ),
                ),

                // Next Deadline
                if (activeTontines.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: const Border(left: BorderSide(color: AppTheme.primaryGold, width: 4)),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryGold.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Symbols.calendar_today, color: AppTheme.primaryGold),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    activeTontines.first.nom.toUpperCase(),
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.grey.shade400),
                                  ),
                                  const Text(
                                    'Prochaine échéance',
                                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppTheme.emeraldDark),
                                  ),
                                  const Text(
                                    'Dû le 14 Octobre',
                                    style: TextStyle(fontSize: 12, color: AppTheme.grayText),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${activeTontines.first.montantCotisation} FCFA',
                                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => PaymentScreen(
                                          tontineName: activeTontines.first.nom,
                                          amount: activeTontines.first.montantCotisation.toString(),
                                          cycleId: activeTontines.first.currentCycleId ?? '',
                                        ),
                                      ),
                                    );
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryGold,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text('PAYER',
                                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                // Active Tontines Section
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mes Tontines Actives',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.emeraldDark),
                        ),
                        TextButton(
                          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TontineListScreen())),
                          child: const Text('VOIR TOUT', style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ),

                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tontine = activeTontines[index];
                      return _buildActiveTontineCard(tontine);
                    },
                    childCount: activeTontines.length,
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }

  Widget _buildQuickAction({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    final bool isGold = color == AppTheme.primaryGold;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
              border: isGold ? null : Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.2)),
              boxShadow: isGold ? [BoxShadow(color: AppTheme.primaryGold.withValues(alpha: 0.4), blurRadius: 12, offset: const Offset(0, 6))] : null,
            ),
            child: Icon(icon, color: isGold ? Colors.white : AppTheme.primaryGold),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.emeraldDark)),
        ],
      ),
    );
  }

  Widget _buildActiveTontineCard(TontineModel tontine) {
    // Calcul de progression mocké
    const double progress = 0.6; 
    
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => TontineDetailScreen(tontineId: tontine.id, tontineName: tontine.nom),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.emeraldDark.withValues(alpha: 0.05)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.02), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppTheme.emeraldDark.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Symbols.flight_takeoff, color: AppTheme.emeraldDark),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tontine.nom, style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.emeraldDark)),
                        Text('Fin: 24 Dec 2024', style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                Text('${(progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold)),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.grey.shade100,
              color: AppTheme.primaryGold,
              minHeight: 6,
              borderRadius: BorderRadius.circular(3),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    _AvatarGroup(),
                  ],
                ),
                Text(
                  'Objectif: 2.5M FCFA',
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade400, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarGroup extends StatelessWidget {
  const _AvatarGroup();
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 20,
      child: Stack(
        children: [
          Positioned(left: 0, child: _smallInitialsAvatar('A')),
          Positioned(left: 12, child: _smallInitialsAvatar('B')),
          Positioned(
            left: 24,
            child: Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 1),
              ),
              child: const Center(child: Text('+8', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallInitialsAvatar(String initial) {
    return Container(
      width: 20,
      height: 20,
      decoration: BoxDecoration(
        color: AppTheme.primaryGold,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 1),
      ),
      child: Center(
        child: Text(
          initial,
          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
