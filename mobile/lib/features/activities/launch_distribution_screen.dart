import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../core/providers/distribution_provider.dart';
import '../../core/providers/tontine_provider.dart';
import '../../core/models/tontine_model.dart';
import '../../theme/app_theme.dart';

class LaunchDistributionScreen extends StatefulWidget {
  final TontineModel tontine;

  const LaunchDistributionScreen({super.key, required this.tontine});

  @override
  State<LaunchDistributionScreen> createState() => _LaunchDistributionScreenState();
}

class _LaunchDistributionScreenState extends State<LaunchDistributionScreen> {
  String? _selectedMembershipId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TontineProvider>().fetchMembers(widget.tontine.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lancer Distribution'),
        backgroundColor: AppTheme.emeraldDark,
        foregroundColor: Colors.white,
      ),
      body: Consumer<TontineProvider>(
        builder: (context, tontineProvider, _) {
          if (tontineProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final members = tontineProvider.members;
          final totalAmount = widget.tontine.montantCotisation * widget.tontine.nombreMembresActuels;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoCard(totalAmount),
                const SizedBox(height: 24),
                const Text(
                  'Sélectionner le bénéficiaire',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.emeraldDark),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      // Note: member object structure depends on API response, assuming it has id, nom, prenom
                      final memberId = member['id'];
                      final isSelected = _selectedMembershipId == memberId;

                      return GestureDetector(
                        onTap: () => setState(() => _selectedMembershipId = memberId),
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primaryGold.withValues(alpha: 0.1) : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? AppTheme.primaryGold : Colors.grey.withValues(alpha: 0.2),
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: AppTheme.emeraldDark,
                                child: Text(member['prenom'][0] + member['nom'][0], style: const TextStyle(color: Colors.white)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('${member['prenom']} ${member['nom']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                    Text(member['telephone'] ?? ''),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(Symbols.check_circle, color: AppTheme.primaryGold),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedMembershipId == null ? null : _handleLaunch,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.emeraldDark,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('CONFIRMER LE VERSEMENT', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoCard(double amount) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.emeraldDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('MONTANT TOTAL A DISTRIBUER', style: TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 8),
              Text('$amount FCFA', style: const TextStyle(color: AppTheme.primaryGold, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          ),
          const Icon(Symbols.payments, color: AppTheme.primaryGold, size: 48),
        ],
      ),
    );
  }

  Future<void> _handleLaunch() async {
    final provider = context.read<DistributionProvider>();
    final cycleId = widget.tontine.currentCycleId;

    if (cycleId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Erreur: Aucun cycle actif trouvé')));
      return;
    }

    final data = {
      'cycle_id': cycleId,
      'membership_id': _selectedMembershipId,
      'montant': widget.tontine.montantCotisation * widget.tontine.nombreMembresActuels,
      'moyen_distribution': 'transfert_interne',
    };

    await provider.triggerDistribution(data);

    if (!mounted) return;
    if (provider.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(provider.error!)));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Distribution effectuée avec succès !')));
      Navigator.pop(context);
    }
  }
}
