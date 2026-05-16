import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

void main() {
  runApp(const CrimsonTapperApp());
}

class CrimsonTapperApp extends StatelessWidget {
  const CrimsonTapperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crimson Tapper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.red,
        scaffoldBackgroundColor: const Color(0xFF111111),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.red,
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int score = 0;
  int multiplier = 1;
  int autoTapRate = 0;
  bool isPremium = false;
  int highScore = 0;
  Timer? autoTimer;
  List<Map<String, dynamic>> upgrades = [
    {'name': 'Double Tap', 'cost': 50, 'bought': false},
    {'name': 'Auto Tapper', 'cost': 100, 'bought': false},
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
    autoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (autoTapRate > 0) {
        setState(() {
          score += autoTapRate * (isPremium ? 2 : 1);
        });
      }
    });
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      score = prefs.getInt('score') ?? 0;
      highScore = prefs.getInt('highScore') ?? 0;
      isPremium = prefs.getBool('premium') ?? false;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('score', score);
    if (score > highScore) {
      highScore = score;
      await prefs.setInt('highScore', highScore);
    }
    await prefs.setBool('premium', isPremium);
  }

  void tapOrb() {
    setState(() {
      score += multiplier * (isPremium ? 2 : 1);
    });
    _saveData();
  }

  void buyUpgrade(int index) {
    final upgrade = upgrades[index];
    if (score >= upgrade['cost'] && !upgrade['bought']) {
      setState(() {
        score -= upgrade['cost'] as int;
        upgrade['bought'] = true;
        if (index == 0) multiplier = 2;
        if (index == 1) autoTapRate = 5;
      });
      _saveData();
    }
  }

  void buyPremium() {
    setState(() {
      isPremium = true;
    });
    _saveData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Premium unlocked! (Demo - Monthly sub simulated)')),
    );
  }

  @override
  void dispose() {
    autoTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crimson Tapper'),
        actions: [
          IconButton(
            icon: const Icon(Icons.monetization_on, color: Colors.red),
            onPressed: buyPremium,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Power: $score',
              style: const TextStyle(fontSize: 32, color: Colors.red, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('High Score: $highScore', style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 40),
            GestureDetector(
              onTap: tapOrb,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.5),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'TAP',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
            const Text('Upgrades', style: TextStyle(fontSize: 24, color: Colors.red)),
            Expanded(
              child: ListView.builder(
                itemCount: upgrades.length,
                itemBuilder: (context, index) {
                  final upgrade = upgrades[index];
                  return ListTile(
                    title: Text(upgrade['name'] as String, style: const TextStyle(color: Colors.white)),
                    subtitle: Text('Cost: ${upgrade['cost']} Power', style: const TextStyle(color: Colors.white70)),
                    trailing: upgrade['bought'] as bool
                        ? const Icon(Icons.check, color: Colors.green)
                        : ElevatedButton(
                            onPressed: () => buyUpgrade(index),
                            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                            child: const Text('Buy'),
                          ),
                  );
                },
              ),
            ),
            if (!isPremium)
              ElevatedButton(
                onPressed: buyPremium,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Unlock Premium (Monthly Sub - Demo)'),
              )
            else
              const Text('Premium Active - x2 Power!', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
