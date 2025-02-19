// move_state.dart
// Barrett Koster 2025

// This captures the stae of the mouse having been
// clicked down at some Square, noted by Coords.
// When the mouse is let up, we make a move.  We do
// not need to RECORD this even as state.

import 'package:hydrated_bloc/hydrated_bloc.dart';

import 'coords.dart';
import 'chess_state.dart';
import 'dart:convert';

class MoveState
{
  Coords? mouseAt;
  bool dragging;

  MoveState( this.mouseAt, this.dragging );

  // turn the object into a map
  Map<String, dynamic> toMap()
  {
    return 
    {
      'mouseAt' : mouseAt?.toMap(),   // converted to map
      'dragging': dragging,
    };
  }

  // turn a map back into an object
  factory MoveState.fromMap(Map<String, dynamic> map)
  {
    return MoveState( 
      map['mouseAt'] == null ? null : Coords.fromMap(map['mouseAt']),
      map['dragging']
      );
  }

  // turn the object into JSON
  String toJson() => json.encode(toMap);

  // turn the Json back into an object
  factory MoveState.fromJson(String source)
  => MoveState.fromMap( json.decode(source));
}

class MoveCubit extends HydratedCubit<MoveState>
{ MoveCubit() : super( MoveState(null,false) ) ;

  void mouseDown( Coords here, ChessCubit cc )
  { 
    if ( state.dragging ) // mouse already down, this is a move
    { if ( !here.equals(state.mouseAt!) )
      { 

      
        if ( state.mouseAt != null )
        { Coords temp = Coords(state.mouseAt!.c,state.mouseAt!.r);
          emit( MoveState(null,false) );
          cc.update( temp, here ); 
        }
        else
        { print("mouseAt is null -- how?"); }
      }
    }
    else // this is the first click of a move
    {   emit( MoveState(here,true) );
    }
  }
  
  @override
  MoveState? fromJson(Map<String, dynamic> json) {
     return MoveState.fromMap(json);
  }
  
  @override
  Map<String, dynamic>? toJson(MoveState state) {
    return state.toMap();
  }
}

