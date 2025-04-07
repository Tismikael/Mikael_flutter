// player.dart
// Barrett Koster 2025

import "dart:io";

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";

import "said_state.dart";
import "game_state.dart";
import "yak_state.dart";
import "server_state.dart";

/*
  A Player gets called for each of the ServerBase and the ClientBase.
  We establish the game state, usually different depending on 
  whether you are the starting player or not.  
  This establishes the Game and Said BLoC layers. 
*/

bool canPlay = false;       // variable to track player's turn

class Player extends StatelessWidget
{ final bool iStart;
  Player( this.iStart, {super.key} );

  @override
  Widget build( BuildContext context )
  { 
    return BlocProvider<GameCubit>
    ( create: (context) => GameCubit( iStart ),
      child: BlocBuilder<GameCubit,GameState>
      ( builder: (context,state) => 
        BlocProvider<SaidCubit>
        ( create: (context) => SaidCubit(),
          child: BlocBuilder<SaidCubit,SaidState>
          ( builder: (context,state) => Scaffold
            ( appBar: AppBar(title: Text("player")),
              body: Player2(),
            ),
          ),
        ),
      ),
    );
  }
}

// this layer initializes the communication.
// By this point, the socets exist in the YakState, but
// they have not yet been told to listen for messages.
class Player2 extends StatelessWidget
{ Widget build( BuildContext context )
  { YakCubit yc = BlocProvider.of<YakCubit>(context);
    YakState ys = yc.state;
    SaidCubit sc = BlocProvider.of<SaidCubit>(context);

    if ( ys.socket != null && !ys.listened )
    { sc.listen(context);
      yc.updateListen();
    } 
    return Player3();
  }
}

// This is the actual presentation of the game.

class Player3 extends StatelessWidget
{ Player3( {super.key} ); 

  final TextEditingController tec = TextEditingController();

  Widget build( BuildContext context )
  { SaidCubit sc = BlocProvider.of<SaidCubit>(context);
    SaidState ss = sc.state;
    GameCubit gc = BlocProvider.of<GameCubit>(context);
    GameState gs = gc.state;
    YakCubit yc = BlocProvider.of<YakCubit>(context);
    YakState ys = yc.state;




     return Column
    ( children:
      [ Row(children: [ Sq(0), Sq(1), Sq(2)]),
        Row(children: [ Sq(3), Sq(4), Sq(5)]),
        Row(children: [ Sq(6), Sq(7), Sq(8)]),
        Text("said: ${ss.said}"),
        Text(canPlay ? "" : "currently not your turn"),
        SizedBox(height: 50),

        // check if the game is over
        gs.isOver ? Column(
          children: [
            Text("Game Over"),
            Text("Player ${gs.winner} wins"),
            gs.playAgain ? 
              Column(
                children: [
                  Text("Opponent wants to play again"),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          gc.reset();
                          // Send message to other player that we accepted
                          yc.say("reset");
                        },
                        child: Text("Accept"),
                      ),
                      SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          gc.declineRematch();
                          // Send message to other player that we declined
                          yc.say("declineRematch");
                        },
                        child: Text("Decline"),
                      ),
                    ],
                  ),
                ],
              ) : 
              ElevatedButton(
                onPressed: () {
                  gc.requestPlayAgain();
                  // Send message to other player about rematch request
                  yc.say("playAgain");
                },
                child: Text("Request rematch"),
              ),
          ] 
        ) : 
        Container(),

        SizedBox(height: 50),
        !gs.isOver ? ElevatedButton(
          onPressed: () {
            gc.resign();
            yc.say("resign");
          },
          child: Text("Resign"),
        ) : Container(),

        gs.rematchDeclined ? Column(
          children: [
            Text("Opponent declined rematch request"),
            ElevatedButton(
              onPressed: () {
                gc.clearDeclineMessage();
              },
              child: Text("OK"),
            ),
          ],
        ) : SizedBox(height: 0),

        // SizedBox(height: 25),
        Divider(height: 5, thickness: 1, color: Colors.black),

        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: TextField(
                controller: tec,
                decoration: InputDecoration(
                  hintText: "Type a message...",
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (value) {
                  if (value.isNotEmpty) {
                    sc.sendMessage(context, value);
                    tec.clear();
                  }
                },
              ),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () {
                if (tec.text.isNotEmpty) {
                  sc.sendMessage(context, tec.text);
                  tec.clear();
                }
              },
              child: Text("Send"),
            ),
          ],
        ),

        Expanded(
          child: ListView.builder(
            itemCount: ss.saidList.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                child: Text(
                  sc.state.saidList[index],
                  style: TextStyle(
                    color: Colors.blue[700], 
                    fontSize: 20,
                  ),
                ),
              );
            },
          ),
        )
      ]
    );
  }
}

// the squares of the board are just buttons.  You press one 
// to play it.  We should have control here over whether it
// is your turn or not (but this is not added yet).
class Sq extends StatelessWidget
{ final int sn;
  Sq(this.sn,{super.key});

  Widget build( BuildContext context )
  { GameCubit gc = BlocProvider.of<GameCubit>(context);
    GameState gs = gc.state;
    // String mark = gs.iStart?"x":"o";

    YakCubit yc = BlocProvider.of<YakCubit>(context);
    
    return ElevatedButton
    ( onPressed: ()

      // check if it is your turn
      {
        if (gs.myTurn && !gs.isOver){
          canPlay = true;
          gc.play(sn);
          yc.say("sq $sn");         
        }
        else
        { 
          canPlay = false;
        }

      },
      child: Text(gs.board[sn]),
    );

  }
}



   