import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../theme/app_theme.dart';
import '../../core/providers/tontine_provider.dart';

class DistributionOrderScreen extends StatefulWidget {
  final String tontineId;
  const DistributionOrderScreen({super.key, required this.tontineId});

  @override
  State<DistributionOrderScreen> createState() => _DistributionOrderScreenState();
}

class _DistributionOrderScreenState extends State<DistributionOrderScreen> {
  bool _isManual = true;
  List<dynamic> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final provider = context.read<TontineProvider>();
    await provider.fetchMembers(widget.tontineId);
    if (mounted) {
      setState(() {
        final rawMembers = List<dynamic>.from(provider.members);
        // Sort by position_ordre if exists, else keep original order
        rawMembers.sort((a, b) {
          final posA = a['position_ordre'] as int? ?? 999;
          final posB = b['position_ordre'] as int? ?? 999;
          return posA.compareTo(posB);
        });
        _members = rawMembers;
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
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Symbols.arrow_back, color: AppTheme.textDark),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'Ordre des bénéficiaires',
            style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Toggle Manuel / Automatique
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                height: 50,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  children: [
                    _buildToggleButton('Manuel', _isManual),
                    _buildToggleButton('Automatique', !_isManual),
                  ],
                ),
              ),
            ),
            
            // Info Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.primaryGold.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTheme.primaryGold.withValues(alpha: 0.2)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Symbols.info, size: 16, color: AppTheme.primaryGold),
                  SizedBox(width: 8),
                  Text(
                    'Position 1 = Premier à recevoir',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppTheme.primaryGold),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Reorderable List
            if (_isLoading)
              const Expanded(child: Center(child: CircularProgressIndicator()))
            else
              Expanded(
              child: ReorderableListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _members.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (newIndex > oldIndex) newIndex -= 1;
                    final member = _members.removeAt(oldIndex);
                    _members.insert(newIndex, member);
                  });
                },
                itemBuilder: (context, index) {
                  final member = _members[index];
                  final name = '${member['user_prenom'] ?? ''} ${member['user_nom'] ?? ''}';
                  final role = member['role'] ?? 'Membre';
                  final img = member['user_photo_url'] ?? 'https://i.pravatar.cc/150?u=${member['user_id']}';
                  
                  return Container(
                    key: ValueKey(member['id']),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
                      border: Border.all(color: Colors.black.withValues(alpha: 0.05)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: index == 0 ? AppTheme.primaryGold : Colors.black.withValues(alpha: 0.05),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: TextStyle(
                                color: index == 0 ? Colors.white : Colors.black54,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage(img),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name.trim().isNotEmpty ? name.trim() : 'Utilisateur', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Text(
                                role.toUpperCase(),
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1, color: Colors.black.withValues(alpha: 0.4)),
                              ),
                            ],
                          ),
                        ),
                        ReorderableDragStartListener(
                          index: index,
                          child: const Icon(Symbols.drag_indicator, color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            
            // Save Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (_members.isEmpty) return;
                    
                    final provider = context.read<TontineProvider>();
                    final List<Map<String, dynamic>> orders = [];
                    for (int i = 0; i < _members.length; i++) {
                      orders.add({
                        'membership_id': _members[i]['id'],
                        'position_ordre': i + 1,
                      });
                    }
                    
                    await provider.updateMembershipOrder(widget.tontineId, orders);
                    
                    if (provider.error != null && mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(provider.error!), backgroundColor: Colors.red),
                      );
                    } else if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ordre des bénéficiaires enregistré avec succès')),
                      );
                      Navigator.pop(context);
                    }
                  },
                  icon: const Icon(Symbols.save),
                  label: const Text('ENREGISTRER L\'ORDRE', style: TextStyle(fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    elevation: 8,
                    shadowColor: AppTheme.primaryGold.withValues(alpha: 0.3),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected) {
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _isManual = label == 'Manuel'),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isSelected ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 5)] : null,
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              color: isSelected ? AppTheme.textDark : Colors.black45,
            ),
          ),
        ),
      ),
    );
  }
}
