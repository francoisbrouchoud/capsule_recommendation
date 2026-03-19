import 'package:flutter/material.dart';

void main() {
  runApp(const CafeApp());
}

class CafeApp extends StatelessWidget {
  const CafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Proposition Café',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6F4E37)),
        useMaterial3: true,
      ),
      home: const CafeHomePage(),
    );
  }
}

class CafeItem {
  const CafeItem({
    required this.nom,
    required this.description,
    required this.prix,
    required this.emoji,
  });

  final String nom;
  final String description;
  final String prix;
  final String emoji;
}

class CafeHomePage extends StatelessWidget {
  const CafeHomePage({super.key});

  static const cafes = <CafeItem>[
    CafeItem(
      nom: 'Espresso',
      description: 'Court, intense et parfait pour un boost rapide.',
      prix: '2,00 €',
      emoji: '☕',
    ),
    CafeItem(
      nom: 'Cappuccino',
      description: 'Équilibre entre espresso, lait chaud et mousse.',
      prix: '3,20 €',
      emoji: '🥛',
    ),
    CafeItem(
      nom: 'Latte vanille',
      description: 'Doux et gourmand avec une touche sucrée.',
      prix: '3,80 €',
      emoji: '🍨',
    ),
    CafeItem(
      nom: 'Cold brew',
      description: 'Infusion lente, frais et moins amer.',
      prix: '3,50 €',
      emoji: '🧊',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ton café du jour'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const _HeroCard(),
            const SizedBox(height: 16),
            ...cafes.map((cafe) => _CafeCard(cafe: cafe)),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.local_cafe), label: 'Cafés'),
          NavigationDestination(icon: Icon(Icons.favorite_border), label: 'Favoris'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profil'),
        ],
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bonjour 👋',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Quelle est ton envie café aujourd\'hui ?',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.coffee_outlined),
            label: const Text('Voir les recommandations'),
          ),
        ],
      ),
    );
  }
}

class _CafeCard extends StatelessWidget {
  const _CafeCard({required this.cafe});

  final CafeItem cafe;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Text(cafe.emoji, style: const TextStyle(fontSize: 24)),
        title: Text(cafe.nom),
        subtitle: Text(cafe.description),
        trailing: Text(
          cafe.prix,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
    );
  }
}
