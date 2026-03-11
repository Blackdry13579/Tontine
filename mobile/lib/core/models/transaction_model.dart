class TransactionModel {
  final String id;
  final String? cycleId;
  final String? tontineId;
  final String? tontineNom;
  final double montant;
  final String statut; // 'en_attente', 'valide', 'rejete'
  final DateTime dateCreation;
  final String? motifRejet;
  final String? preuvePaiementUrl;
  final String type; // 'cotisation', 'distribution'

  TransactionModel({
    required this.id,
    this.cycleId,
    this.tontineId,
    this.tontineNom,
    required this.montant,
    required this.statut,
    required this.dateCreation,
    this.motifRejet,
    this.preuvePaiementUrl,
    required this.type,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    try {
      return TransactionModel(
        id: json['id']?.toString() ?? '',
        cycleId: json['cycle_id']?.toString(),
        tontineId: json['tontine_id']?.toString(),
        tontineNom: json['tontine_nom']?.toString(),
        montant: double.tryParse(json['montant']?.toString() ?? '0') ?? 0.0,
        statut: json['statut']?.toString() ?? 'en_attente',
        dateCreation: json['created_at'] != null 
            ? DateTime.parse(json['created_at'].toString()) 
            : (json['date_creation'] != null 
                ? DateTime.parse(json['date_creation'].toString()) 
                : DateTime.now()),
        motifRejet: json['motif_rejet']?.toString(),
        preuvePaiementUrl: json['preuve_paiement_url']?.toString(),
        type: json['type']?.toString() ?? 'cotisation',
      );
    } catch (e) {
      // Return a safe default instead of crashing the whole screen
      return TransactionModel(
        id: 'error',
        montant: 0.0,
        statut: 'erreur',
        dateCreation: DateTime.now(),
        type: 'inconnu',
      );
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'cycle_id': cycleId,
      'montant': montant,
      'statut': statut,
    };
  }
}
