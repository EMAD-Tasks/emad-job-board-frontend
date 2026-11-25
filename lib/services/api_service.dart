import 'dart:convert';
import 'dart:io';

import 'package:emad_job_board/models/canditatura.dart';
import 'package:emad_job_board/models/annuncio.dart';
import 'package:emad_job_board/models/azienda.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  // Usa 10.0.2.2 per emulatore Android, oppure l'IP locale del PC (es. 192.168.1.15) su smartphone fisico
  static const String baseUrl = 'http://10.0.2.2:8080';

  Azienda? aziendaCorrente;
  bool get isLoggedIn => aziendaCorrente != null;

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  // REGISTRAZIONE
  Future<void> register({
    required String nome,
    required String email,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: _headers,
      body: jsonEncode({'nome': nome, 'email': email, 'password': password}),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode != 201) {
      throw Exception(data['error'] ?? 'Errore durante la registrazione');
    }
    aziendaCorrente = Azienda.fromJson(data);
  }

  // LOGIN
  Future<void> login({required String email, required String password}) async {
    final res = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = jsonDecode(res.body);
    if (res.statusCode != 200) {
      throw Exception(data['error'] ?? 'Credenziali non valide');
    }
    aziendaCorrente = Azienda.fromJson(data);
  }

  // LOGOUT
  void logout() {
    aziendaCorrente = null;
  }

  // LISTA ANNUNCI (tutti o filtrati per azienda)
  Future<List<Annuncio>> getAnnunci({String? aziendaId}) async {
    final uri = (aziendaId != null && aziendaId.isNotEmpty)
        ? Uri.parse('$baseUrl/annunci?aziendaId=$aziendaId')
        : Uri.parse('$baseUrl/annunci');

    final res = await http.get(uri);
    if (res.statusCode != 200) {
      throw Exception('Impossibile caricare gli annunci');
    }

    final List<dynamic> list = jsonDecode(res.body);
    return list.map((e) => Annuncio.fromJson(e as Map<String, dynamic>)).toList();
  }

  // PUBBLICA ANNUNCIO
  Future<void> creaAnnuncio({
    required String titolo,
    required String descrizione,
    int? ral,
  }) async {
    final azienda = aziendaCorrente;
    if (azienda == null) throw Exception('Devi effettuare il login');

    final res = await http.post(
      Uri.parse('$baseUrl/annunci'),
      headers: _headers,
      body: jsonEncode({
        'aziendaId': azienda.id,
        'titolo': titolo,
        'descrizione': descrizione,
        'ral': ral,
      }),
    );

    if (res.statusCode != 201) {
      final data = jsonDecode(res.body);
      throw Exception(data['error'] ?? 'Errore nella pubblicazione');
    }
  }

  // INVIA CANDIDATURA CON PDF
  Future<void> inviaCandidatura({
    required String annuncioId,
    required String nome,
    required String cognome,
    required String email,
    required File cvFile,
  }) async {
    final bytes = await cvFile.readAsBytes();
    final cvBase64 = base64Encode(bytes);

    final res = await http.post(
      Uri.parse('$baseUrl/candidature'),
      headers: _headers,
      body: jsonEncode({
        'annuncioId': annuncioId,
        'nome': nome,
        'cognome': cognome,
        'email': email,
        'cvBase64': cvBase64,
      }),
    );

    if (res.statusCode != 201) {
      final data = jsonDecode(res.body);
      throw Exception(data['error'] ?? 'Errore durante l\'invio della candidatura');
    }
  }

  // CANDIDATURE RICEVUTE PER UN ANNUNCIO
  Future<List<Candidatura>> getCandidature(String annuncioId) async {
    final res = await http.get(Uri.parse('$baseUrl/annunci/$annuncioId/candidature'));
    if (res.statusCode != 200) {
      throw Exception('Impossibile caricare le candidature');
    }

    final List<dynamic> list = jsonDecode(res.body);
    return list.map((e) => Candidatura.fromJson(e as Map<String, dynamic>)).toList();
  }

  // SCARICA E APRI IL PDF DEL CV
  Future<void> apriCv(String fileName) async {
    final res = await http.get(Uri.parse('$baseUrl/uploads/$fileName'));
    if (res.statusCode != 200) {
      throw Exception('Impossibile scaricare il curriculum');
    }

    final tempDir = await getTemporaryDirectory();
    final localFile = File('${tempDir.path}/$fileName');
    await localFile.writeAsBytes(res.bodyBytes);
    await OpenFilex.open(localFile.path);
  }
}