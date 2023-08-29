import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:quizzler/API/API.dart';
import 'package:http/http.dart' as http;
import 'package:quizzler/API/question.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: QuizPage(
        isDialogShow: true,
      ),
    );
  }
}

class QuizPage extends StatefulWidget {
  final bool isDialogShow;
  QuizPage({required this.isDialogShow});

  @override
  State<QuizPage> createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  // first we need a boolean var representing waiting till the data is fetched
  bool is_loading = true;
  // index variable the first question is shown
  int index = 0;
  // the API response variable
  late APIResponse<List<Question>> _response;
  // answers list
  List<Widget> answers = [];
  // game ends
  bool end = false;

  Future<APIResponse<List<Question>>> getQuestions(String difficaulty) async {
    // This Function fetches question from opendb by default the difficaulty is easy

    Uri url = Uri.parse(
        "https://opentdb.com/api.php?amount=5&category=18&difficulty=$difficaulty&type=boolean");
    print(url);
    return await http.get(url, headers: {
      "Accept": "application/json",
      "content-type": "application/json"
    }).then((data) {
      print(data.statusCode);
      if (data.statusCode == 200) {
        List<Question> questions = [];
        Map<String, dynamic> jsonData = jsonDecode(data.body);
        for (var question in jsonData["results"]) {
          final q = Question.fromJson(question);
          questions.add(q);
        }
        if (questions.isEmpty) {
          return APIResponse(
              errorMessage: "No Questions for this yet", hasError: true);
        }
        return APIResponse(data: questions, hasError: false);
      } else {
        return APIResponse(
            hasError: true, errorMessage: "Something Went Wrong");
      }
    });
  }

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, () {
      this.getThings();
    });
    // getThings();
  }

  List<String> items = ["easy", "medium", "hard"];
  String diff = "easy";

  getThings() async {
    await showDialog(
      context: context,
      builder: (context) => Center(
        child: AlertDialog(
          backgroundColor: Color(0xFFF8FFDB),
          title: const Text(
            "Choose the difficaulty",
            style: TextStyle(color: Color(0xFFFF6464)),
          ),
          content: DropdownButtonFormField(
            value: diff,
            onChanged: (String? item) {
              setState(() {
                diff = item!;
              });
            },
            onSaved: ((newValue) {
              setState(() {
                diff = newValue!;
              });
            }),
            dropdownColor: Color(0xFFF8FFDB),
            items: items.map<DropdownMenuItem<String>>((value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          actions: [
            TextButton(
                onPressed: () {
                  _fetch(diff);
                  Navigator.pop(context);
                },
                child: const Text(
                  "Default",
                  style: TextStyle(color: Colors.red),
                )),
            TextButton(
              onPressed: () {
                _fetch(diff);
                Navigator.pop(context);
              },
              child: const Text(
                "Chosen",
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _fetch(String diff) async {
    setState(() {
      is_loading = true;
    });
    _response = await getQuestions(diff);
    setState(() {
      is_loading = false;
    });
  }

  _checkAnswer({required bool userAnswer}) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Quiz Me",
          style: TextStyle(color: Color(0xFFF8FFDB)),
        ),
        backgroundColor: const Color(0xFFFF7D7D),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF8FFDB),
      body: (is_loading)
          ? const Center(child: CircularProgressIndicator())
          : (_response.hasError)
              ? const Center(
                  child: Text("Error"),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                      Expanded(
                        flex: 3,
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10, right: 10),
                          child: Center(
                              child: Text(
                            _response.data![index].question,
                            style: const TextStyle(
                                color: Color(0xFF674747),
                                fontSize: 40,
                                fontWeight: FontWeight.bold),
                          )),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton(
                            child: Text(
                              "True",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all(
                                Color(0xFF98D8AA),
                              ),
                            ),
                            onPressed: () {
                              if (!end) {
                                if (_response.data![index].answer == true) {
                                  answers.add(const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  ));
                                } else {
                                  answers.add(const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ));
                                }
                              }

                              if (index == _response.data!.length - 1) {
                                setState(() {
                                  end = true;
                                });
                                answers.add(
                                  const Text(
                                    "Well Done 🎉🥳",
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              } else {
                                setState(() {
                                  index += 1;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextButton(
                            child: Text(
                              "False",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                            ),
                            style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(Color(0xFFFF6464)),
                            ),
                            onPressed: () {
                              if (!end) {
                                if (_response.data![index].answer == false) {
                                  answers.add(const Icon(
                                    Icons.check,
                                    color: Colors.green,
                                  ));
                                } else {
                                  answers.add(const Icon(
                                    Icons.cancel,
                                    color: Colors.red,
                                  ));
                                }
                              }

                              if (index == _response.data!.length - 1) {
                                setState(() {
                                  end = true;
                                });
                                answers.add(
                                  const Text(
                                    "Well Done 🎉🥳",
                                    style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold),
                                  ),
                                );
                              } else {
                                setState(() {
                                  index += 1;
                                });
                              }
                            },
                          ),
                        ),
                      ),
                      Row(
                        children: answers,
                      )
                    ]),
    );
  }
}
