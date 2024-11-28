import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html_unescape/html_unescape.dart';

class Category {
  final int id;
  final String name;

  Category({required this.id, required this.name});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Question {
  static final _unescape = HtmlUnescape();
  
  final String question;
  final String correctAnswer;
  final List<String> incorrectAnswers;
  final String type;
  final String difficulty;
  final String category;

  Question({
    required this.question,
    required this.correctAnswer,
    required this.incorrectAnswers,
    required this.type,
    required this.difficulty,
    required this.category,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: _unescape.convert(json['question']),
      correctAnswer: _unescape.convert(json['correct_answer']),
      incorrectAnswers: List<String>.from(
        json['incorrect_answers'].map((x) => _unescape.convert(x))
      ),
      type: json['type'],
      difficulty: json['difficulty'],
      category: json['category'],
    );
  }
}

class QuizService {
  static const String _baseUrl = 'https://opentdb.com';

  Future<List<Category>> getCategories() async {
    final response = await http.get(Uri.parse('$_baseUrl/api_category.php'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return (data['trivia_categories'] as List)
          .map((category) => Category.fromJson(category))
          .toList();
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<List<Question>> getQuestions({
    required int amount,
    int? categoryId,
    String? difficulty,
    String? type,
  }) async {
    final queryParameters = {
      'amount': amount.toString(),
      if (categoryId != null) 'category': categoryId.toString(),
      if (difficulty != null) 'difficulty': difficulty,
      if (type != null) 'type': type,
    };

    final uri = Uri.parse('$_baseUrl/api.php').replace(queryParameters: queryParameters);
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      
      if (data['response_code'] != 0) {
        throw Exception('No questions available for these criteria');
      }
      
      return (data['results'] as List)
          .map((question) => Question.fromJson(question))
          .toList();
    } else {
      throw Exception('Failed to load questions');
    }
  }
}
