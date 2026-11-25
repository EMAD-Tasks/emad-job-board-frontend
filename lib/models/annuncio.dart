class Annuncio {
  final String id;
  final String aziendaId;
  final String aziendaNome;
  final String titolo;
  final String descrizione;
  final int? ral;

  Annuncio({
    required this.id,
    required this.aziendaId,
    required this.aziendaNome,
    required this.titolo,
    required this.descrizione,
    this.ral,
  });

  factory Annuncio.fromJson(Map<String, dynamic> json) {
    return Annuncio(
      id: json['id'] as String,
      aziendaId: json['aziendaId'] as String,
      aziendaNome: (json['aziendaNome'] as String),
      titolo: json['titolo'] as String,
      descrizione: json['descrizione'] as String,
      ral: json['ral'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'aziendaId': aziendaId,
      'aziendaNome': aziendaNome,
      'titolo': titolo,
      'descrizione': descrizione,
      'ral': ral,
    };
  }
}