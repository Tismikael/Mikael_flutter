// game_state.dart
// Barrett Koster 2025

// Tic Tac Toe 
// lab

// You are given starter code that runs Tic Tac Toe
// between two programs.  But it is missing things
// you can add:

// -- add a layer so you can chat with your opponent.
//    Or use the current one, but somehow you should
//    have visible messages and INvisible messages.  
//    You will need the latter for the programs to 
//    communicate in Scrabble without telling the user.



import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:mikael_yikum_flutter/TicTacToe/yak_state.dart";
import "yak_state.dart";

// This is where you put whatever the game is about.

class GameState
{
  bool iStart;
  bool myTurn;
  List<String> board;
  bool isOver;
  String winner;
  bool playAgain;
  bool rematchDeclined;

  GameState( this.iStart, this.myTurn, this.board, this.isOver, this.winner, this.playAgain, this.rematchDeclined);
}

class GameCubit extends Cubit<GameState>
{
  static final String d = ".";
  GameCubit( bool myt ): super( GameState( myt, myt, [d,d,d,d,d,d,d,d,d], false, "", false, false) ); 

  update( int where, String what )
  {
    state.board[where] = what;
    state.myTurn = !state.myTurn;
    emit( GameState(state.iStart,state.myTurn,state.board, state.isOver, state.winner, state.playAgain, state.rematchDeclined) ) ;
  }

  // function to check whether the game is over
  isGameOver(String mark){
  if (state.board[0] == state.board[1] && state.board[1] == state.board[2] && state.board[2] == mark ||
      state.board[3] == state.board[4] && state.board[4] == state.board[5] && state.board[5] == mark ||
      state.board[6] == state.board[7] && state.board[7] == state.board[8] && state.board[8] == mark ||
      state.board[0] == state.board[3] && state.board[3] == state.board[6] && state.board[6] == mark ||
      state.board[1] == state.board[4] && state.board[4] == state.board[7] && state.board[7] == mark ||
      state.board[2] == state.board[5] && state.board[5] == state.board[8] && state.board[8] == mark ||
      state.board[0] == state.board[4] && state.board[4] == state.board[8] && state.board[8] == mark ||
      state.board[2] == state.board[4] && state.board[4] == state.board[6] && state.board[6] == mark)
      {
        state.isOver = true;
        state.winner = mark;
        emit( GameState(state.iStart, state.myTurn, state.board, state.isOver, state.winner, state.playAgain, state.rematchDeclined) );
      }

      // check if all the cells are filled
      bool isDraw = true;
      for (int i = 0; i < 9; i++){
        if (state.board[i] == d){
          isDraw = false;
          break;
        }
      }

      if (isDraw && !state.isOver){
        state.isOver = true;
        state.winner = "draw";
        emit( GameState(state.iStart, state.myTurn, state.board, state.isOver, state.winner, state.playAgain, state.rematchDeclined) );
      }
      
  }

  // Someone played x or o in this square.  (numbered from
  // upper left 0,1,2, next row 3,4,5 ... 
  // Update the board and emit.
  play( int where )
  { String mark = state.myTurn==state.iStart? "x":"o";
    // check if cell is empty
    if ( state.board[where] != d ) return;
    state.board[where] = mark;
    state.myTurn = !state.myTurn;
    isGameOver(mark);
    emit( GameState(state.iStart,state.myTurn,state.board, state.isOver, state.winner, state.playAgain, state.rematchDeclined) ) ;
  }

  // incoming messages are sent here for the game to do
  // whatever with.  in this case, "sq NUM" messages ..
  // we send the number to be played.
  void handle( String msg )
  { List<String> parts = msg.split(" ");
    if ( parts[0] == "sq" )
    { int sqNum = int.parse(parts[1]);
      play(sqNum);
    } else if (parts[0] == "playAgain"){
      state.playAgain = true;
      emit( GameState(state.iStart, state.myTurn, state.board, state.isOver, state.winner, state.playAgain, state.rematchDeclined) );
    } else if (parts[0] == "reset"){
      reset();
    } else if (parts[0] == "resign"){
      // If opponent resigns, you win
      state.isOver = true;
      state.winner = state.myTurn ? "o" : "x"; // Opposite of current player
      emit( GameState(state.iStart, state.myTurn, state.board, state.isOver, state.winner, state.playAgain, state.rematchDeclined) );
    } else if (parts[0] == "declineRematch"){
      state.playAgain = false;
      state.rematchDeclined = true;
      emit( GameState(state.iStart, state.myTurn, state.board, state.isOver, state.winner, state.playAgain, state.rematchDeclined));
    }


  }

  // function to reset the game
  void reset(){
    bool newStart = !state.iStart;
    bool newTurn = !state.iStart; // Let the other player go first
    emit( GameState(newStart, newTurn, [d,d,d,d,d,d,d,d,d], false, "", false, state.rematchDeclined) );
  }

  // function to request a rematch
  void requestPlayAgain(){
    state.playAgain = false;
    emit( GameState(state.iStart, state.myTurn, state.board, state.isOver, state.winner, state.playAgain, state.rematchDeclined) );
  }

  // function to decline a rematch
  void declineRematch(){
    state.playAgain = false;
    emit( GameState(state.iStart, state.myTurn, state.board, state.isOver, state.winner, state.playAgain, state.rematchDeclined) );
  }

  // function to clear the decline message
  void clearDeclineMessage(){
    state.rematchDeclined = false;
    emit( GameState(state.iStart, state.myTurn, state.board, state.isOver, state.winner, state.playAgain, state.rematchDeclined) );
  }


  // function to resign
  void resign(){
    state.isOver = true;
    state.winner = state.myTurn == state.iStart ? "o" : "x";
    emit( GameState(state.iStart, state.myTurn, state.board, state.isOver, state.winner, state.playAgain, state.rematchDeclined) );
  }

}