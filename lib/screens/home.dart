import 'package:emad_job_board/screens/dashboard_azienda.dart';
import 'package:flutter/material.dart';

import '../models/annuncio.dart';
import '../services/api_service.dart';
import 'dettaglio_annuncio.dart';
import 'auth_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Annuncio>> _annunciFuture;

  @override
  void initState() {
    super.initState();
    _caricaAnnunci();
  }

  void _caricaAnnunci() {
    setState(() {
      _annunciFuture = ApiService.instance.getAnnunci();
    });
  }

  Future<void> _apriAreaAzienda() async {
    // Scommenta questo blocco al prossimo passo quando aggiungeremo AuthScreen e DashboardAziendaScreen:
    final destinazione = ApiService.instance.isLoggedIn
        ? const DashboardAziendaScreen()
        : const AuthScreen();

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => destinazione),
    );
    _caricaAnnunci(); // Ricarica al rientro nel caso siano stati pubblicati nuovi annunci
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Area Azienda: schermate in arrivo al prossimo passo')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Offerte di Lavoro'),
        actions: [
          TextButton.icon(
            onPressed: _apriAreaAzienda,
            icon: const Icon(Icons.business),
            label: Text(
              ApiService.instance.isLoggedIn ? 'Area Azienda' : 'Accesso Azienda',
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _caricaAnnunci(),
        child: FutureBuilder<List<Annuncio>>(
          future: _annunciFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const SizedBox(height: 80),
                  const Icon(Icons.wifi_off, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'Errore di connessione al server:\n${snapshot.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: FilledButton(
                      onPressed: _caricaAnnunci,
                      child: const Text('Riprova'),
                    ),
                  ),
                ],
              );
            }

            final annunci = snapshot.data ?? [];
            if (annunci.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Nessun annuncio pubblicato al momento.')),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: annunci.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final annuncio = annunci[index];
                return Card(
                  elevation: 1,
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    title: Text(
                      annuncio.titolo,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (annuncio.aziendaNome.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            annuncio.aziendaNome,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Text(
                          annuncio.descrizione,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (annuncio.ral != null) ...[
                          const SizedBox(height: 8),
                          Chip(
                            label: Text('RAL: ${annuncio.ral} €'),
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ],
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DettaglioAnnuncioScreen(annuncio: annuncio),
                        ),
                      );
                    },
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