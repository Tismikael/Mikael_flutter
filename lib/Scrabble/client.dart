// Barrett Koster
// working from notes from Suragch

/* To run this, run s4.dart first, then run this c4.dart.
   The two should communicate.
*/

// client side of connection


import 'dart:io';
import 'dart:typed_data';

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "dart:math";
import "tile.dart";

class ConnectionState
{
  Socket? theServer = null; // Socket.  The Socket for client and 
                            // server are really the same.  
  bool listened = false; // true == listening has been started on this
                         // Socket (do not re-started it)

  ConnectionState( this.theServer, this.listened);
}
class ConnectionCubit extends Cubit<ConnectionState>
{ // constructor.  Try to connect when you start.
  ConnectionCubit() : super( ConnectionState( null, false) )
  { if ( state.theServer==null ) { connect(); } }

  update( Socket s ) { emit( ConnectionState(s,state.listened) ); }
  updateListen() { emit( ConnectionState(state.theServer, true ) ); }
 
  // connect() is async, so it may take a while.  OK.  When done, it
  // emit()s a new ConnectionState, to say that we are connected.
  Future<void>  connect() async
  { await Future.delayed( const Duration(seconds:2) ); // adds drama
      // bind the socket server to an address and port
      // connect to the socket server
    final socket = await Socket.connect('localhost', 9203);
    print('Connected to: ${socket.remoteAddress.address}:${socket.remotePort}');
    update(socket);
  }
}


class SaidState
{
   String said;
   List<String> saidList;

   SaidState( this.said, this.saidList);
}

class SaidCubit extends Cubit<SaidState>
{
  SaidCubit() : super( SaidState("and so it begins ....\n", []) );

  // void update( String more ) { emit(SaidState( "${state.said}$more\n" ) ); } 
  void update( String s ) { emit( SaidState(s, [...state.saidList, s]) ); }

  void addServerMessage(String s){
    List<String> newList = List.from(state.saidList);
    newList.add("Server: $s");
    emit(SaidState(s, newList));
  }

  void addClientMessage(String s){
    List<String> newList = List.from(state.saidList);
    newList.add("Client: $s");
    emit(SaidState(s, newList));
  }
}

List<String> letters = ["A", "B", "C", "D", "E", "F", "G", "H",
                       "I", "J", "K", "L", "M", "N", "O", "P", 
                       "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];

class GameState
{
  late List<List<Tile> > gameBoard;
  late bool isPlayerTurn;
  String selectedLetter;

  // GameState(List<List<Tile>> gameBoard, bool bool) : gameBoard =List.generate(15, (i) => List.generate( 15, (j) => Tile("") ) ), isPlayerTurn = false;
  GameState( this.gameBoard, this.isPlayerTurn, this.selectedLetter);
}

class GameCubit extends Cubit<GameState>
{

  GameCubit() : super( GameState(List.generate(15, (i) => List.generate( 15, (j) => Tile("", borderColor: Colors.black,) ) ), false, "" ) );
  // method to update the player's turn
  void updatePlayerTurn(){
    emit( GameState(state.gameBoard, !state.isPlayerTurn, state.selectedLetter) );
  }

  // method to select a letter
  void selectLetter( String letter ){
    emit( GameState(state.gameBoard, state.isPlayerTurn, letter) );
  }

  // method to update the gameboard based on player's move
  void updateGameBoard(int r, int c){

      // check if the selected letter is in the player's hand
      if (state.selectedLetter.isEmpty) return;

      Tile updatedTile = Tile(state.selectedLetter, color: Colors.blue[50], borderColor: Colors.black,);

      List<List<Tile>> newBoard = List.generate(state.gameBoard.length, (i) => List<Tile>.from(state.gameBoard[i]), );

      newBoard[r][c] = updatedTile;

      emit( GameState(newBoard, state.isPlayerTurn, "") );
  }

    // method to convert the board to a string and send it
    String sendBoard() {

      String result = "BOARD";
      
      for (int i = 0; i < state.gameBoard.length; i++) {
        for (int j = 0; j < state.gameBoard[i].length; j++) {
          String letter = state.gameBoard[i][j].letter;
          if (letter.isNotEmpty) {
            result += ",$i,$j,$letter";
          }
        }
      }
      
      return result;
    }
}


void main()
{
  runApp( Client () );
}

class Client extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "client",
      home: BlocProvider<ConnectionCubit>(
        create: (context) => ConnectionCubit(),
        child: BlocBuilder<ConnectionCubit, ConnectionState>(
          builder: (context, connectionState) => BlocProvider<SaidCubit>(
            create: (context) => SaidCubit(),
            child: BlocBuilder<SaidCubit, SaidState>(
              builder: (context, saidState) => BlocProvider<GameCubit>(
                create: (context) => GameCubit(),
                child: Client2(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class Client2 extends StatelessWidget
{ final TextEditingController tec = TextEditingController();

  @override
  Widget build( BuildContext context )
  { ConnectionCubit cc = BlocProvider.of<ConnectionCubit>(context);
    ConnectionState cs = cc.state;
    SaidCubit sc = BlocProvider.of<SaidCubit>(context);
    GameCubit gc = BlocProvider.of<GameCubit>(context);
    GameState gs = gc.state;   

    if ( cs.theServer != null && !cs.listened )
    { listen(context);
      cc.updateListen();
    } 

    return Scaffold
    ( appBar: AppBar( title: Text("client") ),
      body: Column
      ( children:
        [ 
         Container(
              margin: const EdgeInsets.all(8),
              child: Column(
              children: List.generate(15, (i) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(15, (j) {
                    return GestureDetector(
                      onTap: () {
                        if (gs.selectedLetter.isNotEmpty && cs.theServer != null) {
                          gc.updateGameBoard( i, j);
                          // cs.theServer!.write("BOARD|${gc.sendBoard()}");
                        }
                      },
                      child: gs.gameBoard[i][j],
                    );
                  }),
                );
              }),
            )
          ),

         Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(7, (i) {
                      var random = Random();
                      int randomNum = random.nextInt(26);
                      String letter = letters[randomNum];
                      return GestureDetector(
                        onTap: () { 
                          gc.selectLetter(letter);
                          // gc.updatePlayerTurn();
                        },
                        // if Tile is tapped, change the border color, else leave it
                        child: Tile(letter, color: Colors.blue[50], borderColor: gc.state.selectedLetter == letter ? Colors.white : Colors.black, ),
                        // child: Tile(letter, color: Colors.blue[50], ),
                      );
                    }),
                  ),

                  SizedBox(width: 15,),
                  ElevatedButton(
                    onPressed: () {
                      // gc.updatePlayerTurn();
                      if (cs.theServer != null) {
                        gc.updatePlayerTurn();
                        cs.theServer!.write("BOARD|${gc.sendBoard()}");

                        gc.emit(GameState(gc.state.gameBoard, !gc.state.isPlayerTurn, gc.state.selectedLetter));
                      }
                    }, 
                    
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[50],
                      foregroundColor: Colors.black
                    ),

                    child: Text("Submit", style: TextStyle(fontSize: 15),),
                    
                  ),


            ],
            
            ),

          
          // place to type and sent button
          SizedBox
          ( child: TextField(controller: tec) ),
          cs.theServer!=null
          ?  ElevatedButton
            ( onPressed: ()
              { cs.theServer!.write ( tec.text ); 
                sc.addClientMessage(tec.text);
              },
              child: Text("send to server"),
            )
          : Text("not ready"),

          Expanded(
            child: ListView.builder(
              itemCount: sc.state.saidList.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Text(
                    sc.state.saidList[index],
                    style: TextStyle(
                      color: sc.state.saidList[index].startsWith("Server:")
                        ? Colors.blue[700]
                        : Colors.green,
                      fontSize: 16,
                    ),
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }

  void listen( BuildContext bc )
  { ConnectionCubit cc = BlocProvider.of<ConnectionCubit>(bc);
    ConnectionState cs = cc.state;
    SaidCubit sc = BlocProvider.of<SaidCubit>(bc);
    GameCubit gc = BlocProvider.of<GameCubit>(bc);

    cs.theServer!.listen
    ( (Uint8List data) async{

       final message = String.fromCharCodes(data);
  
      if (message.startsWith("BOARD|")) {
        String data = message.substring(6);
        List<String> parts = data.split(',');
        
        // Create new empty board
        List<List<Tile>> newBoard = List.generate(15, (i) => 
          List.generate(15, (j) => Tile("", borderColor: Colors.black)));
        
        // Parse the message parts (format: i,j,letter)
        for (int k = 0; k < parts.length; k += 3) {
          if (k + 2 >= parts.length) break;
          int i = int.tryParse(parts[k]) ?? 0;
          int j = int.tryParse(parts[k+1]) ?? 0;
          String letter = parts[k+2];
          if (i >= 0 && i < 15 && j >= 0 && j < 15) {
            newBoard[i][j] = Tile(letter, color: Colors.blue[50], borderColor: Colors.black);
          }
        }
        
        // Update the game state
        gc.emit(GameState(newBoard, !gc.state.isPlayerTurn, ""));
      }
      else
      { final message = String.fromCharCodes(data);
      sc.addServerMessage(message);
        // sc.update(message);
      }
    },
      // handle errors
      onError: (error)
      { print(error);
        cs.theServer!.close();
      },
    );
  }
}



