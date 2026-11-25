import 'dart:io';

import 'package:emad_job_board/utils/board_style.dart';
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
      appBar: AppBar(title: const Text('Dettaglio Offerta')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // --- FOGLIETTO DELL'OFFERTA ---
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                  decoration: BoxDecoration(
                    color: BoardStyle.noteColorFor(annuncio.id),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: Colors.black12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 6,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        annuncio.titolo,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF222222),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 12,
                        runSpacing: 8,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          if (annuncio.aziendaNome.isNotEmpty)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.apartment, size: 16, color: Color(0xFF2B5943)),
                                const SizedBox(width: 4),
                                Text(
                                  annuncio.aziendaNome,
                                  style: const TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF2B5943),
                                  ),
                                ),
                              ],
                            ),
                          if (annuncio.ral != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFF2B5943).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'RAL: ${annuncio.ral} €',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF2B5943),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const Divider(height: 28),
                      Text(
                        annuncio.descrizione,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: -7,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: BoardStyle.pinColorFor(annuncio.id),
                      shape: BoxShape.circle,
                      boxShadow: const [
                        BoxShadow(color: Colors.black38, blurRadius: 3, offset: Offset(1, 2)),
                      ],
                      border: Border.all(color: Colors.white70, width: 1.5),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // --- SCHEDA CANDIDATURA ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.black12),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'Invia la tua candidatura',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nomeCtrl,
                      decoration: const InputDecoration(
                        labelText: 'Nome',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Color(0xFFFAFAFA),
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
                        filled: true,
                        fillColor: Color(0xFFFAFAFA),
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
                        filled: true,
                        fillColor: Color(0xFFFAFAFA),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Inserisci l\'email';
                        if (!v.contains('@')) return 'Email non valida';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
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
                    const SizedBox(height: 20),
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
            ),
          ],
        ),
      ),
    );
  }
}