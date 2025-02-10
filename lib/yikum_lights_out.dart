import "dart:math";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";


// Light class
class Light extends Padding
{
  final double width;
  final double height;
  final bool isLit;  // true if light is lit, false if not

  Light(this.width, this.height, {required this.isLit})
  : super
  (padding: EdgeInsets.all(4.0),
  child: Container(
    width: width, height: height,
    decoration: BoxDecoration(
      border: Border.all(), 
      color: isLit? Colors.yellow: Colors.brown  // set color based on light state
    )
  ));
}

class LightState {
  int numLights = 0;
  
  // create a set to store the light state
  Set<int> lights = {};
  LightState({required this.numLights, required this.lights});  
}

class LightCubit extends Cubit<LightState> {
  LightCubit() : super(LightState( numLights: 0, lights: {}));
 
   // method to update the number of lights
  void updateNumLights(int num) {
    Set<int> initializedLights = {};
    // generate random set of lights to be lit
    Random random = Random();
    for (int i = 0; i < num; i++) {
      initializedLights.add(random.nextInt(num));
    }
    emit(LightState(numLights: num, lights: initializedLights));
  }
   
   // method to toggle selected light
  void toggleLight(int index) {
    if (state.lights.contains(index)) {
      state.lights.remove(index);
    } else {
      state.lights.add(index);
    }
    emit(LightState(numLights: state.numLights, lights: state.lights));
  }


}




void main() {
  runApp(LightsOut());
}

class LightsOut extends StatelessWidget
{
  LightsOut({super.key});


  @override
  Widget build(BuildContext context){

    return BlocProvider<LightCubit>(
      
      create: (context) => LightCubit(),
      child: MaterialApp(
        title: "lights out",
        home: LightsOutHome(),
      ),
    );
  }
}



class LightsOutHome extends StatelessWidget {
  LightsOutHome({super.key});
  
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LightCubit, LightState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: const Text("Lights Out!")),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),

              // create a textfield to enter the number of lights
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: "Enter the number of lights",
                  ),

               // retrieve the number of lights 
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    if (value.isNotEmpty) {
                      context.read<LightCubit>().updateNumLights(int.parse(value));
                    }
                  },
                ),
              ),

              // use input number to create row of Lights
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  state.numLights,
                  (index) => Light(50, 50, isLit: state.lights.contains(index)),
                ),
              ),

              // generate buttons to toggle lights
              
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  state.numLights,
                  (index) => FloatingActionButton(
                    onPressed: () {
                      context.read<LightCubit>().toggleLight(index);
                      // toggle the light to the left and right of the current light
                      if (index > 0) {
                        context.read<LightCubit>().toggleLight(index - 1);
                      }
                      if (index < state.numLights - 1) {
                        context.read<LightCubit>().toggleLight(index + 1);
                      }
                    },
                  )
                )
              
                
                )

              
            ],
          ),
        );
      },
    );
  }
}


