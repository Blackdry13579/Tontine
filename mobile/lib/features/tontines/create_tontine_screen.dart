import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:provider/provider.dart';
import '../../core/providers/tontine_provider.dart';
import '../../core/models/tontine_model.dart';
import '../../theme/app_theme.dart';

class CreateTontineScreen extends StatefulWidget {
  final TontineModel? tontine;
  const CreateTontineScreen({super.key, this.tontine});

  @override
  State<CreateTontineScreen> createState() => _CreateTontineScreenState();
}

class _CreateTontineScreenState extends State<CreateTontineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _montantController = TextEditingController();
  final _membresController = TextEditingController();
  final _penaliteController = TextEditingController();

  String _frequence = 'mensuelle';
  DateTime _dateDebut = DateTime.now();
  bool _penalitesActivees = false;

  @override
  void initState() {
    super.initState();
    if (widget.tontine != null) {
      _nomController.text = widget.tontine!.nom;
      _descriptionController.text = widget.tontine!.description ?? '';
      _montantController.text = widget.tontine!.montantCotisation.toInt().toString();
      _membresController.text = widget.tontine!.nombreMembresMax.toString();
      _frequence = widget.tontine!.frequence;
      _dateDebut = widget.tontine!.dateDebut ?? DateTime.now();
      _penalitesActivees = widget.tontine!.penalitesActivees;
      _penaliteController.text = widget.tontine!.montantPenalite.toInt().toString();
    }
  }

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _montantController.dispose();
    _membresController.dispose();
    _penaliteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dateDebut,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryGold,
              onPrimary: Colors.white,
              onSurface: AppTheme.emeraldDark,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _dateDebut) {
      setState(() {
        _dateDebut = picked;
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<TontineProvider>();
    
    final data = {
      'nom': _nomController.text.trim(),
      'description': _descriptionController.text.trim(),
      'montant_cotisation': double.parse(_montantController.text.trim()),
      'frequence': _frequence,
      'nombre_membres_max': int.parse(_membresController.text.trim()),
      'date_debut': _dateDebut.toIso8601String(),
      'penalites_activees': _penalitesActivees,
      'montant_penalite': _penalitesActivees ? double.parse(_penaliteController.text.trim()) : 0.0,
    };

    if (widget.tontine != null) {
      await provider.updateTontine(widget.tontine!.id, data);
    } else {
      final newTontine = TontineModel(
        id: '',
        nom: data['nom'] as String,
        description: data['description'] as String,
        montantCotisation: data['montant_cotisation'] as double,
        frequence: data['frequence'] as String,
        nombreMembresMax: data['nombre_membres_max'] as int,
        statut: 'en_attente',
        dateDebut: _dateDebut,
        penalitesActivees: _penalitesActivees,
        montantPenalite: data['montant_penalite'] as double,
        organisateurId: '',
      );
      await provider.createTontine(newTontine);
    }

    if (mounted) {
      if (provider.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.error!), backgroundColor: Colors.red),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.tontine != null ? 'Tontine mise à jour !' : 'Tontine créée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.creamLight,
      appBar: AppBar(
        title: Text(widget.tontine != null ? 'MODIFIER LA TONTINE' : 'CRÉER UNE TONTINE', 
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: AppTheme.emeraldDark,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle('INFORMATIONS GÉNÉRALES'),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _nomController,
                  label: 'Nom de la tontine',
                  hint: 'Ex: Tontine Solaire 2024',
                  icon: Symbols.edit,
                  validator: (v) => v == null || v.isEmpty ? 'Champ requis' : null,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _descriptionController,
                  label: 'Description (Optionnel)',
                  hint: 'Objectif de la tontine...',
                  icon: Symbols.description,
                  maxLines: 3,
                ),
                
                const SizedBox(height: 32),
                _buildSectionTitle('MODALITÉS FINANCIÈRES'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _montantController,
                        label: 'Cotisation (FCFA)',
                        hint: '10000',
                        icon: Symbols.payments,
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDropdownField(
                        label: 'Fréquence',
                        value: _frequence,
                        items: const ['mensuelle', 'hebdomadaire', 'trimestrielle'],
                        onChanged: (v) => setState(() => _frequence = v!),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                _buildSectionTitle('ROULEMENT & DATES'),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _membresController,
                        label: 'Membres Max',
                        hint: '12',
                        icon: Symbols.groups,
                        keyboardType: TextInputType.number,
                        validator: (v) => v == null || v.isEmpty ? 'Requis' : null,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _buildDatePickerField(),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                _buildSectionTitle('PÉNALITÉS'),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Activer les pénalités de retard', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.emeraldDark)),
                  value: _penalitesActivees,
                  activeThumbColor: AppTheme.primaryGold,
                  onChanged: (v) => setState(() => _penalitesActivees = v),
                ),
                if (_penalitesActivees) 
                  _buildTextField(
                    controller: _penaliteController,
                    label: 'Montant de la pénalité (FCFA)',
                    hint: '500',
                    icon: Symbols.warning,
                    keyboardType: TextInputType.number,
                  ),
                
                const SizedBox(height: 48),
                Consumer<TontineProvider>(
                  builder: (context, provider, _) {
                    return SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: provider.isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.emeraldDark,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        child: provider.isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : Text(widget.tontine != null ? 'ENREGISTRER LES MODIFICATIONS' : 'CRÉER LA TONTINE', 
                                style: const TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppTheme.primaryGold,
        letterSpacing: 1.5,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppTheme.grayText)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: AppTheme.emeraldDark.withValues(alpha: 0.5)),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppTheme.grayText)),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Symbols.expand_more, color: AppTheme.emeraldDark),
              items: items.map((String item) {
                return DropdownMenuItem(value: item, child: Text(item, style: const TextStyle(fontSize: 14)));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDatePickerField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Date de début', style: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, color: AppTheme.grayText)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () => _selectDate(context),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Symbols.calendar_today, size: 20, color: AppTheme.emeraldDark),
                const SizedBox(width: 8),
                Text(
                  '${_dateDebut.day}/${_dateDebut.month}/${_dateDebut.year}',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
