import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/question.dart';

class ApiService {
  static const String apiUrl =
      "https://opentdb.com/api.php?amount=10&category=9&difficulty=easy&type=multiple";

  static Future<List<Question>> fetchQuestions() async {
    final response = await http.get(Uri.parse(apiUrl));
    if (response.statusCode == 200) {
      final decodedData = json.decode(response.body);
      final List results = decodedData["results"];
      return results.map((q) => Question.fromJson(q)).toList();
    } else {
      throw Exception("Failed to load questions");
    }
  }
}
