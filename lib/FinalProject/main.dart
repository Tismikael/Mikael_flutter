/*
  Mikael Yikum
  Final Project
  Piano - Drums Simulator
*/
  

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'piano_ui.dart';
import 'drums_ui.dart';
import 'midi_controller.dart';
import 'instrument_mode.dart';

bool keyAssist = false;

// // method to toggle key assist
// void switchKeyAssist() {
//   keyAssist = !keyAssist;
// }

void main() {
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<PianoKeysAssistCubit>(
          create: (context) => PianoKeysAssistCubit(),
        ),
        BlocProvider<InstrumentCubit>(
          create: (context) => InstrumentCubit(),
        ),
        // BlocProvider<DrumsStickCubit>(
        //   create: (context) => DrumsStickCubit(),
        // )
      ],
      child: Provider<MidiController>(
        create: (context) => MidiController(),
        child: MaterialApp(
          title: "Piano Keys Simulator",
          theme: ThemeData.dark(),
          home: const Home(),
        ),
      ),
    );
  }
}


class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

// Piano Simulator initialization
  class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   title: const Text(
      //     'Piano Keys Simulator',
      //     style: TextStyle(color: Colors.white),
      //   ),
      //   backgroundColor: Colors.black87,
      // ),
      body: SingleChildScrollView(
        child:  Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              
              const PianoUI(),
            ],
          ),
      )
    );
  }
}  


// Second page initialization for Drums Simulator

class SecondHomeState extends StatelessWidget
{

  const SecondHomeState({super.key});

  @override
  Widget build(BuildContext context)

  {

    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      // appBar: AppBar(
      //   title: const Text(
      //     "Drums Simulator",
      //     style: TextStyle(color: Colors.white),
      //   ),
      //   backgroundColor: Colors.black87,
      // ),
      body: SingleChildScrollView(
        child:  Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              
              const DrumsUI(),
            ],
          ),
      )

 
    );
  }
}


  

 