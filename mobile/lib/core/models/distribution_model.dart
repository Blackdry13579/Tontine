class DistributionModel {
  final String id;
  final String cycleId;
  final String membershipId;
  final double montant;
  final String statut; // 'planifiee', 'en_cours', 'effectuee', 'annulle'
  final String? moyenDistribution;
  final String? referenceTransaction;
  final DateTime? dateDistribution;
  final DateTime dateCreation;
  final String? nomBeneficiaire;
  final String? prenomBeneficiaire;

  DistributionModel({
    required this.id,
    required this.cycleId,
    required this.membershipId,
    required this.montant,
    required this.statut,
    this.moyenDistribution,
    this.referenceTransaction,
    this.dateDistribution,
    required this.dateCreation,
    this.nomBeneficiaire,
    this.prenomBeneficiaire,
  });

  factory DistributionModel.fromJson(Map<String, dynamic> json) {
    return DistributionModel(
      id: json['id'] ?? '',
      cycleId: json['cycle_id'] ?? '',
      membershipId: json['membership_id'] ?? '',
      montant: double.tryParse(json['montant']?.toString() ?? '0') ?? 0.0,
      statut: json['statut'] ?? 'planifiee',
      moyenDistribution: json['moyen_distribution'],
      referenceTransaction: json['reference_transaction'],
      dateDistribution: json['date_distribution'] != null 
          ? DateTime.tryParse(json['date_distribution'].toString()) 
          : null,
      dateCreation: DateTime.tryParse(json['date_creation']?.toString() ?? '') ?? DateTime.now(),
      nomBeneficiaire: json['nom'],
      prenomBeneficiaire: json['prenom'],
    );
  }

  String get beneficiaryName => '${prenomBeneficiaire ?? ""} ${nomBeneficiaire ?? ""}'.trim();
}
