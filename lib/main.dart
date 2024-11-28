import 'package:flutter/material.dart';
import 'quiz_service.dart';
import 'quiz_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trivia Quiz App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const QuizSetupScreen(),
    );
  }
}

class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  int numberOfQuestions = 5;
  String selectedCategory = 'Any Category';
  String difficulty = 'easy';
  String questionType = 'multiple';

  final List<String> difficulties = ['easy', 'medium', 'hard'];
  final List<String> types = ['multiple', 'boolean'];
  // We'll fetch these categories from the API later
  // final List<String> categories = [ ... ];

  final QuizService _quizService = QuizService();
  bool _isLoading = false;
  List<Category> _categories = [];
  Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _quizService.getCategories();
      setState(() {
        _categories = categories;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading categories: $e')),
      );
    }
  }

  Future<void> _startQuiz() async {
    setState(() => _isLoading = true);

    try {
      final questions = await _quizService.getQuestions(
        amount: numberOfQuestions,
        difficulty: difficulty,
        type: questionType,
        categoryId: _selectedCategory?.id,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => QuizScreen(questions: questions),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading questions: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Setup'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            DropdownButtonFormField<int>(
              value: numberOfQuestions,
              decoration: const InputDecoration(labelText: 'Number of Questions'),
              items: [5, 10, 15].map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value Questions'),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  numberOfQuestions = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Category>(
              value: _selectedCategory,
              decoration: const InputDecoration(labelText: 'Category'),
              items: [
                DropdownMenuItem<Category>(
                  value: null,
                  child: Text('Any Category'),
                ),
                ..._categories.map((Category category) {
                  return DropdownMenuItem<Category>(
                    value: category,
                    child: Text(category.name),
                  );
                }).toList(),
              ],
              onChanged: (newValue) {
                setState(() {
                  _selectedCategory = newValue;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: difficulty,
              decoration: const InputDecoration(labelText: 'Difficulty'),
              items: difficulties.map((String difficulty) {
                return DropdownMenuItem<String>(
                  value: difficulty,
                  child: Text(difficulty.capitalize()),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  difficulty = newValue!;
                });
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: questionType,
              decoration: const InputDecoration(labelText: 'Question Type'),
              items: types.map((String type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type == 'multiple' ? 'Multiple Choice' : 'True/False'),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  questionType = newValue!;
                });
              },
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: _isLoading ? null : _startQuiz,
              child: _isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Start Quiz'),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
