// CalcMikael.dart
// Mikael Yikum
// Converter HW

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";


// Create converter state and cubit classes for calculating temperature and weight
class ConverterState {
  double input;
  double output;

  ConverterState(this.input, this.output);
}

class ConverterCubit extends Cubit<ConverterState> {
  ConverterCubit() : super(ConverterState(0, 0));

  // function to convert from celsius to fahrenheit
  void convertCelsiusToFahrenheit(double input) {
    double F = ((9 / 5) * input) + 32;
    emit(ConverterState(input, F));
  }

  // function to convert from fahrenheit to celsius
  void convertFarenheitToCelsius(double input){
    double C = (input - 32) * (5 / 9);
    emit(ConverterState(input, C));
  }

  // function to convert from kilograms to pounds
  void convertKilogramsToPounds(double input){
    double LB = input * 2.2046;
    emit(ConverterState(input, LB));
  }

  // function to convert from pounds to kilograms
  void convertPoundsToKilograms(double input){
    double KG = input / 2.2046;
    emit(ConverterState(input, KG));
  }

}

void main() {
  runApp(Converter());
}


class Converter extends StatelessWidget {
  Converter({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Converter",
      home: BlocProvider<ConverterCubit>(
        create: (context) => ConverterCubit(),
        child: BlocBuilder<ConverterCubit, ConverterState>(
          builder: (context, state) => ConverterHome(),
        ),
      ),
    );
  }
}

class ConverterHome extends StatelessWidget {
  ConverterHome({super.key});

  TextEditingController controller = TextEditingController();

  // List of button options
  List<String> options = ["7", "8", "9", "4", "5", "6", "1", "2", "3", ".", "0", "-"];
  // List of conversion options
  List<String> ConversionOptions = ["C-F", "F-C", "Kg-Lb", "Lb-Kg"];

  @override
  Widget build(BuildContext context) {

    ConverterState cs = BlocProvider.of<ConverterCubit>(context).state;
    ConverterCubit cc = BlocProvider.of<ConverterCubit>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text("Converter"),
      ),
      body: Column(
        children: [
          // Create a row of textfields for input and output

          // input textfield
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 50,
                width: 170,
                decoration: BoxDecoration(
                  border: Border.all(width: 1),
                ),
                child: TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
              ),

              Container(width: 50), // spacing

              // output textfield
              Container(
                height: 50,
                width: 200,
                decoration: BoxDecoration(
                  border: Border.all(width: 1),
                ),
                child: Text(
                  cs.output.toStringAsFixed(2),  // set to 2 decimal places
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20),
                ),
                
              ),
            ],
          ),

          Container(height: 20), // spacing

          // Create a row to hold number buttons and conversion options
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Number buttons (keypad)
              Column(
                children: [
                  // Create a 4 x 3 grid of number buttons
                  for (int i = 0; i < options.length; i += 3) // loop for 4 times
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int j = 0; j < 3 && (i + j) < options.length; j++) // loop for 3 times
                          Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(width: 3, color: Colors.black), 
                                borderRadius: BorderRadius.circular(2),
                              ),
                              child: FloatingActionButton(
                                child: Text(options[i + j], style: TextStyle(fontSize: 20)),
                                // add number to input string via controller
                                onPressed: () => controller.text += options[i + j],
                              ),
                            ),
                          ),
                      ],
                    ),
                ],
              ),

              Container(width: 20),    // spacing

              // Conversion options
              Column(
                  children: [
                    Container(height: 20),  
                    // iterate through conversion options
                    for (int i = 0; i < ConversionOptions.length; i++)
                      SizedBox(
                        height: 50, 
                        width: 200, 
                        child: FloatingActionButton.extended(
                          onPressed: () {
                            // convert input string to input double 
                            double input = double.parse(controller.text);
                            
                            //select conversion option based on button pressed 
                            switch (i) {
                              case 0:     // C - F
                                cc.convertCelsiusToFahrenheit(input);
                                break;

                              case 1:     // F - C
                                cc.convertFarenheitToCelsius(input);
                                break;

                              case 2:     // Kg - Lb
                                cc.convertKilogramsToPounds(input);
                                break;

                              case 3:     // Lb - Kg
                                cc.convertPoundsToKilograms(input);
                                break;
                                
                            }
                          },
                          label: Text(
                            ConversionOptions[i],
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                          backgroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(width: 2, color: Colors.black), 
                          ),
                        ),
                      ),
                  ],
                ),
             
            ],
          ),
        ],
      ),
    );
  }
}

