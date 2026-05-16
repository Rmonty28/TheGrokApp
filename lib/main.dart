import 'package:flutter/material.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const CrimsonTapperApp());
}

class CrimsonTapperApp extends StatelessWidget {
  const CrimsonTapperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Crimson Tapper',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF111111),
        primaryColor: const Color(0xFFFF0000),
        colorScheme: const ColorScheme.dark(primary: Color(0xFFFF0000)),
      ),
      home: const GameScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double power = 0;
  double tapMultiplier = 1;
  int autoTappers = 0;
  double autoPower = 0;
  int highScore = 0;

  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadData();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _autoGenerate());
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      power = prefs.getDouble('power') ?? 0;
      tapMultiplier = prefs.getDouble('tapMultiplier') ?? 1;
      autoTappers = prefs.getInt('autoTappers') ?? 0;
      autoPower = prefs.getDouble('autoPower') ?? 0;
      highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setDouble('power', power);
    prefs.setDouble('tapMultiplier', tapMultiplier);
    prefs.setInt('autoTappers', autoTappers);
    prefs.setDouble('autoPower', autoPower);
    prefs.setInt('highScore', highScore);
  }

  void _tap() {
    setState(() {
      power += 1 * tapMultiplier;
      if (power > highScore) highScore = power.toInt();
    });
    _saveData();
  }

  void _autoGenerate() {
    setState(() {
      power += autoPower;
      if (power > highScore) highScore = power.toInt();
    });
    _saveData();
  }

  void _buyUpgrade(String type) {
    setState(() {
      if (type == 'multi' && power >= 50) {
        power -= 50;
        tapMultiplier += 0.5;
      } else if (type == 'auto' && power >= 100) {
        power -= 100;
        autoTappers++;
        autoPower += 0.5;
      }
    });
    _saveData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRIMSON TAPPER', style: TextStyle(color: Color(0xFFFF0000), fontWeight: FontWeight.bold)),
        backgroundColor: Colors.black,
        actions: [Text('High: $highScore', style: const TextStyle(color: Colors.white))],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: _tap,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF0000),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: Colors.red.withOpacity(0.5), blurRadius: 30, spreadRadius: 10)],
                ),
                child: const Center(child: Text('TAP', style: TextStyle(fontSize: 40, color: Colors.black, fontWeight: FontWeight.bold))),
              ),
            ),
            const SizedBox(height: 40),
            Text('Power: ${power.toStringAsFixed(1)}', style: const TextStyle(fontSize: 32, color: Color(0xFFFF0000))),
            const SizedBox(height: 20),
            Text('Tap Multi: x${tapMultiplier.toStringAsFixed(1)} | Auto: $autoTappers', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _buyUpgrade('multi'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF0000)),
                  child: const Text('Upgrade Tap (50)'),
                ),
                ElevatedButton(
                  onPressed: () => _buyUpgrade('auto'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF0000)),
                  child: const Text('Buy Auto (100)'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Simulate IAP
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Premium Unlocked! (In real app: add IAP)')));
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              child: const Text('Unlock Premium (Monthly)'),
            ),
          ],
        ),
      ),
    );
  }
}