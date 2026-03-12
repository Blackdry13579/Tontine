import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/tontine_provider.dart';
import '../../../theme/app_theme.dart';

class ReorderMembersSheet extends StatefulWidget {
  final String tontineId;

  const ReorderMembersSheet({super.key, required this.tontineId});

  @override
  State<ReorderMembersSheet> createState() => _ReorderMembersSheetState();
}

class _ReorderMembersSheetState extends State<ReorderMembersSheet> {
  List<dynamic> _members = [];
  bool _isLoading = true;
  bool _isSaving = false;

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
        _members = List.from(provider.members);
        _isLoading = false;
      });
    }
  }

  Future<void> _saveOrder() async {
    setState(() => _isSaving = true);
    try {
      final orders = _members.asMap().entries.map((e) {
        return {
          'user_id': e.value['user_id'],
          'ordre_passage': e.key + 1,
        };
      }).toList();

      await context.read<TontineProvider>().updateMembershipOrder(widget.tontineId, orders);
      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ordre mis à jour avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24),
      decoration: const BoxDecoration(
        color: AppTheme.creamLight,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Modifier l\'ordre des membres',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.emeraldDark,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Maintenez et glissez pour réorganiser.',
              style: TextStyle(fontSize: 12, color: AppTheme.grayText),
            ),
          ),
          const SizedBox(height: 16),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: CircularProgressIndicator(color: AppTheme.primaryGold)),
            )
          else if (_members.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32.0),
              child: Center(child: Text('Aucun membre trouvé')),
            )
          else
            Flexible(
              child: ReorderableListView.builder(
                shrinkWrap: true,
                itemCount: _members.length,
                onReorder: (oldIndex, newIndex) {
                  setState(() {
                    if (oldIndex < newIndex) {
                      newIndex -= 1;
                    }
                    final item = _members.removeAt(oldIndex);
                    _members.insert(newIndex, item);
                  });
                },
                itemBuilder: (context, index) {
                  final member = _members[index];
                  final nom = member['nom'] ?? '';
                  final prenom = member['prenom'] ?? 'Membre';
                  return ListTile(
                    key: ValueKey(member['user_id']),
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.primaryGold.withValues(alpha: 0.2),
                      child: Text('${index + 1}', style: const TextStyle(color: AppTheme.emeraldDark, fontWeight: FontWeight.bold)),
                    ),
                    title: Text('$prenom $nom', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textDark)),
                    trailing: const Icon(Icons.drag_handle, color: Colors.grey),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: _isSaving ? null : () => Navigator.pop(context),
                    child: const Text('ANNULER', style: TextStyle(color: AppTheme.grayText)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading || _isSaving ? null : _saveOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryGold,
                      foregroundColor: Colors.white,
                    ),
                    child: _isSaving
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                        : const Text('ENREGISTRER'),
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
