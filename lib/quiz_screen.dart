import 'package:flutter/material.dart';
import 'quiz_service.dart';
import 'results_screen.dart';

class QuizScreen extends StatefulWidget {
  final List<Question> questions;

  const QuizScreen({super.key, required this.questions});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentQuestionIndex = 0;
  int score = 0;
  bool answered = false;
  late List<String> shuffledAnswers;
  int timeLeft = 15;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _loadQuestion();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  void _loadQuestion() {
    if (currentQuestionIndex < widget.questions.length) {
      setState(() {
        answered = false;
        shuffledAnswers = [
          widget.questions[currentQuestionIndex].correctAnswer,
          ...widget.questions[currentQuestionIndex].incorrectAnswers,
        ]..shuffle();
        timeLeft = 15;
      });
      _startTimer();
    }
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (_disposed || !mounted) return;
      
      setState(() {
        if (timeLeft > 0 && !answered) {
          timeLeft--;
          _startTimer();
        } else if (timeLeft == 0 && !answered) {
          _handleTimeUp();
        }
      });
    });
  }

  void _handleAnswer(String? selectedAnswer) {
    if (answered) return;

    setState(() {
      answered = true;
      if (selectedAnswer == widget.questions[currentQuestionIndex].correctAnswer) {
        score++;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Correct!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Incorrect! The correct answer was: ${widget.questions[currentQuestionIndex].correctAnswer}',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      
      if (currentQuestionIndex < widget.questions.length - 1) {
        setState(() {
          currentQuestionIndex++;
          _loadQuestion();
        });
      } else {
        _showResults();
      }
    });
  }

  void _handleTimeUp() {
    if (!answered) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Time\'s up!'),
          backgroundColor: Colors.orange,
        ),
      );
      _handleAnswer(null);
    }
  }

  void _showResults() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultsScreen(
          score: score,
          totalQuestions: widget.questions.length,
          questions: widget.questions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final question = widget.questions[currentQuestionIndex];
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LinearProgressIndicator(
              value: (currentQuestionIndex + 1) / widget.questions.length,
            ),
            const SizedBox(height: 16),
            Text(
              'Question ${currentQuestionIndex + 1}/${widget.questions.length}',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Time left: $timeLeft seconds',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              'Score: $score',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 24),
            Text(
              question.question,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            ...shuffledAnswers.map((answer) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: ElevatedButton(
                onPressed: answered ? null : () => _handleAnswer(answer),
                style: ElevatedButton.styleFrom(
                  backgroundColor: answered
                      ? answer == question.correctAnswer
                          ? Colors.green
                          : Colors.red
                      : null,
                ),
                child: Text(answer),
              ),
            )),
          ],
        ),
      ),
    );
  }
}
