import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:provider/provider.dart";
import 'midi_controller.dart';
import 'instrument_mode.dart';
import 'main.dart';

List<String> whiteKeysAssist = ["z", "x", "c", "v", "b", "n", "m",
                            ",", ".", "/", "RS", "l", ";", "RET",
                            "a", "s", "d", "f", "g", "h", "j", "k"];

List<String> blackKeysAssist = ["o", "p", "", "[", "]","\\", "",
                                "q", "w", "", "e", "r", "t", "",
                                 "8", "9", "", "0", "-","=", "",
                                 "",""];

// following two sets of numbers are associated with piano notes
List<int> whiteKeysNumbers = [48, 50, 52, 53, 55, 57, 59, 60, 
                               62, 64, 65, 67, 69, 71, 72,
                                74, 76, 77, 79, 81, 83, 84];


final Map<int, int> blackKeysNumbers = {
  0: 49,
  1: 51,
  3: 54,
  4: 56,
  5: 58,
  7: 61,
  8: 63,
  10: 66,
  11: 68,
  12: 70,
  14: 73,
  15: 75,
  17: 78,
  18: 80,
  19: 82,
};

// WHITE KEYS
class WhiteKey extends Container {


    WhiteKey (String keyAssistNote, {bool isPressed = false}) :
     super (
        width: 50,
        height: 200,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: isPressed ? Colors.grey[400] : Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Text(keyAssistNote, style: const TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
        )
        
     );

    //  bool switchNoteColor(bool isPressedValue){
    //     return !isPressedValue;
    //  }
}

// BLACK KEYS
class BlackKey extends Container {

    BlackKey (String keyAssistNote, {bool isPressed = false}) :
     super (
        width: 40,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.rectangle,
          color: isPressed ? Colors.grey[700] : Colors.black,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Text(keyAssistNote, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold), textAlign: TextAlign.center,),
        )
     );
}

class PianoKeysAssistState{
  bool isKeysAssistOn = false;
  late List<String> whiteKeys;
  late List<String> blackKeys;

  late WhiteKey wKey;
  late BlackKey bKey;

  PianoKeysAssistState({required this.isKeysAssistOn, required this.whiteKeys, required this.blackKeys, required this.wKey, required this.bKey});
}

class PianoKeysAssistCubit extends Cubit<PianoKeysAssistState> {
    PianoKeysAssistCubit() : super(PianoKeysAssistState(isKeysAssistOn: false, whiteKeys: whiteKeysAssist, blackKeys: blackKeysAssist, wKey: WhiteKey(""), bKey: BlackKey("")));


  // method to switch key assist state 
  void switchKeyAssistState(){
    emit(PianoKeysAssistState(isKeysAssistOn: !state.isKeysAssistOn, whiteKeys: state.whiteKeys, blackKeys: state.blackKeys, wKey: state.wKey, bKey: state.bKey));
  }

}



List<String> effects = ["grand", "e piano", "strings", "bass", "trumpet", "guitar"];


class SoundEffect extends StatelessWidget {

  final String soundEffect;

  SoundEffect({super.key, required this.soundEffect});

  @override
  Widget build(BuildContext context){

    final isToggled = context.select<EffectCubit, bool>(
      (cubit) => cubit.state.isToggled[soundEffect] ?? false
    );

    final isDualMode = context.select<EffectCubit, bool>(
      (cubit) => cubit.state.isDualMode
    );

    final dualModeSelection = context.select<EffectCubit, List<String>>(
      (cubit) => cubit.state.dualModeSelection
    );

    // Determine position in dual mode (first or second instrument)
    int position = dualModeSelection.indexOf(soundEffect);
    String positionLabel = '';
    
    // if (isDualMode && isToggled) {
    //   // In dual mode, show which half of the keyboard this instrument affects
    //   positionLabel = position == 0 ? "(Lower)" : "(Upper)";
    // }


     MidiController midiController = Provider.of<MidiController>(context, listen: false);

    return GestureDetector(
      onTap: () {
        context.read<EffectCubit>().toggleEffect(soundEffect);

        // Get the updated selection after toggling
        final updatedSelection = context.read<EffectCubit>().state.dualModeSelection;
        final isDualModeActive = context.read<EffectCubit>().state.isDualMode;
        
        // Update the midi controller
        if (isDualModeActive) {
          midiController.setDualMode(true);
          midiController.updateDualModeInstruments(updatedSelection);
        } else {
          midiController.setDualMode(false);
          midiController.selectInstrument(soundEffect);
        }

      },
      child: Column(
        children: [
          Text(soundEffect,
               style: TextStyle(
                color: Colors.white,
                fontStyle: FontStyle.italic
                
               ),),
          SizedBox(height: 2,),
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: isToggled ? Colors.green[50] : Colors.green[800],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                width: 2,
                color: isToggled? Colors.white : Colors.black),
            ),
          )
        ]
      )
    );

  }
}


class EffectState {
  Map<String, bool> isToggled = {};

  late bool isDualMode = false;
  late bool isSustainOn = false;

  late List<String> dualModeSelection = [];

  EffectState({required this.isToggled, required this.isDualMode, required this.isSustainOn, required this.dualModeSelection});
}


class EffectCubit extends Cubit<EffectState> {
  EffectCubit() : super(EffectState(isToggled: {
            "grand": true,     // set to default
            "e piano": false,
            "strings": false,
            "bass": false,
            "trumpet": false,
            "guitar": false,
          }, 
          isDualMode: false,
          isSustainOn: false,
          dualModeSelection: ["grand"]));
          


  void toggleEffect(String effect) {

    // create a copy of current map
    Map<String, bool> newMap = Map.from(state.isToggled);
    List<String> newSelection = List.from(state.dualModeSelection);

    // set the current toggled effect to false
    if (!state.isDualMode) {
      for (String key in newMap.keys){
        if (key != effect){
          newMap[key] = false;
        } else {
          newMap[key] = !newMap[key]!;
        }
      }

      newSelection = newMap[effect] == true ? [effect] : [];
    } else {


      // Dual mode
      if (newMap[effect] == true) {
        // If already selected, deselect it
        newMap[effect] = false;
        newSelection.remove(effect);
      } else {
        // If not selected, select it
        if (newSelection.length < 2) {
          newMap[effect] = true;
          newSelection.add(effect);
        } else {
          // Already have 2 selections
          String oldestEffect = newSelection.removeAt(0);
          newMap[oldestEffect] = false;
          newMap[effect] = true;
          newSelection.add(effect);
        }
      }

    }

    // update state
    emit(EffectState(isToggled: newMap, isDualMode: state.isDualMode, isSustainOn: state.isSustainOn, dualModeSelection: newSelection));
      
  }

  void setDualMode(bool isDualMode){
    Map<String, bool> newMap = Map.from(state.isToggled);
    List<String> newSelection = List.from(state.dualModeSelection);


    if (!isDualMode && newSelection.length > 1){

      String latestChoice = newSelection.last;

      for (String key in newMap.keys){
        newMap[key] = (key == latestChoice);
      }

      newSelection = [latestChoice];
      
    } else if (isDualMode && newSelection.isEmpty){

      newMap["grand"] = true;
      newSelection.add("grand");
      
    }
    
    emit(EffectState(isToggled: newMap, isDualMode: isDualMode, isSustainOn: state.isSustainOn, dualModeSelection: newSelection));
  }

  // method to set all effects to false
  void resetEffects() {

    // create a copy of current map
    Map<String, bool> newMap = Map.from(state.isToggled);

    // set the current toggled effect to false
    for (String key in newMap.keys){
      newMap[key] = false;
    }

    emit(EffectState(isToggled: newMap, isDualMode: true, isSustainOn: state.isSustainOn, dualModeSelection: [] ));
  }

  // method to set sustain effect on
  void toggleSustainEffect(){
    emit(EffectState(isToggled: state.isToggled, isDualMode: state.isDualMode, isSustainOn: !state.isSustainOn, dualModeSelection: state.dualModeSelection));
  }

}


class DualModeEffect extends StatelessWidget {

  final String mode;

  DualModeEffect({super.key, required this.mode});

  @override
  Widget build(BuildContext context){

    final isToggled = context.select<EffectCubit, bool>(
      (cubit) => cubit.state.isDualMode
    );

    final selections = context.select<EffectCubit, List<String>>(
      (cubit) => cubit.state.dualModeSelection
    );

    final MidiController midiController = Provider.of<MidiController>(context, listen: false);

    return GestureDetector(
      onTap: () {

        final effectCubit = context.read<EffectCubit>();
        effectCubit.setDualMode(!isToggled);

        midiController.setDualMode(!isToggled);
        midiController.updateDualModeInstruments(effectCubit.state.dualModeSelection);
      },
      child: Column(
        children: [
          Text(mode,
              style: TextStyle(color: Colors.white, fontSize: 20), textAlign: TextAlign.center,),
          SizedBox(height: 2,),
          Container(
            width: 100,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: isToggled ? Colors.green[50] : Colors.green[800],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(width: 2, color: Colors.black),
            ),
          )
        ],
      )
    );
  }
}

class SustainEffect extends StatelessWidget {
  const SustainEffect({super.key});

  @override
  Widget build(BuildContext context){
    final isToggled = context.select<EffectCubit, bool>(
      (cubit) => cubit.state.isSustainOn
    );

    final MidiController midiController = Provider.of<MidiController>(context, listen: false);

    return Column(
      children: [
        Text("Sustain", style: TextStyle(color: Colors.white, fontSize: 20), textAlign: TextAlign.center,),
        SizedBox(height: 2,),
        GestureDetector(
          onTap: () {
            final effectCubit = context.read<EffectCubit>();
            effectCubit.toggleSustainEffect();
            midiController.sustainDuration = isToggled? Duration(milliseconds: 500) : Duration(seconds: 3);
          },
          child: Container(
            width: 100,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              color: isToggled ? Colors.green[50] : Colors.green[800],
              borderRadius: BorderRadius.circular(4),
              border: Border.all(width: 2, color: Colors.black)
            ),
          )
        )
      ]
    );
  }
}

// -----------------------------------------------------

// PIANO COVER
class PianoCover extends StatelessWidget {

  const PianoCover({super.key});

  @override
  Widget build(BuildContext context){
    return Column(
      children: [

        Stack( 
          children: [
            Container(
              width: 1130,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(2),
              )
            ),

            Positioned(
              left: 200, 
              top: 3,
              child: Column(
                children: [
                  Row(
                    children: [
                      SoundEffect(soundEffect: effects[0]),
                      SizedBox(width: 5),
                      SoundEffect(soundEffect: effects[1]),
                      SizedBox(width: 5),
                      SoundEffect(soundEffect: effects[2]),
                    ],
                  ),
                  Row(
                    children: [
                      SoundEffect(soundEffect: effects[3]),
                      SizedBox(width: 10),
                      SoundEffect(soundEffect: effects[4]),
                      SizedBox(width: 5),
                      SoundEffect(soundEffect: effects[5]),
                    ],
                  ),

                ],
              ),
            ),

            Positioned(
              left: 450, 
              top: 3,
              child: DualModeEffect(mode: "Dual Mode"),
              
            ),

            Positioned(
              left: 600,
              top: 3,
              child: SustainEffect(),
            ),


          ],
        ),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              width: 0,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(4),),
            ),

            Container(
              width: 0,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                color: Colors.grey[850],
                borderRadius: BorderRadius.circular(4),),
            ),

          ]
        )


      ]
    );
  }
}

// -----------------------------------------------------

// method to map key pressed on keyboard to note
Map<String, int> keyToNote(LogicalKeyboardKey key){

  Map<String, int> noteMap = {};
  switch(key){
    case LogicalKeyboardKey.keyZ:
       noteMap['z'] = 0;
       break;
    case LogicalKeyboardKey.keyX:
       noteMap['x'] = 0;
       break;
    case LogicalKeyboardKey.keyC:
       noteMap['c'] = 0;
       break;
    case LogicalKeyboardKey.keyV:
       noteMap['v'] = 0;
       break;
    case LogicalKeyboardKey.keyB:
       noteMap['b'] = 0;
       break;
    case LogicalKeyboardKey.keyN:
       noteMap['n'] = 0;
       break;
    case LogicalKeyboardKey.keyM:
       noteMap['m'] = 0;
       break;
    case LogicalKeyboardKey.comma:
       noteMap[','] = 0;
       break;
    case LogicalKeyboardKey.period:
       noteMap['.'] = 0;
       break;
    case LogicalKeyboardKey.slash:
       noteMap['/'] = 0;
       break;
    case LogicalKeyboardKey.shiftRight:
      noteMap['RS'] = 0;
      break;
    case LogicalKeyboardKey.keyL:
      noteMap['l'] = 0;
    case LogicalKeyboardKey.semicolon:
      noteMap[';'] = 0;
      break;
    case LogicalKeyboardKey.enter:
      noteMap['RET'] = 0;
      break;
    case LogicalKeyboardKey.keyA: 
      noteMap['a'] = 0;
      break;
    case LogicalKeyboardKey.keyS:
      noteMap['s'] = 0;
      break;
    case LogicalKeyboardKey.keyD:
      noteMap['d'] = 0;
      break;
    case LogicalKeyboardKey.keyF:
      noteMap['f'] = 0;
      break;
    case LogicalKeyboardKey.keyG:
      noteMap['g'] = 0;
      break;
    case LogicalKeyboardKey.keyH:
      noteMap['h'] = 0;
      break;
    case LogicalKeyboardKey.keyJ:
      noteMap['j'] = 0;
      break;
    case LogicalKeyboardKey.keyK:
      noteMap['k'] = 0;
      break;
    case LogicalKeyboardKey.keyO:
      noteMap['o'] = 1;
      break;
    case LogicalKeyboardKey.keyP:
      noteMap['p'] = 1;
      break;
    case LogicalKeyboardKey.bracketLeft:
      noteMap['['] = 1;
      break;
    case LogicalKeyboardKey.bracketRight:
      noteMap[']'] = 1;
      break;
    case LogicalKeyboardKey.backslash:
      noteMap['\\'] = 1;
      break;
    case LogicalKeyboardKey.keyQ:
      noteMap['q'] = 1;
      break;
    case LogicalKeyboardKey.keyW:
      noteMap['w'] = 1;
      break;
    case LogicalKeyboardKey.keyE:
      noteMap['e'] = 1;
      break;
    case LogicalKeyboardKey.keyR:
      noteMap['r'] = 1;
      break;
    case LogicalKeyboardKey.keyT:
      noteMap['t'] = 1;
      break;
    case LogicalKeyboardKey.digit8:
      noteMap['8'] = 1;
      break;
    case LogicalKeyboardKey.digit9:
      noteMap['9'] = 1;
      break;
    case LogicalKeyboardKey.digit0:
      noteMap['0'] = 1;
      break;
    case LogicalKeyboardKey.minus:
      noteMap['-'] = 1;
      break;
    case LogicalKeyboardKey.equal:
      noteMap['='] = 1;
      break;

    default:
      return {};
  }

  return noteMap;
}


// PIANO KEYBOARD IMPLEMENTATION

class KeyboardState {
  final Map<int, bool> pressedKeys;

  KeyboardState({required this.pressedKeys});

}

class KeyboardCubit extends Cubit<KeyboardState> {
  KeyboardCubit() : super(KeyboardState(pressedKeys: {}));


  // method to press a key
  void pressKey(int key){
    final newPressedKeys = Map<int, bool>.from(state.pressedKeys);
    newPressedKeys[key] = true;
    emit(KeyboardState(pressedKeys: newPressedKeys));
  }

  // method to release a key
  void releaseKey(int key){
    final newPressedKeys = Map<int, bool>.from(state.pressedKeys);
    newPressedKeys[key] = false;
    emit(KeyboardState(pressedKeys: newPressedKeys));
  }

  // method to check if a key has been pressed
  bool isKeyPressed(int key){
    return state.pressedKeys[key] ?? false;
  }
}
class PianoKeyboard extends StatelessWidget {
  const PianoKeyboard({super.key});

  void pressKeyboardKey(KeyEvent event, MidiController midiController, KeyboardCubit keyboardCubit) async {
    Map<String, int> noteToPlay = {};

    if (event.logicalKey == LogicalKeyboardKey.quote) {
      noteToPlay["'"] = 0;
    } else {
      noteToPlay = keyToNote(event.logicalKey);
    }

    if (noteToPlay.isEmpty) return;

    final key = noteToPlay.values.first == 0
        ? whiteKeysNumbers[whiteKeysAssist.indexOf(noteToPlay.keys.toList().first)]
        : blackKeysNumbers[blackKeysAssist.indexOf(noteToPlay.keys.toList().first)];

    if (key == null) return;

    if (event is KeyDownEvent) {
      keyboardCubit.pressKey(key);
      midiController.playNote(key);
    } else if (event is KeyUpEvent) {
      keyboardCubit.releaseKey(key);
      midiController.stopNote(key);
    }
  }

  @override
  Widget build(BuildContext context) {
    final midiController = Provider.of<MidiController>(context, listen: false);
    final keyboardCubit = context.read<KeyboardCubit>();
    final focusNode = FocusNode();

    return BlocBuilder<PianoKeysAssistCubit, PianoKeysAssistState>(
      builder: (context, keysAssistState) {
        return BlocBuilder<KeyboardCubit, KeyboardState>(
          builder: (context, keyboardState) {
            return Focus(
              focusNode: focusNode,
              autofocus: true,
              onKeyEvent: (node, event) {
                pressKeyboardKey(event, midiController, keyboardCubit);
                return KeyEventResult.handled;
              },
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  children: [
                    SizedBox(height: 145),
                    Stack(
                      children: [
                        // Row of white keys
                        Row(
                          children: List.generate(
                            22,
                            (i) => GestureDetector(
                              onTapDown: (_) {
                                keyboardCubit.pressKey(whiteKeysNumbers[i]);
                                midiController.playNote(whiteKeysNumbers[i]);
                              },
                              onTapUp: (_) {
                                keyboardCubit.releaseKey(whiteKeysNumbers[i]);
                                midiController.stopNote(whiteKeysNumbers[i]);
                              },
                              onTapCancel: () {
                                keyboardCubit.releaseKey(whiteKeysNumbers[i]);
                                midiController.stopNote(whiteKeysNumbers[i]);
                              },
                              child: Container(
                                width: 50,
                                child: Padding(
                                  padding: const EdgeInsets.all(1.0),
                                  child: WhiteKey(
                                    keysAssistState.isKeysAssistOn ? keysAssistState.whiteKeys[i] : "",
                                    isPressed: keyboardState.pressedKeys[whiteKeysNumbers[i]] ?? false,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),

                        // Row of black keys layered above
                        Row(
                          children: [
                            const SizedBox(width: 18),
                            ...List.generate(22, (i) {
                              const blackKeysPlacement = [0, 1, 3, 4, 5, 7, 8, 10, 11, 12, 14, 15, 17, 18, 19];

                              if (blackKeysPlacement.contains(i)) {
                                return GestureDetector(
                                  onTapDown: (_) {
                                    keyboardCubit.pressKey(blackKeysNumbers[i]!);
                                    midiController.playNote(blackKeysNumbers[i]!);
                                  },
                                  onTapUp: (_) {
                                    keyboardCubit.releaseKey(blackKeysNumbers[i]!);
                                    midiController.stopNote(blackKeysNumbers[i]!);
                                  },
                                  onTapCancel: () {
                                    keyboardCubit.releaseKey(blackKeysNumbers[i]!);
                                    midiController.stopNote(blackKeysNumbers[i]!);
                                  },
                                  child: Container(
                                    width: 50,
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 15.0),
                                      child: BlackKey(
                                        keysAssistState.isKeysAssistOn ? keysAssistState.blackKeys[i] : "",
                                        isPressed: keyboardState.pressedKeys[blackKeysNumbers[i]!] ?? false,
                                      ),
                                    ),
                                  ),
                                );
                              } else {
                                return const SizedBox(width: 50);
                              }
                            }),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// -----------------------------------------------------

// COMPLETED PIANO UI
class PianoUI extends StatelessWidget {
  const PianoUI({super.key});

  @override
  Widget build(BuildContext context) {

    InstrumentCubit ic = BlocProvider.of<InstrumentCubit>(context);

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => EffectCubit()),
        BlocProvider(create: (context) => KeyboardCubit()),
        BlocProvider(create: (context) => PianoKeysAssistCubit()),
        BlocProvider(create:(context) => InstrumentCubit(),),
        
      ],

      child: Column(
        children: [
        BlocBuilder<PianoKeysAssistCubit, PianoKeysAssistState>(
            builder: (context, keysAssistState) {
              return BlocBuilder<InstrumentCubit, InstrumentState>(
                builder: (context, instrumentState) {
                  return LayoutBuilder(
                    builder: (context, constraints){
                      // final sizeFactor = constraints.maxWidth / 1000;

                      return   
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Align(
                                        alignment: Alignment.topLeft,
                                        child: 
                                          Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.grey[900],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                              onPressed: () {
                                                // context.read<KeysAssistCubit>().switchKeyAssistState();
                                                ic.togglePianoMode();
                                                Navigator.of(context).push
                                                ( MaterialPageRoute 
                                                (builder:(context) => SecondHomeState()),
                                                );
                                              },
                                              child: Text(
                                                "Switch to Drums",
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          ),
                                      ),

                                      BlocBuilder<PianoKeysAssistCubit, PianoKeysAssistState>(
                                        builder: (context, pianoKeysAssistState){
                                          return  Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: Colors.grey[900],
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius: BorderRadius.circular(10),
                                                  ),
                                                ),
                                                onPressed: () {
                                                  context.read<PianoKeysAssistCubit>().switchKeyAssistState();
                                                },
                                                child: Text(
                                                  'Key Assist ${keysAssistState.isKeysAssistOn ? 'On' : 'Off'}',
                                                  style: const TextStyle(color: Colors.white),
                                                ),
                                              ),
                                            );
                                        }
                                      ),

                                ]
 
                              )
                            ]
                          );            
                
                    }
                    
                    );
                }
              );
              
            },
          ),

         Stack(
              alignment: Alignment.topCenter,
              children: [
                Center(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: PianoKeyboard(),
                  ),
                ),
                const PianoCover(),
              ],
            )
                  
        ],
      )
    );
  }
}



  