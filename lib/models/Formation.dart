class TypeFormation {
  final int id;
  final String nom;
  final List<Formation> formations;

  TypeFormation(
      {required this.id, required this.nom, required this.formations});

  factory TypeFormation.fromJson(Map<String, dynamic> json) {
    return TypeFormation(
      id: json['id'],
      nom: json['nom'],
      formations: (json['formations'] as List)
          .map((formation) => Formation.fromJson(formation))
          .toList(),
    );
  }
}

class Formation {
  final int id;
  final String nom;
  final String description;
  final String coutMin;
  final bool modePaiementTranches;

  Formation({
    required this.id,
    required this.nom,
    required this.description,
    required this.coutMin,
    required this.modePaiementTranches,
  });

  factory Formation.fromJson(Map<String, dynamic> json) {
    return Formation(
      id: json['id'],
      nom: json['nom'],
      description: json['description'],
      coutMin: json['cout_min'],
      modePaiementTranches: json['mode_paiement_tranches'] ?? false,
    );
  }
}
