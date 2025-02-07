// sized_grid_prep.dart
// Mikael Yikum
// lab
// let user enter 2D grid size, make grid that size


import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";


// Create Grid State 
class GridState {

  // state width and height
  final int width;
  final int height;

  // constructor
  GridState({required this.width, required this.height});
}

// Grid Cubit
class GridCubit extends Cubit<GridState> {
  GridCubit() : super(GridState(width: 4, height: 3));  // default 4 x 3 grid

  // Add methods to change width and height

  // Width
  void increaseWidth() {
    emit(GridState(width: state.width + 1, height: state.height));
  }

  void decreaseWidth() {
    emit(GridState(width: state.width - 1, height: state.height));
  }

  // Height
  void increaseHeight() {
    emit(GridState(width: state.width, height: state.height + 1));
  }

  void decreaseHeight() {
    emit(GridState(width: state.width, height: state.height - 1));
  }
}


void main()
{ runApp(SG()); }

class SG extends StatelessWidget
{
  SG({super.key});

  Widget build( BuildContext context )
  {
    // enable cubit blocprovider
    return BlocProvider<GridCubit>  
    ( create: (context) => GridCubit(),
      child: MaterialApp
      ( title: "sized grid prep",
        home: SG1(),
      ),
    );
   
  }
}


class SG1 extends StatelessWidget {
  SG1({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<GridCubit, GridState>(
      builder: (context, gstate) {

        // create the grid  of Boxy objects
        int width = gstate.width;
        int height = gstate.height;

        Row theGrid = Row(children: []);
        for (int i = 0; i < width; i++) {
          Column c = Column(children: []);
          for (int j = 0; j < height; j++) {
            c.children.add(Boxy(40, 40));
          }
          theGrid.children.add(c);
        }

        GridCubit gc = BlocProvider.of<GridCubit>(context);

        return Scaffold(
          appBar: AppBar(title: Text("Sized Grid")),
          body: Column(
            children: [
              Text("before the grid"),
              theGrid,
              Text("after the grid"),

              // display the current width and height on screen
              Row( 
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text("Width: $width, Height: $height",
                    style: TextStyle(height: 2, fontSize: 20),)
                  ,
                ],
              ),

              Container(height: 10),

              // Add buttons to increase and decrease width and height
              FloatingActionButton.extended(
                onPressed: () => gc.decreaseHeight(),
                label: Text("Decrease Height"),
              ),

              Container(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FloatingActionButton.extended(
                    onPressed: () => gc.decreaseWidth(),
                    label: Text("Decrease Width"),
                  ),
                  Container(width: 30),
                  FloatingActionButton.extended(
                    onPressed: () => gc.increaseWidth(),
                    label: Text("Increase Width"),
                  ),
                ],
              ),
              Container(height: 10),

              FloatingActionButton.extended(
                onPressed: () => gc.increaseHeight(),
                label: Text("Increase Height"),
              ),
          
            ],
          ),
        );
      },
    );
  }
}

class Boxy extends Padding
{
  final double width;
  final double height;
  Boxy( this.width,this.height ) 
  : super
    ( padding: EdgeInsets.all(4.0),
      child: Container
      ( width: width, height: height,
        decoration: BoxDecoration
        ( border: Border.all(), ),
        child: Text("x"),
      ),
    );
}

