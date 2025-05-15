import 'package:flutter/material.dart';
import 'package:examen_tp/models/score.dart';
import 'package:examen_tp/services/api_service.dart';

class ScoresScreen extends StatefulWidget {
  const ScoresScreen({Key? key}) : super(key: key);

  @override
  _ScoresScreenState createState() => _ScoresScreenState();
}

class _ScoresScreenState extends State<ScoresScreen> {
  final ApiService _apiService = ApiService();
  List<Score> _scores = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadScores();
  }

  Future<void> _loadScores() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final scores = await _apiService.getScores();
      
      // Sort scores by score (highest first)
      scores.sort((a, b) => b.score.compareTo(a.score));
      
      setState(() {
        _scores = scores;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur lors du chargement des scores: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tableau des Scores'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.red)))
              : _scores.isEmpty
                  ? const Center(child: Text('Aucun score enregistré'))
                  : ListView.builder(
                      itemCount: _scores.length,
                      itemBuilder: (context, index) {
                        final score = _scores[index];
                        return ListTile(
                          leading: CircleAvatar(
                            child: Text('${index + 1}'),
                          ),
                          title: Text('${score.playerName} (ID: ${score.id})'),
                          subtitle: Text('Temps: ${score.time} secondes'),
                          trailing: Text(
                            '${score.score} points',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        );
                      },
                    ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadScores,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}