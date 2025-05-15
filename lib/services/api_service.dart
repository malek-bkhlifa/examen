import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:examen_tp/models/score.dart';

class ApiService {
  // For emulator, use 10.0.2.2 instead of localhost to access your development machine
  // static const String baseUrl = 'http://10.0.2.2:3000'; // For Android emulator
  
  // Local storage for scores
  final List<Score> _scores = [];
  
  // Start a new game and get a random number
  Future<int> startNewGame() async {
    try {
      // Generate a random number locally instead of calling the server
      final random = Random();
      final randomNumber = random.nextInt(101); // 0-100
      
      print('Generated random number: $randomNumber'); // For debugging
      return randomNumber;
    } catch (e) {
      print('Error in startNewGame: $e');
      throw Exception('Failed to start new game: $e');
    }
  }

  // Save score to local storage
  Future<void> saveScore(Score score) async {
    try {
      // Save score locally
      _scores.add(score);
      print('Score saved locally: ${score.playerName} - ${score.score} points');
    } catch (e) {
      print('Error in saveScore: $e');
      throw Exception('Failed to save score: $e');
    }
  }

  // Get all scores from local storage
  Future<List<Score>> getScores() async {
    try {
      // Return scores from local storage
      print('Returning ${_scores.length} scores from local storage');
      return List<Score>.from(_scores);
    } catch (e) {
      print('Error in getScores: $e');
      throw Exception('Failed to load scores: $e');
    }
  }
}