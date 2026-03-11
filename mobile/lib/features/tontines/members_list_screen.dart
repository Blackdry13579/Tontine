import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../core/models/user_model.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/tontine_provider.dart';

class MembersListScreen extends StatefulWidget {
  final String tontineId;
  final String? tontineNom;
  
  const MembersListScreen({
    super.key,
    required this.tontineId,
    this.tontineNom,
  });

  @override
  State<MembersListScreen> createState() => _MembersListScreenState();
}

class _MembersListScreenState extends State<MembersListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TontineProvider>().fetchMembers(widget.tontineId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamLight, // '#F5F0E1' equivalent
      appBar: AppBar(
        title: Text(
          'Membres du groupe',
          style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark),
        ),
        backgroundColor: AppTheme.creamLight.withValues(alpha: 0.95),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Symbols.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Symbols.info, color: AppTheme.textDark),
            onPressed: () {}, // Tooltip/Info
          ),
        ],
      ),
      body: Consumer2<TontineProvider, AuthProvider>(
        builder: (context, tontineProvider, authProvider, _) {
          if (tontineProvider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppTheme.primaryGold));
          }

          final members = tontineProvider.members;
          final organizer = members.firstWhere(
            (m) => m['role'] == 'organisateur',
            orElse: () => <String, dynamic>{},
          );
          final participants = members.where((m) => m['role'] != 'organisateur').toList();
          final currentUserPhone = authProvider.user?.telephone;

          return RefreshIndicator(
            onRefresh: () => tontineProvider.fetchMembers(widget.tontineId),
            color: AppTheme.primaryGold,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              children: [
                // Organisateur Header
                if (organizer.isNotEmpty) ...[
                  const Text(
                    'ORGANISATEUR',
                    style: TextStyle(
                      color: AppTheme.emeraldDark,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildOrganizerCard(organizer, currentUserPhone),
                  const SizedBox(height: 32),
                ],

                // Participants List
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'MEMBRES (${participants.length})',
                      style: const TextStyle(
                        color: AppTheme.emeraldDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryGold.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'ORDRE ALPHABÉTIQUE',
                        style: TextStyle(
                          color: AppTheme.primaryGold,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...participants.asMap().entries.map((entry) {
                  return _buildMemberCard(entry.value, entry.key + 1, currentUserPhone);
                }),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrganizerCard(Map<String, dynamic> organizer, String? currentUserId) {
    final String nomComplet = '${organizer['prenom'] ?? ''} ${organizer['nom'] ?? 'Membre'}';
    final bool isMe = organizer['telephone'] == currentUserId;

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(height: 8, width: double.infinity, color: AppTheme.emeraldDark),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Stack(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${organizer['user_id']}'),
                          backgroundColor: Colors.grey.shade200,
                        ),
                        if (isMe)
                          Positioned(
                            top: -4,
                            left: -4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.emeraldDark,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text('MOI', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nomComplet,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'GESTIONNAIRE PRINCIPAL',
                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textDark.withValues(alpha: 0.5)),
                        ),
                      ],
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Symbols.chat, size: 16),
                  label: const Text('CONTACTER', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildMemberCard(Map<String, dynamic> member, int position, String? currentUserId) {
    final String nomComplet = '${member['prenom'] ?? ''} ${member['nom'] ?? 'Membre'}';
    final bool isMe = member['telephone'] == currentUserId;
    
    // Simulation du statut depuis la maquette: on se base grossièrement sur le nom pour l'exemple, ou sur des données réelles
    // La DB backend n'a pas encoré "statut_paiement_cycle_courant" direct. 
    final bool isPaid = member['statut'] == 'actif'; // Si on a un fallback
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMe ? AppTheme.primaryGold.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isMe ? AppTheme.primaryGold.withValues(alpha: 0.2) : AppTheme.primaryGold.withValues(alpha: 0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?u=${member['user_id']}'),
                  ),
                  if (isMe)
                    Positioned(
                      top: -4,
                      left: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.emeraldDark,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('MOI', style: TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nomComplet,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textDark),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        'Position #$position',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppTheme.textDark.withValues(alpha: 0.4)),
                      ),
                      const SizedBox(width: 8),
                      // Badge Payé/En attente
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isPaid ? AppTheme.emeraldDark.withValues(alpha: 0.1) : Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          isPaid ? 'PAYÉ' : 'EN ATTENTE',
                          style: TextStyle(
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                            color: isPaid ? AppTheme.emeraldDark : Colors.grey.shade600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          IconButton(
            icon: const Icon(Symbols.more_vert, color: Colors.black26),
            onPressed: () {},
          )
        ],
      ),
    );
  }
}
