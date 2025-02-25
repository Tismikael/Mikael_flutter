// quizzle dart
// Mikael Yikum

// Quizzle HW where user is asked to enter 
// US capitol based on state name 


import "package:flutter/foundation.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:hydrated_bloc/hydrated_bloc.dart";
import "dart:io";
import "dart:convert";
import "package:path_provider/path_provider.dart";
import "package:flutter/material.dart";
import "dart:math";

// Using info from https://stackoverflow.com/questions/44816042/flutter-read-text-file-from-assets
import "package:flutter/services.dart" show rootBundle;


// Create a Quiz class to store US states and capitols

class StateCapitols
{
  String state;
  String capitol;

  StateCapitols(this.state, this.capitol);

}


// QuizState class
class QuizState
{

  double score;       
  int total;      // total number of questions
  int currentQuestionNumber;  
  bool isFinished;    // to check if the game is finished
  
  QuizState(this.score, this.total, this.currentQuestionNumber, {this.isFinished = false});

  // turn the state into a map
  Map<String, dynamic> toMap() {
    return {
      'score': score,
      'total': total,
      'currentQuestionNumber': currentQuestionNumber,
      'isFinished': isFinished,
    };
  }

  // turn the map into a state
  factory QuizState.fromMap(Map<String, dynamic> map){
    return QuizState(map['score'], map['total'], map['currentQuestionNumber'], isFinished: map['isFinished']);
  }

  // turn the object into JSON
  String toJson() => json.encode(toMap);

  // turn the JSON into an object
  factory QuizState.fromJson(String source) => QuizState.fromMap(json.decode(source));

}


class QuizCubit extends HydratedCubit<QuizState> {
  QuizCubit() : super(QuizState(0, 10, 0, isFinished: false));

  List<StateCapitols> stateCapitols = [];
  // int totalQuestions = 10;
  bool isDataLoaded = false;

    List<int> randomNumbers = [];

    // function to generate 10 random numbers between 0 and 50
    void generateRandomNumbers() {
      if (stateCapitols.isEmpty) {
        return;
      }
      
      randomNumbers = [];
      Random random = Random();

      while (randomNumbers.length < state.total) {  
        int randomIndex = random.nextInt(stateCapitols.length);
        if (!randomNumbers.contains(randomIndex)) {
          randomNumbers.add(randomIndex);
        }

      }
    }

  Future<void> readData() async {
    try {
      // Load the file from assets folder
      String fileData = await rootBundle.loadString('assets/StateCapitols.txt');
      final lines = fileData.split('\n');

      // Read the file line by line from the second line
      for (int i = 1; i < lines.length; i++) {
        // Skip empty lines
        if (lines[i].trim().isEmpty) continue;

        // Split the line into state and capitol
        List<String> line = lines[i].split(",");

        if (line.length == 2) {
          // Create a StateCapitols object and add it to the list
          stateCapitols.add(StateCapitols(line[0].trim(), line[1].trim()));
        }
      }

      isDataLoaded = true;

      emit(QuizState(state.score, 10, state.currentQuestionNumber, isFinished: false));
    } catch (e) {
      print("Error loading file: $e");
    }
  }

  void checkAnswer(String stateQuestion, String answer) {
    // Turn the answer into lowercase
    answer = answer.toLowerCase();

    // Get the capitol from the stateQuestion
    String correctAnswer = stateCapitols
        .firstWhere((element) => element.state == stateQuestion).capitol;

    correctAnswer = correctAnswer.toLowerCase();

    // Check if the answer is correct
    if (answer == correctAnswer) {
      // Emit a new state with the updated score
      emit(QuizState(state.score + 1, state.total, state.currentQuestionNumber, isFinished: state.isFinished));
    } else {
      // Emit the same state if the answer is incorrect
      emit(QuizState(state.score, state.total, state.currentQuestionNumber, isFinished: state.isFinished));
    }
  }

  // function to go to the next question
  void nextQuestion() {
    if (state.currentQuestionNumber <  state.total) {
      emit(QuizState(state.score, state.total, state.currentQuestionNumber + 1, isFinished: false));
    } else {
      emit(QuizState(state.score, state.total, state.total, isFinished: true));
    }
    
  }

  // function to reset the quiz
  void reset() {
    // Reset the score and current question number
    emit(QuizState(0, state.total, 0, isFinished: false));
    generateRandomNumbers();

  }

  // function to calculate the final score in percentage
  double calculateScore() {
    // Calculate the percentage 
    return (state.score / state.total) * 100;

    // emit(QuizState(percentage, state.total, state.currentQuestionNumber));
  }

  // function to get the current question number
  int getCurrentQuestionNumber() {
    return min(state.currentQuestionNumber, state.total - 1);
  }

   // function to get current state
  String getCurrentState() {
    if (randomNumbers.isEmpty || getCurrentQuestionNumber() >= randomNumbers.length) {
      return "";
    }
    return stateCapitols[randomNumbers[getCurrentQuestionNumber()]].state;
  }
  

  @override
  QuizState? fromJson(Map<String, dynamic> json) {
    return QuizState.fromMap(json);
  }

  @override
  Map<String, dynamic>? toJson(QuizState state) {
    return state.toMap();
  }
}

// main function 
void main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // set up HydratedStore with web or local storage capabilities
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
  );

  runApp( Quizzle());
}


class Quizzle extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: "Quizzle",
      home: BlocProvider<QuizCubit>(
      create: (context) => QuizCubit(),
      child: BlocBuilder<QuizCubit, QuizState>(
        builder: (context, state) => QuizzleHome(),
      ),
      ),
    );
  }
}


class QuizzleHome extends StatelessWidget {
  final Random random = Random();
  final TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    QuizCubit qc = BlocProvider.of<QuizCubit>(context);
    QuizState qs = qc.state;

    return Scaffold(
      appBar: AppBar(
        title: Text("Quizzle"),
      ),
      body: BlocBuilder<QuizCubit, QuizState>(
        builder: (context, state) {
          // Check if data is loaded
          if (!qc.isDataLoaded) {
            qc.readData()
            .then((value) => {
              // Generate random numbers for questions
              qc.generateRandomNumbers(),
            });

          }


          // Check if all questions have been answered
          bool isQuizCompleted = qs.isFinished || qs.currentQuestionNumber >= qs.total;

          return Column(
            children: [
              // Welcome message
              Text("Welcome to Quizzle!", style: TextStyle(fontSize: 24)),
              Text("Lets play a game to test your knowledge of US State Capitals!",
                  style: TextStyle(fontSize: 24)),

              SizedBox(height: 20),

              Text("Enter the capital of the displayed text in the right text field below",
                  style: TextStyle(fontSize: 20)),
              SizedBox(height: 40),

              // Display the current question or final score if quiz is completed
              if (isQuizCompleted)

                Text("Quiz Completed! Final Score: ${qc.calculateScore().toStringAsFixed(0) }%",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))
              else
                Column(
                 children: [

                  // Display the current score and total questions
                  Text("Your Current Score: ${state.score} out of ${qc.state.total}",
                      style: TextStyle(fontSize: 24)),

                  SizedBox(height: 20),

                  Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          
                          // Display the current question
                          Text("Q${min(qc.getCurrentQuestionNumber() + 1, qc.state.total)} of ${qc.state.total}",
                              style: TextStyle(fontSize: 20)),

                          Container(width: 20),

                          // Display the question
                          Container(
                            height: 50,
                            width: 250,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              qc.getCurrentState(),
                              style: TextStyle(fontSize: 20)),
                          ),

                          Container(width: 20),

                          // Create input text field
                          Container(
                            height: 50,
                            width: 250,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1),
                            ),
                            alignment: Alignment.center,
                            child: TextField(
                              decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Enter capital here',
                              ),
                              controller: controller,
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ],
                      ),
                  ]),
                

              SizedBox(height: 20),

              // button to submit answer or restart quiz
              if (isQuizCompleted)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    qc.reset();
                    controller.clear();
                  },
                  child: Text("Restart Quiz"),
                )
              else

              Column(
                children: [
                  ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightGreen,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    if (qc.state.currentQuestionNumber < qc.state.total) {
                      qc.checkAnswer(
                          qc.getCurrentState(),
                          controller.text);
                      qc.nextQuestion();
                      controller.clear();
                    }
                  },
                  child: Text("Submit"),

                ),

                SizedBox(height: 50),

                // button to reset the quiz
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    qc.reset();
                    controller.clear();
                  },
                  child: Text("Restart Game"),
                ),
                
              ])

            ],
          );
        },
      ),
    );
  }
}

