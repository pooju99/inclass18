import 'package:flutter/material.dart';
import '../models/question.dart';
import '../services/api_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<Question> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  bool _answerSelected = false;
  String _feedback = "";

  @override
  void initState() {
    super.initState();
    loadQuestions();
  }

  Future<void> loadQuestions() async {
    final data = await ApiService.fetchQuestions();
    setState(() {
      _questions = data;
    });
  }

  void checkAnswer(String selected, String correct) {
    if (_answerSelected) return;

    setState(() {
      _answerSelected = true;
      if (selected == correct) {
        _score++;
        _feedback = "Correct! The answer is $correct.";
      } else {
        _feedback = "Incorrect. The correct answer is $correct.";
      }
    });
  }

  void nextQuestion() {
    setState(() {
      _currentIndex++;
      _answerSelected = false;
      _feedback = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentIndex >= _questions.length) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quiz Finished")),
        body: Center(
          child: Text(
            "Your Score: $_score / ${_questions.length}",
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Question ${_currentIndex + 1} / ${_questions.length}"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              question.question,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            ...question.options.map((option) {
              return ElevatedButton(
                onPressed: () => checkAnswer(option, question.correctAnswer),
                child: Text(option),
              );
            }).toList(),

            const SizedBox(height: 20),

            if (_answerSelected)
              Text(
                _feedback,
                style: const TextStyle(fontSize: 18, color: Colors.blue),
              ),

            if (_answerSelected)
              ElevatedButton(
                onPressed: nextQuestion,
                child: const Text("Next Question"),
              ),
          ],
        ),
      ),
    );
  }
}
