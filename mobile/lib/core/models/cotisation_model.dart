class CotisationModel {
  final String id;
  final String cycleId;
  final String membershipId;
  final double montant;
  final String statut;
  final String moyenPaiement;
  final String? nomExpediteur;
  final String? prenomExpediteur;
  final String? telephoneExpediteur;
  final DateTime dateCreation;
  final String? userName;
  final String? userPrenom;

  CotisationModel({
    required this.id,
    required this.cycleId,
    required this.membershipId,
    required this.montant,
    required this.statut,
    required this.moyenPaiement,
    this.nomExpediteur,
    this.prenomExpediteur,
    this.telephoneExpediteur,
    required this.dateCreation,
    this.userName,
    this.userPrenom,
  });

  factory CotisationModel.fromJson(Map<String, dynamic> json) {
    return CotisationModel(
      id: json['id'] ?? '',
      cycleId: json['cycle_id'] ?? '',
      membershipId: json['membership_id'] ?? '',
      montant: double.tryParse(json['montant'].toString()) ?? 0.0,
      statut: json['statut'] ?? '',
      moyenPaiement: json['moyen_paiement'] ?? '',
      nomExpediteur: json['nom_expediteur'],
      prenomExpediteur: json['prenom_expediteur'],
      telephoneExpediteur: json['telephone_expediteur'],
      dateCreation: DateTime.tryParse(json['date_creation'] ?? '') ?? DateTime.now(),
      userName: json['nom'], // From JOIN in getCycleCotisations
      userPrenom: json['prenom'],
    );
  }
}
