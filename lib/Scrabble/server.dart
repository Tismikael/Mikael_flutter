// s4.dart.  This is a GUI demo of socket connections.
// Barrett Koster
// working from notes from Suragch

// This runs with c4.dart.  Run this s4.dart first, then
// run c4.dart along with it.  They should communicate.
/*
   must have 
	<key>com.apple.security.network.client</key>
	<true/>
  in Runner/DebugProfile.entitlements and Runner/Release.entitlements

*/

// create a 15 x 15 scrabble board

// generate a list of 7 random letters to fill player's deck

// allow player to place letters on the board

// when players click on a letter, light it up and then click on the tile to place it on

// use the server-client communication code from Chatter


// server.listen() defines a function that gets
// called EVERY time a client calls the server.  We 
// can make a server that handles lots of clients, but
// we start with one.  

import 'dart:io';
import 'dart:typed_data';

import "package:flutter/material.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "dart:math";
import "tile.dart";

class ConnectionState
{
  bool listening = false; // true === server is waiting for a client to connect
  Socket? theClient = null; // the client's Socket when connected
  bool listened = false; // true === we are listening to client (we only
                         // want to turn this on once, so ... )

  ConnectionState( this.listening, this.theClient, this.listened);
}
class ConnectionCubit extends Cubit<ConnectionState>
{
  // constructor.  make empty start, but then launch the async
  // connect() that will make a connection.
  ConnectionCubit() : super( ConnectionState(false, null, false) )
  { if ( state.theClient==null) { connect(); } }

  // when a connection is made, note the Socket
  update( bool b, Socket s ) { emit( ConnectionState(b,s, state.listened) ); }

  // when we turn on listening on this Socket, make a not of that
  updateListen() { emit( ConnectionState(true,state.theClient,true) ); }

  // connect() creates a ServerSocket and then it waits/listens, possibly
  // forever, for Client to call.  
  /// Create a server socket, wait for a client to connect, and save the client's socket.
  /// When the connection is established, the [ConnectionCubit] is updated with the connected
  /// socket and a boolean indicating that we are listening.
  Future<void>  connect() async
  { await Future.delayed( const Duration(seconds:2) ); // adds drama
      // bind the socket server to an address and port
    final server = await ServerSocket.bind(InternetAddress.anyIPv4, 9203);
    print("server socket created?");

    // listen for clent connections to the server.
    // When this function is triggered, it sets up the Sockets, nothing more.
    server.listen
    ( (client)
      { emit( ConnectionState(true,client, state.listened) ); }
    );
    emit( ConnectionState(true,null, false) );
    // print("server waiting for client");
  }
}


class SaidState
{
   String said;
   List<String> saidList;

   SaidState( this.said, this.saidList );
}

class SaidCubit extends Cubit<SaidState>
{
  SaidCubit() : super( SaidState("and so it begins ....\n" ,  []) );

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
    // change the Tile's color to blue[50]
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
  runApp( Server () );
}

// The Server class just has the BLoC layers.  Note that the
// Connection is outside the message, so we can connect once and
// then re-build the message many times.
class Server extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "server",
      home: BlocProvider<ConnectionCubit>(
        create: (context) => ConnectionCubit(),
        child: BlocBuilder<ConnectionCubit, ConnectionState>(
          builder: (context, connectionState) => BlocProvider<SaidCubit>(
            create: (context) => SaidCubit(),
            child: BlocBuilder<SaidCubit, SaidState>(
              builder: (context, saidState) => BlocProvider<GameCubit>(
                create: (context) => GameCubit(),
                child: Server2(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Server2 layer draws the window.  The window is
// 1. a text field where you can type stuff
// 2. a button to press to send what you typed 
// 3. a text window showing what the other side has sent.
class Server2 extends StatelessWidget
{ final TextEditingController tec = TextEditingController();

  @override
  Widget build( BuildContext context )
  { ConnectionCubit cc = BlocProvider.of<ConnectionCubit>(context);
    ConnectionState cs = cc.state;
    SaidCubit sc = BlocProvider.of<SaidCubit>(context);
    GameCubit gc = BlocProvider.of<GameCubit>(context);
    GameState gs = gc.state;

    // This 'listen' call is a little tricky.  We want to define the
    // listener only once, so you might suppose we would put this code outside
    // the message BLoC (which happens every time somebody says something).
    // But the listen function itself needs access to the message BLoC
    // because it uses the messagE BLoC to display what was heard.
    // So we have a 'listened' flag that gets set the first time, so we
    // only define Socket.listen( (){} ) once.
    if ( cs.theClient != null && !cs.listened )
    { listen(context);
      cc.updateListen(); // set the listened flag
    } 

    return Scaffold
    (
      backgroundColor: Colors.grey[200],
      appBar: AppBar( title: Text("server") ),
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
                        if (gs.selectedLetter.isNotEmpty && cs.theClient != null) {
                          gc.updateGameBoard(i, j);
                          // cs.theClient!.write("BOARD|${gc.sendBoard()}");
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
                        child: Tile(letter, color: Colors.blue[50], borderColor: gc.state.selectedLetter == letter ? Colors.white : Colors.black,),
                      );
                    }),
                  ),

                  SizedBox(width: 15,),
                  ElevatedButton(
                    onPressed: () {
                      gc.updatePlayerTurn();
                      if (cs.theClient != null) {
                        cs.theClient!.write("BOARD|${gc.sendBoard()}");
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



          // place to type message
          SizedBox
          ( child: TextField(controller: tec) ),
          // button to send message 
          // (or "not ready" message if client is not there yet)
          cs.theClient!=null
          ?  ElevatedButton
            ( onPressed: ()
              { cs.theClient!.write ( tec.text ); 
                sc.addServerMessage(tec.text);
    
              },
              child: Text("send to client"),
            )
          : Text("not ready"),
          // message from the other process (or local message
          // if we are just getting started.
          cs.listening
          ? cs.theClient!=null
            ? Expanded(
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
            : Text("waiting for client to call ...")
          : Text("server loading ... "),
        ],
      ),
    );
  }

  // listen() tells the Socket to listen for messages from the
  // other side and what to do with them.    It assumes that
  // theClient is there (checking must occur before this call).
  // We also only want to do this ONCE.  We would have to
  // un-listen and then re-listen if we called this more than once.  ick.

  // listen for a list of messages
  void listen( BuildContext bc )
  { ConnectionCubit cc = BlocProvider.of<ConnectionCubit>(bc);
    ConnectionState cs = cc.state;
    SaidCubit sc = BlocProvider.of<SaidCubit>(bc);
    GameCubit gc = BlocProvider.of<GameCubit>(bc);

    cs.theClient!.listen
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
      { 
        // sc.update( "${sc.state.said}$message\n" ); // add to existing
        // sc.update(message);
        sc.addClientMessage(message);
      }
    },
       // handle errors
      onError: (error)
      { print(error);
        cs.theClient!.close();
      },
    );
  }
}


