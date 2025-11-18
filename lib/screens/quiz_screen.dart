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
        _feedback = "✅ Correct! The answer is $correct.";
      } else {
        _feedback = "❌ Incorrect. The correct answer is $correct.";
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

  void restartQuiz() {
    setState(() {
      _currentIndex = 0;
      _score = 0;
      _feedback = "";
      _answerSelected = false;
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
        appBar: AppBar(
          title: const Text("Quiz Completed"),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "🎉 Your Score",
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              Text(
                "$_score / ${_questions.length}",
                style: const TextStyle(fontSize: 24),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: restartQuiz,
                child: const Text("Restart Quiz"),
              ),
            ],
          ),
        ),
      );
    }

    final question = _questions[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: Text("Question ${_currentIndex + 1} / ${_questions.length}"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  question.question,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 20),

            ...question.options.map((option) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => checkAnswer(option, question.correctAnswer),
                  child: Text(option),
                ),
              );
            }),

            const SizedBox(height: 20),

            if (_answerSelected)
              Card(
                color: Colors.blue.shade50,
                elevation: 2,
                margin: const EdgeInsets.only(top: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _feedback,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),

            if (_answerSelected)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: nextQuestion,
                  child: const Text("Next Question"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
