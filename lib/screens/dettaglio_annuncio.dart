import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../models/annuncio.dart';
import '../services/api_service.dart';

class DettaglioAnnuncioScreen extends StatefulWidget {
  final Annuncio annuncio;

  const DettaglioAnnuncioScreen({super.key, required this.annuncio});

  @override
  State<DettaglioAnnuncioScreen> createState() => _DettaglioAnnuncioScreenState();
}

class _DettaglioAnnuncioScreenState extends State<DettaglioAnnuncioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _cognomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  File? _cvSelezionato;
  String? _nomeFileCv;
  bool _invioInCorso = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _cognomeCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _scegliPdf() async {
    final files = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (files.isNotEmpty && files.single.path != null) {
      setState(() {
        _cvSelezionato = File(files.single.path!);
        _nomeFileCv = files.single.name;
      });
    }
  }

  Future<void> _inviaCandidatura() async {
    if (!_formKey.currentState!.validate()) return;

    if (_cvSelezionato == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Allega il tuo CV in formato PDF')),
      );
      return;
    }

    setState(() => _invioInCorso = true);

    try {
      await ApiService.instance.inviaCandidatura(
        annuncioId: widget.annuncio.id,
        nome: _nomeCtrl.text.trim(),
        cognome: _cognomeCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        cvFile: _cvSelezionato!,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Candidatura inviata con successo!')),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _invioInCorso = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final annuncio = widget.annuncio;

    return Scaffold(
      appBar: AppBar(title: const Text('Dettaglio Annuncio')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- INTESTAZIONE ANNUNCIO ---
            Text(
              annuncio.titolo,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            if (annuncio.aziendaNome.isNotEmpty)
              Text(
                'Azienda: ${annuncio.aziendaNome}',
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            if (annuncio.ral != null) ...[
              const SizedBox(height: 8),
              Chip(
                avatar: const Icon(Icons.euro, size: 18),
                label: Text('RAL: ${annuncio.ral} €'),
              ),
            ],
            const SizedBox(height: 16),
            Text(
              annuncio.descrizione,
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),

            const Divider(height: 40),

            // --- FORM CANDIDATURA ---
            Text(
              'Candidati per questa posizione',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _nomeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Inserisci il nome' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _cognomeCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Cognome',
                      border: OutlineInputBorder(),
                    ),
                    textCapitalization: TextCapitalization.words,
                    validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Inserisci il cognome' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _emailCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Inserisci l\'email';
                      if (!v.contains('@')) return 'Email non valida';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Selettore PDF
                  OutlinedButton.icon(
                    onPressed: _invioInCorso ? null : _scegliPdf,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: Text(
                      _nomeFileCv ?? 'Allega Curriculum (PDF)',
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                    ),
                  ),
                  const SizedBox(height: 24),

                  FilledButton(
                    onPressed: _invioInCorso ? null : _inviaCandidatura,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _invioInCorso
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Text('Invia Candidatura'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}