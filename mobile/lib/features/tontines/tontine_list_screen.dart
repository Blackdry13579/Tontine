import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../core/providers/tontine_provider.dart';
import '../../core/models/tontine_model.dart';
import '../../theme/app_theme.dart';
import '../../shared/widgets/app_bottom_nav.dart';
import 'tontine_detail_screen.dart';
import 'completed_tontine_detail_screen.dart';
import 'create_tontine_screen.dart';
import '../activities/admin_payment_tracking_screen.dart';

class TontineListScreen extends StatefulWidget {
  const TontineListScreen({super.key});

  @override
  State<TontineListScreen> createState() => _TontineListScreenState();
}

class _TontineListScreenState extends State<TontineListScreen> {
  int _selectedFilter = 0; // 0: Toutes, 1: Actives, 2: Terminées

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TontineProvider>().fetchTontines();
    });
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
            icon: const Icon(Symbols.arrow_back, color: AppTheme.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Mes Tontines',
            style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              icon: const Icon(Symbols.search, color: AppTheme.textDark),
              onPressed: () {},
            ),
          ],
        ),
        body: Consumer<TontineProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.tontines.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (provider.error != null && provider.tontines.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(provider.error!),
                    ElevatedButton(
                      onPressed: () => provider.fetchTontines(),
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            final filteredList = _getFilteredList(provider.tontines);

            return Column(
              children: [
                // Filtres
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGold.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        _buildFilterOption('Toutes', 0),
                        _buildFilterOption('Actives', 1),
                        _buildFilterOption('Terminées', 2),
                      ],
                    ),
                  ),
                ),
                
                // Liste des tontines
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () => provider.fetchTontines(),
                    child: filteredList.isEmpty
                        ? const Center(child: Text('Aucune tontine trouvée'))
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredList.length,
                            itemBuilder: (context, index) {
                              final tontine = filteredList[index];
                              return GestureDetector(
                                onTap: () {
                                  if (tontine.statut != 'terminee') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => TontineDetailScreen(
                                          tontineId: tontine.id,
                                          tontineName: tontine.nom,
                                        ),
                                      ),
                                    );
                                  }
                                },
                                child: tontine.statut == 'terminee'
                                    ? _buildCompletedCard(
                                        tontineId: tontine.id,
                                        title: tontine.nom,
                                        amount: '${tontine.montantCotisation} FCFA',
                                        role: 'Membre',
                                        months: '${tontine.nombreMembresActuels}/${tontine.nombreMembresMax} membres',
                                        imgUrl: 'https://images.unsplash.com/photo-1590073242678-70ee3fc28e8e?q=80&w=500',
                                      )
                                    : _buildTontineCard(
                                        tontineId: tontine.id,
                                        title: tontine.nom,
                                        amount: '${tontine.montantCotisation} FCFA',
                                        progress: tontine.nombreMembresActuels / tontine.nombreMembresMax,
                                        progressText: '${tontine.nombreMembresActuels}/${tontine.nombreMembresMax} membres',
                                        status: tontine.statut,
                                        role: 'Membre',
                                        info: tontine.description ?? 'Aucune description',
                                        infoIcon: Symbols.info,
                                        statusColor: tontine.statut == 'active' ? AppTheme.emeraldDark : Colors.orange,
                                      ),
                              );
                            },
                          ),
                  ),
                ),
              ],
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const CreateTontineScreen()));
          },
          backgroundColor: AppTheme.primaryGold,
          foregroundColor: Colors.white,
          shape: const CircleBorder(),
          elevation: 4,
          child: const Icon(Symbols.add, size: 30),
        ),
        bottomNavigationBar: const AppBottomNav(currentIndex: 1),
      ),
    );
  }

  List<TontineModel> _getFilteredList(List<TontineModel> tontines) {
    if (_selectedFilter == 1) return tontines.where((t) => t.statut == 'active' || t.statut == 'en_attente').toList();
    if (_selectedFilter == 2) return tontines.where((t) => t.statut == 'terminee').toList();
    return tontines;
  }

  Widget _buildFilterOption(String label, int index) {
    final isSelected = _selectedFilter == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedFilter = index),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryGold : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: isSelected ? Colors.white : AppTheme.grayText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCompletedCard({required String tontineId, required String title, required String amount, required String role, required String months, required String imgUrl}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
        border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.1)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            Stack(
              children: [
                Image.network(imgUrl, height: 140, width: double.infinity, fit: BoxFit.cover),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(color: AppTheme.primaryGold, borderRadius: BorderRadius.circular(8)),
                    child: const Text('TERMINÉE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.emeraldDark)),
                        const SizedBox(height: 4),
                        Text('$role • $amount'.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryGold, letterSpacing: 1)),
                        const SizedBox(height: 8),
                        Text(months, style: const TextStyle(fontSize: 11, color: AppTheme.grayText)),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CompletedTontineDetailScreen(tontineId: tontineId, tontineName: title),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      foregroundColor: AppTheme.grayText,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      minimumSize: const Size(0, 36),
                    ),
                    child: const Text('ARCHIVES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTontineCard({required String tontineId, required String title, required String amount, required double progress, required String progressText, required String status, required String role, required String info, required IconData infoIcon, required Color statusColor, bool isCompleted = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(width: 6, color: statusColor),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: statusColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Text(status.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor))),
                                  const SizedBox(width: 8),
                                  Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), decoration: BoxDecoration(color: AppTheme.primaryGold.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Text(role.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryGold))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(isCompleted ? 'Total épargné' : 'Mensualité', style: const TextStyle(fontSize: 10, color: AppTheme.grayText)),
                              Text(amount, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.primaryGold)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (!isCompleted) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Progression cycle', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
                            Text('${(progress * 100).toInt()}% • $progressText', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.primaryGold)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(value: progress, backgroundColor: AppTheme.primaryGold.withValues(alpha: 0.1), valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.primaryGold), borderRadius: BorderRadius.circular(5), minHeight: 6),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(infoIcon, size: 14, color: AppTheme.primaryGold),
                            const SizedBox(width: 4),
                            Text(info, style: const TextStyle(fontSize: 11, fontStyle: FontStyle.italic, color: AppTheme.grayText)),
                          ],
                        ),
                      ],
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            if (role == 'Admin') {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => AdminPaymentTrackingScreen(tontineName: title)));
                            } else {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => TontineDetailScreen(tontineId: tontineId, tontineName: title)));
                            }
                          },
                          style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(0, 0), tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                          child: Text(isCompleted ? 'ARCHIVES' : (role == 'Admin' ? 'GÉRER LE GROUPE' : 'VOIR DÉTAILS'), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppTheme.textDark, decoration: TextDecoration.underline, decorationColor: AppTheme.primaryGold, decorationThickness: 2)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }} // end _TontineListScreenState
