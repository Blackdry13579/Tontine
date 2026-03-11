import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/tontine_provider.dart';
import '../../core/providers/transaction_provider.dart';
import '../../core/providers/notification_provider.dart';
import '../../theme/app_theme.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import '../tontines/tontine_detail_screen.dart';
import '../tontines/tontine_list_screen.dart';
import '../tontines/create_tontine_screen.dart';
import '../tontines/invite_members_screen.dart';
import '../activities/wallet_screen.dart';
import '../activities/admin_dashboard_screen.dart';
import '../payment/payment_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshData();
    });
  }

  Future<void> _refreshData() async {
    await Future.wait([
      context.read<TontineProvider>().fetchTontines(),
      context.read<TransactionProvider>().fetchHistory(),
      context.read<NotificationProvider>().fetchNotifications(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: AppTheme.lightTheme,
      child: Scaffold(
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: _refreshData,
            child: CustomScrollView(
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Consumer<AuthProvider>(
                          builder: (context, auth, _) {
                            final user = auth.user;
                            return Row(
                              children: [
                                Stack(
                                  alignment: Alignment.bottomRight,
                                  children: [
                                    Container(
                                      width: 48,
                                      height: 48,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.2), width: 2),
                                        image: DecorationImage(
                                          image: NetworkImage(user?.photoUrl ?? 'https://i.pravatar.cc/150?u=${user?.id ?? "default"}'),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppTheme.creamLight, width: 2),
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
                                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1),
                                    ),
                                    Text(
                                      'Bonjour, ${user?.prenom ?? "Utilisateur"}',
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.emeraldDark),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        Consumer<NotificationProvider>(
                          builder: (context, notif, _) {
                            return Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                              ),
                              child: Badge(
                                label: Text(notif.unreadCount.toString()),
                                isLabelVisible: notif.unreadCount > 0,
                                backgroundColor: AppTheme.primaryGold,
                                child: const Icon(Symbols.notifications, color: AppTheme.emeraldDark),
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
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Consumer<TransactionProvider>(
                      builder: (context, tx, _) {
                        if (tx.isLoading && tx.resume == null) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.all(32.0),
                              child: CircularProgressIndicator(color: AppTheme.primaryGold),
                            ),
                          );
                        }
                        
                        if (tx.error != null && tx.resume == null) {
                          return Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.red.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: Center(
                              child: Column(
                                children: [
                                  const Icon(Symbols.error, color: Colors.red),
                                  const SizedBox(height: 8),
                                  Text(tx.error!, style: const TextStyle(color: Colors.red, fontSize: 12), textAlign: TextAlign.center),
                                  TextButton(
                                    onPressed: _refreshData,
                                    child: const Text('RÉESSAYER', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                  )
                                ],
                              ),
                            ),
                          );
                        }

                        final resume = tx.resume;
                        final totalValide = resume?['total_valide'] ?? 0;
                        final devise = resume?['devise'] ?? 'FCFA';

                        return Container(
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: AppTheme.emeraldDark,
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
                              const Text(
                                'SOLDE TOTAL',
                                style: TextStyle(color: AppTheme.primaryGold, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 2),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    '$totalValide $devise',
                                    style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1),
                                  ),
                                  const Icon(Symbols.account_balance_wallet, color: AppTheme.primaryGold, size: 32),
                                ],
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                                    child: Text(
                                      '${resume?['nombre_paiements'] ?? 0} versements',
                                      style: const TextStyle(color: AppTheme.primaryGold, fontSize: 10, fontWeight: FontWeight.bold),
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
                        );
                      },
                    ),
                  ),
                ),
                
                // Quick Actions
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 32.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildQuickAction(Symbols.add_card, 'Verser', true, onTap: () {
                          final provider = context.read<TontineProvider>();
                          final active = provider.tontines.where((t) => t.statut == 'active').firstOrNull;
                          if (active != null && active.currentCycleId != null) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => PaymentScreen(tontineName: active.nom, amount: active.montantCotisation.toStringAsFixed(0), cycleId: active.currentCycleId!)));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Aucune tontine active pour faire un versement.')));
                          }
                        }),
                        _buildQuickAction(Symbols.person_add, 'Créer', false, onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateTontineScreen()));
                        }),
                        _buildQuickAction(Symbols.share, 'Inviter', false, onTap: () {
                          final provider = context.read<TontineProvider>();
                          final tontine = provider.tontines.isNotEmpty ? provider.tontines.first : null;
                          if (tontine != null) {
                            Navigator.push(context, MaterialPageRoute(builder: (_) => InviteMembersScreen(tontineName: tontine.nom)));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez d\'abord créer une tontine.')));
                          }
                        }),
                      ],
                    ),
                  ),
                ),
                
                // Section Tontines
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Mes Tontines Actives',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.emeraldDark),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const TontineListScreen()));
                          },
                          child: const Text('VOIR TOUT', style: TextStyle(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 13)),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Tontine Cards List
                Consumer<TontineProvider>(
                  builder: (context, provider, _) {
                    final tontines = provider.tontines.where((t) => t.statut == 'active').take(3).toList();
                    
                    if (provider.isLoading && tontines.isEmpty) {
                      return const SliverToBoxAdapter(child: Center(child: CircularProgressIndicator()));
                    }

                    if (tontines.isEmpty) {
                      return SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Center(
                            child: Text(
                              'Aucune tontine active',
                              style: TextStyle(color: Colors.grey.shade400),
                            ),
                          ),
                        ),
                      );
                    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final tontine = tontines[index];
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TontineDetailScreen(
                      tontineId: tontine.id,
                      tontineName: tontine.nom,
                    ),
                  ),
                );
              },
              child: _buildHomeTontineCard(
                title: tontine.nom,
                deadline: tontine.dateDebut != null 
                  ? 'Débuté le ${tontine.dateDebut!.day}/${tontine.dateDebut!.month}/${tontine.dateDebut!.year}'
                  : 'En attente',
                progress: tontine.nombreMembresActuels / tontine.nombreMembresMax,
                goal: '${tontine.montantCotisation} FCFA / mois',
                imgUrl: 'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?q=80&w=500',
              ),
            );
          },
          childCount: tontines.length,
        ),
      ),
    );
                  },
                ),
                
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateTontineScreen())),
          backgroundColor: AppTheme.primaryGold,
          shape: const CircleBorder(),
          child: const Icon(Symbols.add, color: Colors.white, size: 28),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
        bottomNavigationBar: const AppBottomNav(currentIndex: 0),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, bool isPrimary, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isPrimary ? AppTheme.primaryGold : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: isPrimary ? null : Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: isPrimary ? AppTheme.primaryGold.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(icon, color: isPrimary ? Colors.white : AppTheme.primaryGold, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.emeraldDark),
          ),
        ],
      ),
    );
  }

  Widget _buildHomeTontineCard({required String title, required String deadline, required double progress, required String goal, required String imgUrl}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: AppTheme.emeraldDark.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(imgUrl, width: 48, height: 48, fit: BoxFit.cover),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppTheme.emeraldDark)),
                    Text(deadline.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5)),
                  ],
                ),
              ),
              Text('${(progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryGold)),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: Colors.grey.shade100,
            valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGold),
            borderRadius: BorderRadius.circular(10),
            minHeight: 6,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.center,
                children: [
                  const CircleAvatar(radius: 10, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=4')),
                  const Positioned(left: 14, child: CircleAvatar(radius: 10, backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=5'))),
                  const SizedBox(width: 36),
                  const Positioned(left: 30, child: Text('+8', style: TextStyle(fontSize: 8, fontWeight: FontWeight.bold, color: Colors.grey))),
                ],
              ),
              Text('Objectif: $goal', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateTontineScreen()));
      },
      child: Container(
        height: 64,
        width: 64,
        margin: const EdgeInsets.only(top: 24),
        decoration: BoxDecoration(
          color: AppTheme.primaryGold,
          shape: BoxShape.circle,
          border: Border.all(color: AppTheme.emeraldDark, width: 4),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGold.withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: const Icon(Symbols.add, color: Colors.white, size: 32, weight: 700),
      ),
    );
  }

  Widget _buildBottomNav() {
    return BottomAppBar(
      height: 80,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      color: Colors.white,
      notchMargin: 12,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Symbols.home, 'ACCUEIL', true,
            onTap: () {}),
          _buildNavItem(Symbols.pie_chart, 'TONTINES', false,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TontineListScreen()))),
          const SizedBox(width: 48), // Space for FAB
          _buildNavItem(Symbols.account_balance_wallet, 'WALLET', false,
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WalletScreen()))),
          Consumer<AuthProvider>(
            builder: (context, auth, _) {
              final isAdmin = auth.user?.roleSysteme == 'admin';
              return _buildNavItem(
                Symbols.person,
                'PROFIL',
                false,
                onTap: () {
                  if (isAdmin) {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const AdminDashboardScreen()));
                  }
                }
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isSelected, {required VoidCallback onTap}) {
    final color = isSelected ? AppTheme.primaryGold : Colors.grey.shade400;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, fill: isSelected ? 1 : 0),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: color, letterSpacing: 0.5),
          ),
        ],
      ),
    );
  }
}
