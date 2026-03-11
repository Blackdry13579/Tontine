class TontineModel {
  final String id;
  final String nom;
  final String? description;
  final double montantCotisation;
  final String frequence;
  final int nombreMembresMax;
  final int nombreMembresActuels;
  final String statut;
  final String? codeInvitation;
  final DateTime? dateDebut;
  final bool penalitesActivees;
  final double montantPenalite;
  final String organisateurId;
  final String? currentCycleId;

  TontineModel({
    required this.id,
    required this.nom,
    this.description,
    required this.montantCotisation,
    required this.frequence,
    required this.nombreMembresMax,
    this.nombreMembresActuels = 0,
    required this.statut,
    this.codeInvitation,
    this.dateDebut,
    this.penalitesActivees = false,
    this.montantPenalite = 0.0,
    required this.organisateurId,
    this.currentCycleId,
  });

  factory TontineModel.fromJson(Map<String, dynamic> json) {
    return TontineModel(
      id: json['id'] ?? '',
      nom: json['nom'] ?? '',
      description: json['description'],
      montantCotisation: double.tryParse(json['montant_cotisation']?.toString() ?? '0') ?? 0.0,
      frequence: json['frequence'] ?? '',
      nombreMembresMax: json['nombre_membres_max'] ?? 0,
      nombreMembresActuels: json['nombre_membres_actuels'] ?? 0,
      statut: json['statut'] ?? 'en_attente',
      codeInvitation: json['code_invitation'],
      dateDebut: json['date_debut'] != null ? DateTime.tryParse(json['date_debut'].toString()) : null,
      penalitesActivees: json['penalites_activees'] ?? false,
      montantPenalite: double.tryParse(json['montant_penalite']?.toString() ?? '0') ?? 0.0,
      organisateurId: json['organisateur_id'] ?? '',
      currentCycleId: json['current_cycle_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nom': nom,
      'description': description,
      'montant_cotisation': montantCotisation,
      'frequence': frequence,
      'nombre_membres_max': nombreMembresMax,
      'date_debut': dateDebut?.toIso8601String(),
      'penalites_activees': penalitesActivees,
      'montant_penalite': montantPenalite,
    };
  }
}
