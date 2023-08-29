class Question {
  String question;
  bool answer;

  Question({required this.question, required this.answer});

  Question.fromJson(Map<String, dynamic> json)
      : question = json['question'],
        answer = json['correct_answer'] == "True" ? true : false;

  Map<String, dynamic> toJson() => {
        'question': question,
        'correct_answer': answer,
      };
}
