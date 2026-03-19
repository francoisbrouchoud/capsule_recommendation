import 'package:flutter/material.dart';

void main() {
  runApp(const CapsuleRecommendationApp());
}

class CapsuleRecommendationApp extends StatelessWidget {
  const CapsuleRecommendationApp({super.key});

  @override
  Widget build(BuildContext context) {
    const black = Color(0xFF111111);
    const gold = Color(0xFFB08D57);
    const cream = Color(0xFFF6F1E8);

    return MaterialApp(
      title: 'Capsule Advisor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme(
          brightness: Brightness.light,
          primary: gold,
          onPrimary: Colors.white,
          secondary: black,
          onSecondary: Colors.white,
          error: Color(0xFFB3261E),
          onError: Colors.white,
          surface: Colors.white,
          onSurface: black,
        ),
        scaffoldBackgroundColor: cream,
        appBarTheme: const AppBarTheme(
          backgroundColor: black,
          foregroundColor: Colors.white,
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: gold,
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
    this.intensity = 'Medium',
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
  int _step = 0;

  bool get _isEvening {
    final hour = DateTime.now().hour;
    return hour >= 18 || hour <= 5;
  }

  String _currentTime() {
    final now = DateTime.now();
    final hh = now.hour.toString().padLeft(2, '0');
    final mm = now.minute.toString().padLeft(2, '0');
    return '$hh:$mm';
  }

  @override
  void initState() {
    super.initState();
    _resetConversation();
  }

  void _resetConversation() {
    _path = null;
    _goal = null;
    _emotion = null;
    _energy = null;
    _step = 0;
    _messages
      ..clear()
      ..add(
        const ChatMessage(
          text:
              'Hello, I will help you find the capsule that best fits your current moment.',
          options: ['Start', 'See how it works'],
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
                  'Would you like a recommendation based on your data and current context?',
              options: [
                'Yes, personalized recommendation',
                'No, quick recommendation',
              ],
            ),
          );
          break;

        case 1:
          _path = choice.contains('personalized')
              ? UserPath.personalized
              : UserPath.quick;
          _messages.add(
            ChatMessage(
              text: choice.contains('personalized')
                  ? 'Great. The system can use consumption habits, connected machine data, available wellness data, and your answers.'
                  : 'Great. I will run a quick recommendation with short questions only.',
            ),
          );
          _step = 2;
          _messages.add(
            ChatMessage(
              text: _isEvening
                  ? 'Evening moment detected automatically. I will prioritize low-caffeine capsules.'
                  : 'Time of day detected automatically from the device clock.',
              options: const ['Continue'],
            ),
          );
          break;

        case 2:
          _step = 3;
          _messages.add(
            const ChatMessage(
              text: 'What is your main need right now?',
              options: [
                'Focus for work / study',
                'Prepare for sport',
                'Manage stress before an important moment',
                'Relax',
                'I just want a coffee',
              ],
            ),
          );
          break;

        case 3:
          _goal = _parseGoal(choice);
          _step = 4;
          _messages.add(
            const ChatMessage(
              text: 'How do you feel right now?',
              options: [
                'Stressed / anxious',
                'Tired / unmotivated',
                'Neutral',
                'Positive / motivated',
                'Calm / relaxed',
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
                  'Do you agree to let us automatically use your health bracelet/watch data to analyze your energy level?',
              options: ['Yes, auto analysis', 'No, I will answer manually'],
            ),
          );
          break;

        case 5:
          if (choice.contains('auto analysis')) {
            _energy = _inferEnergyFromContext();
            _step = 7;
            _messages.add(
              ChatMessage(
                text:
                    'Estimated level: ${_energyLabel(_energy!)}. I am preparing your recommendation.',
                options: const ['See my recommendation'],
              ),
            );
          } else {
            _step = 6;
            _messages.add(
              const ChatMessage(
                text: 'How would you rate your energy level?',
                options: ['Low', 'Medium', 'High'],
              ),
            );
          }
          break;

        case 6:
          _energy = _parseEnergy(choice);
          _step = 7;
          _messages.add(
            const ChatMessage(
              text: 'Thanks. I am preparing your recommendation.',
              options: ['See my recommendation'],
            ),
          );
          break;

        case 7:
          final rec = _buildRecommendation();
          _step = 8;
          _messages.add(_recommendationMessage(rec));
          _messages.add(
            const ChatMessage(
              text: 'Would you like to see other options?',
              options: [
                'Yes, a more intense option',
                'Yes, a smoother option',
                'Yes, an option with less caffeine',
                'No, I will keep this recommendation',
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
              text: 'What would you like to do now?',
              options: [
                'Add capsule to cart',
                'Save for later',
                'View coffee details',
                'Redo a recommendation',
              ],
            ),
          );
          break;

        case 9:
          if (choice == 'Redo a recommendation') {
            _resetConversation();
            return;
          }
          _messages.add(
            const ChatMessage(
              text: 'Can I help you with anything else?',
              options: ['Redo a recommendation'],
            ),
          );
          break;
      }
    });
  }

  UserGoal _parseGoal(String choice) {
    if (choice.contains('Focus')) return UserGoal.focus;
    if (choice.contains('sport')) return UserGoal.sport;
    if (choice.contains('stress')) return UserGoal.stressManagement;
    if (choice.contains('Relax')) return UserGoal.relax;
    return UserGoal.justCoffee;
  }

  EmotionState _parseEmotion(String choice) {
    if (choice.contains('Stressed')) return EmotionState.stressed;
    if (choice.contains('Tired')) return EmotionState.tired;
    if (choice.contains('Positive')) return EmotionState.positive;
    if (choice.contains('Calm')) return EmotionState.calm;
    return EmotionState.neutral;
  }

  EnergyLevel _parseEnergy(String choice) {
    if (choice == 'Low') return EnergyLevel.low;
    if (choice == 'High') return EnergyLevel.high;
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
    if (choice.contains('smoother')) return AlternativeChoice.soft;
    if (choice.contains('less')) return AlternativeChoice.lessCaffeine;
    return AlternativeChoice.keepMain;
  }

  String _energyLabel(EnergyLevel energy) {
    switch (energy) {
      case EnergyLevel.low:
        return 'Low';
      case EnergyLevel.medium:
        return 'Medium';
      case EnergyLevel.high:
        return 'High';
    }
  }

  CapsuleRecommendation _buildRecommendation() {
    final energy = _energy ?? EnergyLevel.medium;
    final goal = _goal ?? UserGoal.justCoffee;
    final emotion = _emotion ?? EmotionState.neutral;

    if (_isEvening) {
      return const CapsuleRecommendation(
        name: 'Altissio Decaffeinato',
        why: 'Evening consumption: prioritize a low-caffeine capsule.',
        effect: 'A smoother moment for the end of the day.',
        caffeine: 'Decaffeinated',
        intensity: '5',
      );
    }

    if (goal == UserGoal.stressManagement && emotion == EmotionState.stressed) {
      return const CapsuleRecommendation(
        name: 'Melozio Go',
        why: 'Need support without overstimulation.',
        effect: 'Stable concentration.',
        caffeine: 'Moderate',
        intensity: '6',
      );
    }

    if (goal == UserGoal.sport) {
      if (energy == EnergyLevel.low || energy == EnergyLevel.medium) {
        return const CapsuleRecommendation(
          name: 'Ristretto Intenso',
          why: 'Sport goal with low/medium energy.',
          effect: 'Strong boost before effort.',
          caffeine: 'High',
          intensity: '9',
        );
      }
      return const CapsuleRecommendation(
        name: 'Arpeggio',
        why: 'Maintain energy with controlled intensity.',
        effect: 'Stable energy.',
        caffeine: 'Moderate to high',
        intensity: '8',
      );
    }

    if (goal == UserGoal.relax) {
      return const CapsuleRecommendation(
        name: 'Ethiopia',
        why: 'A softer profile for a relaxing moment.',
        effect: 'Aromatic break.',
        caffeine: 'Moderate',
        intensity: '4',
      );
    }

    if (goal == UserGoal.focus || goal == UserGoal.justCoffee) {
      if (energy == EnergyLevel.low) {
        return const CapsuleRecommendation(
          name: 'Melozio Go',
          why: 'Low energy with a need for clarity.',
          effect: 'Progressive mental support.',
          caffeine: 'Moderate',
          intensity: '6',
        );
      }
      return const CapsuleRecommendation(
        name: 'Arpeggio',
        why: 'A bold profile to stay focused.',
        effect: 'Focus and consistency.',
        caffeine: 'Moderate to high',
        intensity: '8',
      );
    }

    return const CapsuleRecommendation(
      name: 'Melozio Go',
      why: 'Balanced recommendation based on your context.',
      effect: 'Overall balance.',
      caffeine: 'Moderate',
      intensity: '6',
    );
  }

  CapsuleRecommendation? _buildAlternative(AlternativeChoice choice) {
    if (choice == AlternativeChoice.keepMain) return null;

    switch (choice) {
      case AlternativeChoice.intense:
        return const CapsuleRecommendation(
          name: 'Ristretto Intenso',
          why: 'You asked for a more intense option.',
          effect: 'Stronger boost.',
          caffeine: 'High',
          intensity: '9',
        );
      case AlternativeChoice.soft:
        return const CapsuleRecommendation(
          name: 'Ethiopia',
          why: 'You asked for a smoother option.',
          effect: 'Lighter break.',
          caffeine: 'Moderate',
          intensity: '4',
        );
      case AlternativeChoice.lessCaffeine:
        return const CapsuleRecommendation(
          name: 'Half Caffeinato',
          why: 'You asked for a lower-caffeine option.',
          effect: 'Light stimulation.',
          caffeine: 'Low to moderate',
          intensity: '5',
        );
      case AlternativeChoice.keepMain:
        return null;
    }
  }

  ChatMessage _recommendationMessage(CapsuleRecommendation rec) {
    return ChatMessage(
      text: 'Here is the capsule that best matches your situation:\n\n'
          'Recommended capsule: ${rec.name}\n'
          'Why: ${rec.why}\n'
          'Expected effect: ${rec.effect}\n'
          'Caffeine level: ${rec.caffeine}\n'
          'Intensity: ${rec.intensity}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_currentTime())),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
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
