import 'package:emad_job_board/models/canditatura.dart';
import 'package:flutter/material.dart';

import '../models/annuncio.dart';
import '../services/api_service.dart';

class DashboardAziendaScreen extends StatefulWidget {
  const DashboardAziendaScreen({super.key});

  @override
  State<DashboardAziendaScreen> createState() => _DashboardAziendaScreenState();
}

class _DashboardAziendaScreenState extends State<DashboardAziendaScreen> {
  late Future<List<Annuncio>> _mieiAnnunciFuture;

  @override
  void initState() {
    super.initState();
    _caricaMieiAnnunci();
  }

  void _caricaMieiAnnunci() {
    final aziendaId = ApiService.instance.aziendaCorrente?.id;
    setState(() {
      _mieiAnnunciFuture = ApiService.instance.getAnnunci(aziendaId: aziendaId);
    });
  }

  Future<int> _getNumeroCandidati(Annuncio annuncio) async {
    List<Candidatura> canditature = await ApiService.instance.getCandidature(annuncio.id);
    return canditature.length;
  }

  void _logout() {
    ApiService.instance.logout();
    Navigator.pop(context);
  }

  Future<void> _mostraDialogNuovoAnnuncio() async {
    final formKey = GlobalKey<FormState>();
    final titoloCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final ralCtrl = TextEditingController();
    bool salvataggio = false;

    await showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Nuovo Annuncio'),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: titoloCtrl,
                    decoration: const InputDecoration(labelText: 'Titolo posizione'),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Obbligatorio' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: descCtrl,
                    decoration: const InputDecoration(labelText: 'Descrizione'),
                    maxLines: 3,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Obbligatorio' : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: ralCtrl,
                    decoration: const InputDecoration(labelText: 'RAL (€) - opzionale'),
                    keyboardType: TextInputType.number,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: salvataggio ? null : () => Navigator.pop(ctx),
              child: const Text('Annulla'),
            ),
            FilledButton(
              onPressed: salvataggio
                  ? null
                  : () async {
                if (!formKey.currentState!.validate()) return;
                setDialogState(() => salvataggio = true);

                try {
                  await ApiService.instance.creaAnnuncio(
                    titolo: titoloCtrl.text.trim(),
                    descrizione: descCtrl.text.trim(),
                    ral: int.tryParse(ralCtrl.text.trim()),
                  );
                  if (ctx.mounted) Navigator.pop(ctx);
                  _caricaMieiAnnunci();
                } catch (e) {
                  setDialogState(() => salvataggio = false);
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                    );
                  }
                }
              },
              child: const Text('Pubblica'),
            ),
          ],
        ),
      ),
    );
  }

  void _mostraCandidature(Annuncio annuncio) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        builder: (_, scrollCtrl) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Candidature: ${annuncio.titolo}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const Divider(height: 24),
              Expanded(
                child: FutureBuilder<List<Candidatura>>(
                  future: ApiService.instance.getCandidature(annuncio.id),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Errore: ${snapshot.error}'));
                    }

                    final lista = snapshot.data ?? [];
                    if (lista.isEmpty) {
                      return const Center(child: Text('Nessuna candidatura ricevuta finora.'));
                    }

                    return ListView.separated(
                      controller: scrollCtrl,
                      itemCount: lista.length,
                      separatorBuilder: (_, __) => const Divider(),
                      itemBuilder: (_, index) {
                        final cand = lista[index];
                        return ListTile(
                          title: Text('${cand.nome} ${cand.cognome}'),
                          subtitle: Text(cand.email),
                          trailing: FilledButton.tonalIcon(
                            onPressed: () async {
                              try {
                                await ApiService.instance.apriCv(cand.cvFileName);
                              } catch (e) {
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Errore apertura PDF: $e')),
                                  );
                                }
                              }
                            },
                            icon: const Icon(Icons.picture_as_pdf, size: 18),
                            label: const Text('Apri CV'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nomeAzienda = ApiService.instance.aziendaCorrente?.nome ?? 'Azienda';

    return Scaffold(
      appBar: AppBar(
        title: Text(nomeAzienda),
        actions: [
          IconButton(
            tooltip: 'Logout',
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _mostraDialogNuovoAnnuncio,
        icon: const Icon(Icons.add),
        label: const Text('Pubblica Annuncio'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _caricaMieiAnnunci(),
        child: FutureBuilder<List<Annuncio>>(
          future: _mieiAnnunciFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(child: Text('Errore: ${snapshot.error}'));
            }

            final annunci = snapshot.data ?? [];
            if (annunci.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Non hai ancora pubblicato annunci.')),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: annunci.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final annuncio = annunci[index];
                return Card(
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      annuncio.titolo,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        annuncio.descrizione,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    trailing: FutureBuilder<int>(
                      future: _getNumeroCandidati(annuncio),
                      builder: (context, snapshot) {
                        final count = snapshot.data;
                        final labelText = count == null
                            ? '...'
                            : '$count ${count == 1 ? 'Candidato' : 'Candidati'}';

                        return Chip(
                          avatar: const Icon(Icons.people, size: 16),
                          label: Text(labelText),
                        );
                      },
                    ),
                    onTap: () => _mostraCandidature(annuncio),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}