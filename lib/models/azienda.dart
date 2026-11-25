class Azienda {
  final String id;
  final String nome;
  final String email;
  final String password;

  Azienda({
    required this.id,
    required this.nome,
    required this.email,
    this.password = ''
  });

  factory Azienda.fromJson(Map<String, dynamic> json) {
    return Azienda(
      id: json['id'] as String,
      nome: (json['nome'] as String),
      email: json['email'] as String,
      password: json['password'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'email': email,
      'password': password,
    };
  }
}