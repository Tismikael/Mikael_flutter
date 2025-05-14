import "dart:math";

import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:audioplayers/audioplayers.dart";
import "package:provider/provider.dart";

// // State class
// class DrumsStickState {
//   final bool isSwinging;
//   final double swingAngle;

//   DrumsStickState({required this.isSwinging, this.swingAngle = 0.0});
// }

// // Cubit class
// class DrumsStickCubit extends Cubit<DrumsStickState> {
//   DrumsStickCubit() : super(DrumsStickState(isSwinging: false, swingAngle: 0.0));
  
//   // method to toggle swinging action
//   void toggleSwing(){
//     emit(DrumsStickState(isSwinging: !state.isSwinging, swingAngle: state.isSwinging ? 0.0 : -0.7));
//   }
  
//   bool checkState() {
//     return state.isSwinging;
//   }
// }

// KEYS ASSIST IMPLEMENTATION
class DrumPart{
  final String key;
  final String name;
  final Offset position;
  final Color color;
  final String sound;

  DrumPart({required this.key, required this.name, required this.position, required this.color, required this.sound});
}

List<DrumPart> drumParts = [
  DrumPart(key: "g", name: "left tom", position: Offset(260, 90), color: Colors.white, sound : "drum_sounds/hi_tom.wav"),
  DrumPart(key: "h", name: "right tom", position: Offset(420, 90), color: Colors.white, sound: "drum_sounds/mid_tom.wav" ),
  DrumPart(key: "y", name: "left crash", position: Offset(75, 50), color: Colors.white, sound: "drum_sounds/crash.wav"),
  DrumPart(key: "u", name: "right crash", position: Offset(650, 55), color: Colors.white, sound: "drum_sounds/ride.wav"),
  DrumPart(key: "e", name: "open hi-hat", position: Offset(80, 170), color: Colors.white, sound: "drum_sounds/open_hi_hat.wav"),
  DrumPart(key: "r", name: "closed hi-hat", position: Offset(60, 350), color: Colors.white, sound: "drum_sounds/closed_hi_hat.wav"),
  DrumPart(key: "s", name: "snare", position: Offset(180, 210), color: Colors.white, sound: "drum_sounds/snare.wav"),
  DrumPart(key: "j", name: "floor tom", position: Offset(535, 210), color: Colors.white, sound: "drum_sounds/floor_tom.wav"),
  DrumPart(key: "l", name: "kick", position: Offset(340, 290), color: Colors.white, sound: "drum_sounds/drum_kick.wav"),
];


// Keys Assist Class
class DrumsKeysAssistState{
  bool isKeysAssistOn = false;

  late List<DrumPart> drumParts;

  DrumsKeysAssistState({required this.isKeysAssistOn, required this.drumParts});

}

class DrumsKeysAssistCubit extends Cubit<DrumsKeysAssistState> {
  DrumsKeysAssistCubit() : super(DrumsKeysAssistState(isKeysAssistOn: false, drumParts: drumParts));

  // method to switch key assist state
  void switchKeyAssistState(){
    emit(DrumsKeysAssistState(isKeysAssistOn: !state.isKeysAssistOn, drumParts: state.drumParts));
  }

}



class KeyAssistLabel extends StatelessWidget {
  final DrumPart drumPart;
  
  const KeyAssistLabel({
    Key? key,
    required this.drumPart,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: drumPart.position.dx,
      top: drumPart.position.dy,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: Colors.white, width: 1),
        ),
        child: Text(
          drumPart.key,
          style: TextStyle(
            color: drumPart.color,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}


class DrumSoundState {
  AudioPlayer player;
  String? activeDrumPart;

  DrumSoundState(this.player, {this.activeDrumPart});
}

class DrumSoundCubit extends Cubit<DrumSoundState> {
  DrumSoundCubit() : super(DrumSoundState(AudioPlayer()));
  final Map<String, AudioPlayer> _players = {};
  
  Future<void> play(String key) async {
    try {
      final part = drumParts.firstWhere((p) => p.key == key);
      final player = _players[key] ??= AudioPlayer()
        ..setReleaseMode(ReleaseMode.release)
        ..setPlayerMode(PlayerMode.lowLatency);

      // Update state with active drum part
      emit(DrumSoundState(state.player, activeDrumPart: key));
      
      await player.stop();
      await player.play(AssetSource(part.sound));
      
      // Reset drum part after delay
      await Future.delayed(const Duration(milliseconds: 200));
      emit(DrumSoundState(state.player, activeDrumPart: null));
    } catch (e) {
      debugPrint("Play error: $e");
    }
  }

  @override
  Future<void> close() async {
    for (final player in _players.values) {
      await player.dispose();
    }
    return super.close();
  }
}

// Drum Part Tapping implementation
class DrumPartClickable extends StatelessWidget {
  final DrumPart drumPart;
  final double sizeFactor;
  
  const DrumPartClickable({
    Key? key,
    required this.drumPart,
    required this.sizeFactor,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: (drumPart.position.dx - 35) * sizeFactor,
      top: (drumPart.position.dy - 15)  * sizeFactor,
      child: GestureDetector(
        onTap: () {
          context.read<DrumSoundCubit>().play(drumPart.key);
          
        },
        child: Container(
          width: 100 * sizeFactor,
          height: 100 * sizeFactor,
          decoration: BoxDecoration(
            shape: BoxShape.rectangle,
            color: Colors.transparent,
          ),
        ),
      ),
    );
  }
}



// Keyboard pressing implementation
class DrumKeyboardListener extends StatefulWidget {
  final Widget child;
  
  const DrumKeyboardListener({
    Key? key,
    required this.child,
  }) : super(key: key);
  
  @override
  State<DrumKeyboardListener> createState() => _DrumKeyboardListenerState();
}


class _DrumKeyboardListenerState extends State<DrumKeyboardListener> {
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    final dsc = context.read<DrumSoundCubit>();

    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          final keyPressed = event.logicalKey.keyLabel.toLowerCase();
          if (drumParts.any((part) => part.key == keyPressed)) {
            
            dsc.play(keyPressed);

            return KeyEventResult.handled; 
          }
        }
        return KeyEventResult.ignored; 
      },
      child: widget.child,
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }
}


// Drum part image for opacity implementation 
class DrumPartImage extends StatelessWidget {
  final String assetPath; 
  final double width;
  final double height;
  final Offset offset;
  final bool isActive;
  final double sizeFactor;

  const DrumPartImage({
    Key? key,
    required this.assetPath,
    required this.width,
    required this.height,
    required this.offset,
    required this.isActive,
    required this.sizeFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset * sizeFactor,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 100),
        opacity: isActive ? 0.7 : 1.0,
        child: Image.asset(
          assetPath,
          width: width * sizeFactor,
          height: height * sizeFactor,
        ),
      ),
    );
  }
}



class DrumsUI extends StatelessWidget {
  const DrumsUI({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // BlocProvider(create: (context) => DrumsStickCubit()),
        BlocProvider(create: (context) => DrumsKeysAssistCubit()),
        BlocProvider(create: (context) => DrumSoundCubit()),
      ],
      child: DrumKeyboardListener(
        child: Column(
          children: [
              BlocBuilder<DrumsKeysAssistCubit, DrumsKeysAssistState>(
                  builder: (context, keysAssistState) {
                    return BlocBuilder<DrumSoundCubit, DrumSoundState>(
                      builder: (context, soundState) {
                        return LayoutBuilder(
                          builder: (context, constraints) {
                            final sizeFactor = constraints.maxWidth / 1000;
                            
                            return SizedBox(
                              width: constraints.maxWidth,
                              height: constraints.maxWidth * 0.65,
                              child: Column(
                                children: [
                                  Row(          // for buttons
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Align(
                                        alignment: Alignment.topLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: Colors.grey[900],
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(10),
                                              ),
                                            ),
                                            onPressed: () { Navigator.of(context).pop(); },
                                            child: Text(
                                              "Switch to Piano",
                                              style: const TextStyle(color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ),
                                      BlocBuilder<DrumsKeysAssistCubit, DrumsKeysAssistState>(
                                        builder: (context, keysAssistState) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.grey[900],
                                                shape: RoundedRectangleBorder(
                                                  borderRadius: BorderRadius.circular(10),
                                                ),
                                              ),
                                              onPressed: () {
                                                context.read<DrumsKeysAssistCubit>().switchKeyAssistState();
                                              },
                                              child: Text(
                                                'Key Assist ${keysAssistState.isKeysAssistOn ? 'On' : 'Off'}',
                                                style: const TextStyle(color: Colors.white),
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ],
                                  ),
                                  
                                  // drum kit layout
                                  Transform.translate(
                                    offset: Offset(0, 10),
                                    child: Stack(
                                      fit: StackFit.loose,
                                      children: [
                                        
                                        Stack(
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                DrumPartImage(
                                                  assetPath: 'assets/drum_parts/left_crash.png',
                                                  width: 190,
                                                  height: 390,
                                                  offset: Offset(10, 0),
                                                  isActive: soundState.activeDrumPart == 'y',
                                                  sizeFactor: sizeFactor,
                                                ),
                                                SizedBox(width: 65 * sizeFactor),
                                                Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    DrumPartImage(
                                                      assetPath: 'assets/drum_parts/bass_drum.png',
                                                      width: 220,
                                                      height: 390,
                                                      offset: Offset(-10, 140),
                                                      isActive: soundState.activeDrumPart == 'l',
                                                      sizeFactor: sizeFactor,
                                                    ),
                                                    DrumPartImage(
                                                      assetPath: 'assets/drum_parts/tom_mounts.png',
                                                      width: 100,
                                                      height: 100,
                                                      offset: Offset(-13, -260),
                                                      isActive: false,
                                                      sizeFactor: sizeFactor,
                                                    ),                                           
                                                  ],
                                                ),
                                                DrumPartImage(
                                                  assetPath: 'assets/drum_parts/right_crash.png',
                                                  width: 450,
                                                  height: 450,
                                                  offset: Offset(-50, 2),
                                                  isActive: soundState.activeDrumPart == 'u',
                                                  sizeFactor: sizeFactor,
                                                ),                                             
                                              ],
                                            ),
                                            DrumPartImage(
                                              assetPath: 'assets/drum_parts/Hi-hat.png',
                                              width: 350,
                                              height: 350,
                                              offset: Offset(-100, 110),
                                              isActive: soundState.activeDrumPart == 'e' || soundState.activeDrumPart == 'r',
                                              sizeFactor: sizeFactor,
                                            ),
                                            DrumPartImage(
                                              assetPath: 'assets/drum_parts/snare_base.png',
                                              width: 210,
                                              height: 210,
                                              offset: Offset(90, 240),
                                              isActive: false,
                                              sizeFactor: sizeFactor,
                                            ),
                                            DrumPartImage(
                                              assetPath: 'assets/drum_parts/snare.png',
                                              width: 120,
                                              height: 70,
                                              offset: Offset(140, 210),
                                              isActive: soundState.activeDrumPart == 's',
                                              sizeFactor: sizeFactor,
                                            ),
                                            DrumPartImage(
                                              assetPath: 'assets/drum_parts/left_tom.png',
                                              width: 250,
                                              height: 150,
                                              offset: Offset(155, 85),
                                              isActive: soundState.activeDrumPart == 'g',
                                              sizeFactor: sizeFactor,
                                            ),
                                            DrumPartImage(
                                              assetPath: 'assets/drum_parts/right_tom.png',
                                              width: 250,
                                              height: 150,
                                              offset: Offset(300, 85),
                                              isActive: soundState.activeDrumPart == 'h',
                                              sizeFactor: sizeFactor,
                                            ),
                                            DrumPartImage(
                                              assetPath: 'assets/drum_parts/floor_tom.png',
                                              width: 250,
                                              height: 250,
                                              offset: Offset(420, 200),
                                              isActive: soundState.activeDrumPart == 'j',
                                              sizeFactor: sizeFactor,
                                            ),
                                           
                                          ],
                                        ),

                                        
                                        ...drumParts.map(
                                          (drumPart) => DrumPartClickable(
                                            drumPart: drumPart,
                                            sizeFactor: sizeFactor,
                                          ),
                                        ),
                                      
                                        if (keysAssistState.isKeysAssistOn)
                                          ...keysAssistState.drumParts.map(
                                            (drumPart) => Positioned(
                                              left: drumPart.position.dx * sizeFactor,
                                              top: drumPart.position.dy * sizeFactor,
                                              child: Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: Colors.black,
                                                  borderRadius: BorderRadius.circular(4),
                                                  border: Border.all(color: Colors.white, width: 1),
                                                ),
                                                child: Text(
                                                  drumPart.key.toUpperCase(),
                                                  style: TextStyle(
                                                    color: drumPart.color,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14 * sizeFactor,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  )
                                ],
                              )
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              // },
            // ),
          ],
        ),
      ),
    );
  }
}
