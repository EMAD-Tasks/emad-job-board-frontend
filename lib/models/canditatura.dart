class Candidatura {
  final String id;
  final String annuncioId;
  final String nome;
  final String cognome;
  final String email;
  final String cvFileName;

  Candidatura({
    required this.id,
    required this.annuncioId,
    required this.nome,
    required this.cognome,
    required this.email,
    required this.cvFileName,
  });

  factory Candidatura.fromJson(Map<String, dynamic> json) {
    return Candidatura(
      id: json['id'] as String,
      annuncioId: json['annuncioId'] as String,
      nome: json['nome'] as String,
      cognome: json['cognome'] as String,
      email: json['email'] as String,
      cvFileName: json['cvFileName'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'annuncioId': annuncioId,
      'nome': nome,
      'cognome': cognome,
      'email': email,
      'cvFileName': cvFileName,
    };
  }
}