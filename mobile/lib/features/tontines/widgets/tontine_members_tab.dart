import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import '../../../theme/app_theme.dart';
import '../invite_members_screen.dart';
import '../members_list_screen.dart';
import '../../../core/providers/tontine_provider.dart';
import 'package:provider/provider.dart';

class TontineMembersTab extends StatelessWidget {
  const TontineMembersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Invitation Action
          _buildInviteAction(context),

          const SizedBox(height: 24),

          // Organizer Section
          const Text(
            'ORGANISATEUR',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
              color: AppTheme.emeraldDark,
            ),
          ),
          const SizedBox(height: 12),
          _buildOrganizerCard(),

          const SizedBox(height: 32),

          // Members List Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'MEMBRES (12)',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 2,
                  color: AppTheme.emeraldDark,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.primaryGold.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'ORDRE ALPHABÉTIQUE',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.primaryGold,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  final tontine = context.read<TontineProvider>().currentTontine;
                  if (tontine != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => MembersListScreen(
                          tontineId: tontine.id,
                          tontineNom: tontine.nom,
                        ),
                      ),
                    );
                  }
                },
                child: const Text('VOIR TOUT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primaryGold)),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Members List
          _buildMemberTile(
            name: 'Awa Diallo',
            position: 1,
            status: 'PAYÉ',
            statusColor: AppTheme.emeraldDark,
            isMe: true,
            imageUrl: 'https://i.pravatar.cc/150?u=awa',
          ),
          _buildMemberTile(
            name: 'Babacar Sy',
            position: 2,
            status: 'PAYÉ',
            statusColor: AppTheme.emeraldDark,
            imageUrl: 'https://i.pravatar.cc/150?u=babacar',
          ),
          _buildMemberTile(
            name: 'Fatou Camara',
            position: 3,
            status: 'EN ATTENTE',
            statusColor: Colors.grey,
            imageUrl: 'https://i.pravatar.cc/150?u=fatou',
          ),
          _buildMemberTile(
            name: 'Issa Diop',
            position: 4,
            status: 'PAYÉ',
            statusColor: AppTheme.emeraldDark,
            imageUrl: 'https://i.pravatar.cc/150?u=issa',
          ),
          _buildMemberTile(
            name: 'Mariam Traoré',
            position: 5,
            status: 'EN ATTENTE',
            statusColor: Colors.grey,
            imageUrl: 'https://i.pravatar.cc/150?u=mariam',
          ),

          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildInviteAction(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                const InviteMembersScreen(tontineName: 'Tontine Solaire'),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryGold,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryGold.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(Symbols.person_add, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Inviter de nouveaux membres',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Faites grandir votre cercle Aurum',
                    style: TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                ],
              ),
            ),
            const Icon(Symbols.chevron_right, color: Colors.white70),
          ],
        ),
      ),
    );
  }

  Widget _buildOrganizerCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.05)),
      ),
      child: Column(
        children: [
          Container(
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.emeraldDark,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Stack(
                  children: [
                    const CircleAvatar(
                      radius: 28,
                      backgroundImage: NetworkImage(
                        'https://i.pravatar.cc/150?u=koffi',
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: BoxDecoration(
                          color: AppTheme.primaryGold,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
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
                      const Text(
                        'Koffi Mensah',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark,
                        ),
                      ),
                      Text(
                        'GESTIONNAIRE PRINCIPAL',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textDark.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Symbols.chat, size: 14),
                  label: const Text('CONTACTER'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberTile({
    required String name,
    required int position,
    required String status,
    required Color statusColor,
    bool isMe = false,
    String? imageUrl,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isMe ? AppTheme.primaryGold.withValues(alpha: 0.05) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isMe
              ? AppTheme.primaryGold.withValues(alpha: 0.2)
              : AppTheme.primaryGold.withValues(alpha: 0.05),
        ),
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
            clipBehavior: Clip.none,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundImage: imageUrl != null
                    ? NetworkImage(imageUrl)
                    : null,
              ),
              if (isMe)
                Positioned(
                  top: -4,
                  left: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.emeraldDark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      'MOI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Position #$position',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.textDark.withValues(alpha: 0.4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(10),
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
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Symbols.more_vert, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
