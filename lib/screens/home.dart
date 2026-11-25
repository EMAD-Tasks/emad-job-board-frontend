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
    _caricaAnnunci();
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(Icons.push_pin, size: 20),
            SizedBox(width: 8),
            Text('Bacheca Annunci', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilledButton.tonalIcon(
              onPressed: _apriAreaAzienda,
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.business, size: 18),
              label: Text(
                ApiService.instance.isLoggedIn ? 'Area Azienda' : 'Aziende',
              ),
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
                  const Icon(Icons.wifi_off, size: 48, color: Colors.brown),
                  const SizedBox(height: 16),
                  Text(
                    'Impossibile raggiungere la bacheca:\n${snapshot.error}',
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
                  Center(
                    child: Text(
                      'La bacheca è ancora vuota.',
                      style: TextStyle(fontSize: 16, color: Colors.brown),
                    ),
                  ),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 24),
              itemCount: annunci.length,
              separatorBuilder: (_, __) => const SizedBox(height: 18),
              itemBuilder: (context, index) {
                final annuncio = annunci[index];
                return _AnnuncioPinCard(
                  annuncio: annuncio,
                  index: index,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DettaglioAnnuncioScreen(annuncio: annuncio),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _AnnuncioPinCard extends StatelessWidget {
  final Annuncio annuncio;
  final int index;
  final VoidCallback onTap;

  const _AnnuncioPinCard({
    required this.annuncio,
    required this.index,
    required this.onTap,
  });

  static const _noteColors = [
    Color(0xFFFFFDF7), // Carta avorio
    Color(0xFFFFF8DC), // Post-it crema
    Color(0xFFF4F9F4), // Carta salvia chiarissima
  ];

  static const _pinColors = [
    Color(0xFFD94E4E), // Puntina rossa
    Color(0xFF2B5943), // Puntina verde
    Color(0xFFD98A2B), // Puntina ambra
  ];

  @override
  Widget build(BuildContext context) {
    final bgColor = _noteColors[index % _noteColors.length];
    final pinColor = _pinColors[index % _pinColors.length];
    // Leggerissima inclinazione alternata per simulare fogli appesi a mano
    final angle = (index % 2 == 0) ? -0.012 : 0.012;

    return Transform.rotate(
      angle: angle,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          Material(
            color: bgColor,
            elevation: 3,
            shadowColor: Colors.black26,
            borderRadius: BorderRadius.circular(4),
            child: InkWell(
              onTap: onTap,
              borderRadius: BorderRadius.circular(4),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(18, 22, 18, 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.black12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            annuncio.titolo,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF222222),
                            ),
                          ),
                        ),
                        if (annuncio.ral != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2B5943).withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: const Color(0xFF2B5943).withValues(alpha: 0.35),
                              ),
                            ),
                            child: Text(
                              '${annuncio.ral} €',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Color(0xFF2B5943),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      annuncio.descrizione,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.4,
                        color: Color(0xFF444444),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Divider(height: 1, color: Colors.black12),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.apartment, size: 15, color: Colors.black54),
                            const SizedBox(width: 6),
                            Text(
                              annuncio.aziendaNome.isNotEmpty
                                  ? annuncio.aziendaNome
                                  : 'Azienda verficata',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const Row(
                          children: [
                            Text(
                              'Leggi e candidati',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF2B5943),
                              ),
                            ),
                            SizedBox(width: 2),
                            Icon(Icons.arrow_forward, size: 14, color: Color(0xFF2B5943)),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Puntina in alto al centro del foglietto
          Positioned(
            top: -7,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: pinColor,
                shape: BoxShape.circle,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black38,
                    blurRadius: 3,
                    offset: Offset(1, 2),
                  ),
                ],
                border: Border.all(color: Colors.white70, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}