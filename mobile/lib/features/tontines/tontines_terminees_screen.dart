import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../core/providers/tontine_provider.dart';
import '../../core/models/tontine_model.dart';
import '../../theme/app_theme.dart';
import 'completed_tontine_detail_screen.dart';

class TontinesTermineesScreen extends StatefulWidget {
  const TontinesTermineesScreen({super.key});

  @override
  State<TontinesTermineesScreen> createState() => _TontinesTermineesScreenState();
}

class _TontinesTermineesScreenState extends State<TontinesTermineesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TontineProvider>().fetchTontines();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F6), // Background light from HTML
      appBar: AppBar(
        backgroundColor: AppTheme.creamLight,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back, color: AppTheme.emeraldDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Mes Tontines',
          style: TextStyle(color: AppTheme.emeraldDark, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Symbols.search, color: AppTheme.emeraldDark),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Segmented Control (Mockup style)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  _buildTab('Toutes', false),
                  _buildTab('Actives', false),
                  _buildTab('Terminées', true),
                ],
              ),
            ),
          ),
          Expanded(
            child: Consumer<TontineProvider>(
              builder: (context, provider, _) {
                final terminees = provider.tontines.where((t) => t.statut == 'terminee').toList();

                if (provider.isLoading && terminees.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
                }

                if (terminees.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Symbols.assignment_turned_in, size: 64, color: Colors.grey.shade300),
                        const SizedBox(height: 16),
                        const Text('Aucune tontine terminée', style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: terminees.length,
                  itemBuilder: (context, index) {
                    final tontine = terminees[index];
                    return _buildTermineeCard(tontine);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String label, bool isActive) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isActive ? AppTheme.primaryGold : Colors.transparent,
          borderRadius: BorderRadius.circular(25),
          boxShadow: isActive ? [BoxShadow(color: AppTheme.primaryGold.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 4))] : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isActive ? Colors.white : AppTheme.emeraldDark.withValues(alpha: 0.6),
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildTermineeCard(TontineModel tontine) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.1)),
      ),
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  'https://images.unsplash.com/photo-1590073242678-70ee3fc28e8e?q=80&w=500',
                  height: 140,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryGold,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text(
                    'TERMINÉE',
                    style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tontine.nom,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.emeraldDark),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ADMIN • ${tontine.montantCotisation} FCFA',
                            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryGold, letterSpacing: 1),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CompletedTontineDetailScreen(tontineId: tontine.id, tontineName: tontine.nom),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF1F5F9),
                        foregroundColor: const Color(0xFF64748B),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                      ),
                      child: const Text('ARCHIVES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('12/12 mois complétés', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                    Text('100%', style: TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: const LinearProgressIndicator(
                    value: 1.0,
                    backgroundColor: Color(0xFFF1F5F9),
                    color: AppTheme.emeraldDark,
                    minHeight: 8,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
