import 'package:flutter/material.dart';

void main() {
  runApp(const CapsuleRecommendationApp());
}

class CapsuleRecommendationApp extends StatelessWidget {
  const CapsuleRecommendationApp({super.key});

  @override
  Widget build(BuildContext context) {
    const nespressoBlack = Color(0xFF111111);
    const nespressoGold = Color(0xFFB08D57);
    const nespressoCream = Color(0xFFF6F1E8);

    return MaterialApp(
      title: 'Nespresso Assistant',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'NespressoLucas',
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: nespressoGold,
          onPrimary: Colors.white,
          secondary: nespressoBlack,
          onSecondary: Colors.white,
          error: Color(0xFFB3261E),
          onError: Colors.white,
          surface: Colors.white,
          onSurface: nespressoBlack,
        ),
        scaffoldBackgroundColor: nespressoCream,
        appBarTheme: const AppBarTheme(
          backgroundColor: nespressoBlack,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: nespressoGold,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
      home: const ChatbotScreen(),
    );
  }
}

enum UserPath { personalized, quick }

enum UserGoal { focus, sport, stressManagement, relax, justCoffee }

enum EmotionState { stressed, tired, neutral, positive, calm }

enum EnergyLevel { low, medium, high }

enum AlternativeChoice { intense, soft, lessCaffeine, keepMain }

class CapsuleRecommendation {
  const CapsuleRecommendation({
    required this.name,
    required this.why,
    required this.effect,
    required this.caffeine,
    this.intensity = 'Moyenne',
  });

  final String name;
  final String why;
  final String effect;
  final String caffeine;
  final String intensity;
}

class ChatMessage {
  const ChatMessage({
    required this.text,
    this.isBot = true,
    this.options = const [],
  });

  final String text;
  final bool isBot;
  final List<String> options;
}

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final List<ChatMessage> _messages = [];

  UserPath? _path;
  UserGoal? _goal;
  EmotionState? _emotion;
  EnergyLevel? _energy;
  CapsuleRecommendation? _mainRecommendation;
  bool _showEnergyAuto = false;

  int _step = 0;

  bool get _isEvening {
    final hour = DateTime.now().hour;
    return hour >= 18 || hour <= 5;
  }

  @override
  void initState() {
    super.initState();
    _pushWelcome();
  }

  void _pushWelcome() {
    _messages
      ..clear()
      ..add(
        const ChatMessage(
          text:
              'Bonjour, je vais vous aider à trouver la capsule la plus adaptée à votre moment.',
          options: ['Commencer', 'Voir comment ça fonctionne'],
        ),
      );
  }

  void _handleSelection(String choice) {
    setState(() {
      _messages.add(ChatMessage(text: choice, isBot: false));

      switch (_step) {
        case 0:
          _step = 1;
          _messages.add(
            const ChatMessage(
              text:
                  'Souhaitez-vous une recommandation basée sur vos données et votre contexte du moment ?',
              options: [
                'Oui, recommandation personnalisée',
                'Non, recommandation rapide',
              ],
            ),
          );
          break;

        case 1:
          if (choice.contains('personnalisée')) {
            _path = UserPath.personalized;
            _messages.add(
              const ChatMessage(
                text:
                    'Parfait. Le système peut utiliser : habitudes de consommation, données de machine connectée, données bien-être disponibles et vos réponses.',
              ),
            );
          } else {
            _path = UserPath.quick;
            _messages.add(
              const ChatMessage(
                text:
                    'Très bien. Je vais faire une recommandation rapide uniquement avec quelques questions courtes.',
              ),
            );
          }

          _step = 2;
          _messages.add(
            ChatMessage(
              text: _isEvening
                  ? 'J’ai détecté une consommation en soirée. Je vais privilégier des capsules peu caféinées.'
                  : 'Moment détecté automatiquement selon l’heure du téléphone. Continuons.',
              options: const [
                'Continuer',
              ],
            ),
          );
          break;

        case 2:
          _step = 3;
          _messages.add(
            const ChatMessage(
              text: 'Quel est votre besoin principal en ce moment ?',
              options: [
                'Me concentrer pour travailler / étudier',
                'Me préparer pour le sport',
                'Gérer le stress avant un moment important',
                'Me détendre',
                'J’ai juste envie d’un café',
              ],
            ),
          );
          break;

        case 3:
          _goal = _parseGoal(choice);
          _step = 4;
          _messages.add(
            const ChatMessage(
              text: 'Comment vous sentez-vous actuellement ?',
              options: [
                'Stressé / anxieux',
                'Fatigué / démotivé',
                'Neutre',
                'Positif / motivé',
                'Calme / relax',
              ],
            ),
          );
          break;

        case 4:
          _emotion = _parseEmotion(choice);
          _step = 5;
          _messages.add(
            const ChatMessage(
              text:
                  'Souhaitez-vous que j’analyse automatiquement votre niveau d’énergie (si données disponibles) ?',
              options: ['Oui, analyse auto', 'Non, je réponds manuellement'],
            ),
          );
          break;

        case 5:
          if (choice.contains('analyse auto')) {
            _showEnergyAuto = true;
            _energy = _inferEnergyFromContext();
            _messages.add(
              const ChatMessage(
                text:
                    'J’analyse votre niveau d’énergie à partir de vos données disponibles et de votre contexte.',
              ),
            );
            _messages.add(
              ChatMessage(
                text:
                    'Niveau estimé : ${_energyLabel(_energy!)}. Je prépare la recommandation.',
                options: const ['Voir ma recommandation'],
              ),
            );
            _step = 7;
          } else {
            _showEnergyAuto = false;
            _step = 6;
            _messages.add(
              const ChatMessage(
                text: 'Comment évaluez-vous votre niveau d’énergie ?',
                options: ['Faible', 'Moyen', 'Élevé'],
              ),
            );
          }
          break;

        case 6:
          _energy = _parseEnergy(choice);
          _step = 7;
          _messages.add(
            const ChatMessage(
              text:
                  'Merci. J’applique la contrainte horaire, votre niveau d’énergie, votre objectif et votre état émotionnel.',
              options: ['Voir ma recommandation'],
            ),
          );
          break;

        case 7:
          _mainRecommendation = _buildRecommendation();
          _step = 8;
          _messages.add(_recommendationMessage(_mainRecommendation!));
          _messages.add(
            const ChatMessage(
              text: 'Souhaitez-vous voir d’autres options ?',
              options: [
                'Oui, une option plus intense',
                'Oui, une option plus douce',
                'Oui, une option avec moins de caféine',
                'Non, je garde cette recommandation',
              ],
            ),
          );
          break;

        case 8:
          final alternative = _buildAlternative(_parseAlternative(choice));
          if (alternative != null) {
            _messages.add(_recommendationMessage(alternative));
          }
          _step = 9;
          _messages.add(
            const ChatMessage(
              text: 'Que souhaitez-vous faire maintenant ?',
              options: [
                'Ajouter la capsule au panier',
                'Enregistrer pour plus tard',
                'Voir les détails du café',
                'Refaire une recommandation',
              ],
            ),
          );
          break;

        case 9:
          if (choice == 'Refaire une recommandation') {
            _resetConversation();
            return;
          }
          _messages.add(
            ChatMessage(
              text:
                  'Parfait 👌 Action enregistrée : "$choice". Si vous voulez, je peux relancer une nouvelle recommandation.',
              options: const ['Refaire une recommandation'],
            ),
          );
          break;
      }
    });
  }

  void _resetConversation() {
    setState(() {
      _path = null;
      _goal = null;
      _emotion = null;
      _energy = null;
      _mainRecommendation = null;
      _showEnergyAuto = false;
      _step = 0;
      _pushWelcome();
    });
  }

  UserGoal _parseGoal(String choice) {
    if (choice.contains('concentrer')) return UserGoal.focus;
    if (choice.contains('sport')) return UserGoal.sport;
    if (choice.contains('stress')) return UserGoal.stressManagement;
    if (choice.contains('détendre')) return UserGoal.relax;
    return UserGoal.justCoffee;
  }

  EmotionState _parseEmotion(String choice) {
    if (choice.contains('Stressé')) return EmotionState.stressed;
    if (choice.contains('Fatigué')) return EmotionState.tired;
    if (choice.contains('Positif')) return EmotionState.positive;
    if (choice.contains('Calme')) return EmotionState.calm;
    return EmotionState.neutral;
  }

  EnergyLevel _parseEnergy(String choice) {
    if (choice == 'Faible') return EnergyLevel.low;
    if (choice == 'Élevé') return EnergyLevel.high;
    return EnergyLevel.medium;
  }

  EnergyLevel _inferEnergyFromContext() {
    if (_emotion == EmotionState.tired || _emotion == EmotionState.stressed) {
      return EnergyLevel.low;
    }
    if (_emotion == EmotionState.positive) return EnergyLevel.high;
    return _isEvening ? EnergyLevel.medium : EnergyLevel.low;
  }

  AlternativeChoice _parseAlternative(String choice) {
    if (choice.contains('intense')) return AlternativeChoice.intense;
    if (choice.contains('douce')) return AlternativeChoice.soft;
    if (choice.contains('moins')) return AlternativeChoice.lessCaffeine;
    return AlternativeChoice.keepMain;
  }

  String _energyLabel(EnergyLevel energy) {
    switch (energy) {
      case EnergyLevel.low:
        return 'Faible';
      case EnergyLevel.medium:
        return 'Moyen';
      case EnergyLevel.high:
        return 'Élevé';
    }
  }

  CapsuleRecommendation _buildRecommendation() {
    final energy = _energy ?? EnergyLevel.medium;
    final goal = _goal ?? UserGoal.justCoffee;
    final emotion = _emotion ?? EmotionState.neutral;

    if (_isEvening) {
      if (goal == UserGoal.relax) {
        return const CapsuleRecommendation(
          name: 'Altissio Decaffeinato',
          why:
              'Comme il s’agit d’une consommation en soirée, je privilégie une capsule avec peu ou pas de caféine.',
          effect: 'Détente et plaisir sans perturber le sommeil.',
          caffeine: 'Très faible',
          intensity: '6',
        );
      }
      return const CapsuleRecommendation(
        name: 'Altissio Decaffeinato',
        why:
            'Soirée détectée automatiquement : je priorise un profil décaféiné pour limiter la stimulation.',
        effect: 'Moment café du soir plus doux.',
        caffeine: 'Décaféiné',
        intensity: '5',
      );
    }

    if (goal == UserGoal.stressManagement && emotion == EmotionState.stressed) {
      return const CapsuleRecommendation(
        name: 'Melozio Go',
        why:
            'Vous avez besoin de soutien, mais sans surstimulation : équilibre idéal pour un moment important.',
        effect: 'Concentration stable avec une montée douce.',
        caffeine: 'Modérée',
        intensity: '6',
      );
    }

    if (goal == UserGoal.sport) {
      if (energy == EnergyLevel.low || energy == EnergyLevel.medium) {
        return const CapsuleRecommendation(
          name: 'Ristretto Intenso',
          why:
              'Objectif sport avec énergie basse/moyenne : cette capsule apporte un coup de boost net.',
          effect: 'Activation avant effort.',
          caffeine: 'Élevée',
          intensity: '9',
        );
      }
      return const CapsuleRecommendation(
        name: 'Arpeggio',
        why:
            'Vous êtes déjà bien énergisé : on maintient la dynamique sans excès de puissance.',
        effect: 'Énergie stable pré-entraînement.',
        caffeine: 'Modérée à élevée',
        intensity: '8',
      );
    }

    if (goal == UserGoal.relax) {
      return const CapsuleRecommendation(
        name: 'Ethiopia',
        why:
            'Pour un moment détente, ce profil floral et délicat est souvent le plus agréable.',
        effect: 'Pause aromatique et apaisante.',
        caffeine: 'Modérée',
        intensity: '4',
      );
    }

    if (goal == UserGoal.focus || goal == UserGoal.justCoffee) {
      if (energy == EnergyLevel.low) {
        return const CapsuleRecommendation(
          name: 'Melozio Go',
          why:
              'Niveau d’énergie faible + besoin de clarté : bon compromis entre efficacité et confort.',
          effect: 'Soutien mental progressif.',
          caffeine: 'Modérée',
          intensity: '6',
        );
      }
      return const CapsuleRecommendation(
        name: 'Arpeggio',
        why: 'Pour rester concentré avec du caractère, sans aller sur l’extrême.',
        effect: 'Focus et constance.',
        caffeine: 'Modérée à élevée',
        intensity: '8',
      );
    }

    return const CapsuleRecommendation(
      name: 'Melozio Go',
      why: 'Recommandation équilibrée selon votre contexte.',
      effect: 'Équilibre général.',
      caffeine: 'Modérée',
      intensity: '6',
    );
  }

  CapsuleRecommendation? _buildAlternative(AlternativeChoice choice) {
    if (choice == AlternativeChoice.keepMain) {
      return null;
    }

    switch (choice) {
      case AlternativeChoice.intense:
        return const CapsuleRecommendation(
          name: 'Ristretto Intenso',
          why: 'Vous souhaitez une option plus intense.',
          effect: 'Boost plus marqué.',
          caffeine: 'Élevée',
          intensity: '9',
        );
      case AlternativeChoice.soft:
        return const CapsuleRecommendation(
          name: 'Ethiopia',
          why: 'Version plus douce et plus aromatique.',
          effect: 'Pause plus légère.',
          caffeine: 'Modérée',
          intensity: '4',
        );
      case AlternativeChoice.lessCaffeine:
        return const CapsuleRecommendation(
          name: 'Half Caffeinato',
          why: 'Vous souhaitez réduire la caféine sans perdre le rituel café.',
          effect: 'Équilibre avec stimulation légère.',
          caffeine: 'Faible à modérée',
          intensity: '5',
        );
      case AlternativeChoice.keepMain:
        return null;
    }
  }

  ChatMessage _recommendationMessage(CapsuleRecommendation rec) {
    return ChatMessage(
      text: 'Voici la capsule la plus adaptée à votre situation :\n\n'
          'Capsule recommandée : ${rec.name}\n'
          'Pourquoi : ${rec.why}\n'
          'Effet recherché : ${rec.effect}\n'
          'Niveau de caféine : ${rec.caffeine}\n'
          'Intensité : ${rec.intensity}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nespresso Capsule Assistant')),
      body: SafeArea(
        child: Column(
          children: [
            _ContextHeader(isEvening: _isEvening, path: _path, auto: _showEnergyAuto),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(14, 6, 14, 14),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final message = _messages[index];
                  final isLast = index == _messages.length - 1;
                  return _MessageBubble(
                    message: message,
                    onOptionSelected: _handleSelection,
                    showOptions: isLast,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContextHeader extends StatelessWidget {
  const _ContextHeader({
    required this.isEvening,
    required this.path,
    required this.auto,
  });

  final bool isEvening;
  final UserPath? path;
  final bool auto;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    String mode = 'Mode non défini';
    if (path == UserPath.personalized) mode = 'Personnalisé';
    if (path == UserPath.quick) mode = 'Rapide';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(14, 14, 14, 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.secondary, const Color(0xFF2A2A2A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _TagChip(label: isEvening ? 'Soirée détectée' : 'Journée détectée'),
          _TagChip(label: 'Parcours: $mode'),
          _TagChip(label: auto ? 'Énergie auto' : 'Énergie manuelle'),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.13),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.onOptionSelected,
    required this.showOptions,
  });

  final ChatMessage message;
  final ValueChanged<String> onOptionSelected;
  final bool showOptions;

  @override
  Widget build(BuildContext context) {
    final isBot = message.isBot;
    final scheme = Theme.of(context).colorScheme;

    return Align(
      alignment: isBot ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 10),
        child: Column(
          crossAxisAlignment:
              isBot ? CrossAxisAlignment.start : CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isBot ? Colors.white : scheme.primary,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isBot ? 4 : 18),
                  bottomRight: Radius.circular(isBot ? 18 : 4),
                ),
                border: Border.all(
                  color: isBot ? const Color(0xFFE5DACA) : scheme.primary,
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x12000000),
                    blurRadius: 12,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isBot ? const Color(0xFF222222) : Colors.white,
                  height: 1.35,
                ),
              ),
            ),
            if (showOptions && message.options.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: message.options
                      .map(
                        (option) => ElevatedButton(
                          onPressed: () => onOptionSelected(option),
                          child: Text(option),
                        ),
                      )
                      .toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
