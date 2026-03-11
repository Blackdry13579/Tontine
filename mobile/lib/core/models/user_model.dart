class UserModel {
  final String id;
  final String telephone;
  final String? nom;
  final String? prenom;
  final String? email;
  final String? photoUrl;
  final String role;
  final String? roleSysteme;

  UserModel({
    required this.id,
    required this.telephone,
    this.nom,
    this.prenom,
    this.email,
    this.photoUrl,
    required this.role,
    this.roleSysteme,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      telephone: json['telephone'] ?? '',
      nom: json['nom'],
      prenom: json['prenom'],
      email: json['email'],
      photoUrl: json['photo_url'],
      role: json['role'] ?? 'membre',
      roleSysteme: json['role_systeme'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'telephone': telephone,
      'nom': nom,
      'prenom': prenom,
      'email': email,
      'photo_url': photoUrl,
      'role': role,
      'role_systeme': roleSysteme,
    };
  }
}
