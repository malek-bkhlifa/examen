import 'dart:async';
import 'package:flutter/material.dart';
import 'package:examen_tp/models/attempt.dart';
import 'package:examen_tp/models/score.dart';
import 'package:examen_tp/services/api_service.dart';
import 'package:examen_tp/screens/scores_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final TextEditingController _guessController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final ApiService _apiService = ApiService();
  
  int? _targetNumber;
  List<Attempt> _attempts = [];
  int _remainingAttempts = 5;
  bool _gameOver = false;
  bool _gameWon = false;
  int _score = 0;
  
  // Timer related variables
  Timer? _timer;
  int _seconds = 0;
  bool _isTimerRunning = false;

  @override
  void dispose() {
    _guessController.dispose();
    _nameController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startNewGame() async {
    try {
      final randomNumber = await _apiService.startNewGame();
      setState(() {
        _targetNumber = randomNumber;
        _attempts = [];
        _remainingAttempts = 5;
        _gameOver = false;
        _gameWon = false;
        _score = 0;
        _seconds = 0;
      });
      _startTimer();
      print('New game started with target number: $_targetNumber'); // For debugging
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error starting new game: $e')),
      );
    }
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _seconds = 0;
      _isTimerRunning = true;
    });
    
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isTimerRunning = false;
    });
  }

  void _makeGuess() {
    if (_targetNumber == null || _gameOver) return;
    
    final guessText = _guessController.text.trim();
    if (guessText.isEmpty) return;
    
    final guess = int.tryParse(guessText);
    if (guess == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez entrer un nombre valide')),
      );
      return;
    }
    
    String message;
    if (guess < _targetNumber!) {
      message = 'plus grand';
    } else if (guess > _targetNumber!) {
      message = 'plus petit';
    } else {
      message = 'correct';
    }
    
    setState(() {
      _attempts.add(Attempt(
        number: guess,
        attemptNumber: 5 - _remainingAttempts + 1,
        message: message,
      ));
      
      if (guess == _targetNumber) {
        _gameOver = true;
        _gameWon = true;
        _score = (5 - _attempts.length + 1) * 10;
        _stopTimer();
        _showWinDialog();
      } else {
        _remainingAttempts--;
        if (_remainingAttempts <= 0) {
          _gameOver = true;
          _stopTimer();
          _showLoseDialog();
        }
      }
    });
    
    _guessController.clear();
  }

  void _showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Félicitations!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Vous avez trouvé le nombre en ${_attempts.length} tentatives!'),
            Text('Votre score: $_score'),
            Text('Temps: $_seconds secondes'),
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Entrez votre nom complet',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              if (_nameController.text.trim().isNotEmpty) {
                _saveScore();
                Navigator.of(context).pop();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Veuillez entrer votre nom')),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showLoseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Dommage!'),
        content: Text('Vous avez perdu. Le nombre était $_targetNumber.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _saveScore() async {
    final playerName = _nameController.text.trim();
    if (playerName.isEmpty) return;
    
    final score = Score(
      playerName: playerName,
      score: _score,
      time: _seconds,
    );
    
    try {
      await _apiService.saveScore(score);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Score enregistré avec succès!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'enregistrement du score: $e')),
      );
    }
  }

  void _navigateToScores() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScoresScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jeu de Devinette'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Timer display
            Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Text(
                'Temps: $_seconds secondes',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            
            // Game status
            Text(
              _targetNumber == null
                  ? 'Appuyez sur "Nouveau" pour commencer'
                  : _gameOver
                      ? _gameWon
                          ? 'Vous avez gagné! Score: $_score'
                          : 'Vous avez perdu. Le nombre était $_targetNumber.'
                      : 'Devinez un nombre entre 0 et 100. Tentatives restantes: $_remainingAttempts',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            
            // Input field and guess button
            if (_targetNumber != null && !_gameOver)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _guessController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Votre proposition',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _makeGuess,
                    child: const Text('Deviner'),
                  ),
                ],
              ),
            const SizedBox(height: 16),
            
            // Game control buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _startNewGame,
                  child: const Text('Nouveau'),
                ),
                ElevatedButton(
                  onPressed: _navigateToScores,
                  child: const Text('Scores'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Attempts history
            const Text(
              'Historique des tentatives:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _attempts.length,
                itemBuilder: (context, index) {
                  final attempt = _attempts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text('${attempt.attemptNumber}'),
                    ),
                    title: Text('Proposition: ${attempt.number}'),
                    subtitle: Text('Message: ${attempt.message}'),
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