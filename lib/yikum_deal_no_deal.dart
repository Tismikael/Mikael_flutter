import "dart:convert";

import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:hydrated_bloc/hydrated_bloc.dart";
import "dart:math";
import "package:path_provider/path_provider.dart";

// list of prices
List<double> prices = [1, 5, 10, 100, 1000, 5000, 10000, 100000, 500000, 1000000];

FocusNode focusNode = FocusNode();
class SuitCase
{
  final int orderNum;
  final double price;
  bool isPicked;
  bool isOpened;

  SuitCase(this.orderNum, this.price, this.isPicked,this.isOpened);


  // turn the state into a map
  Map<String, dynamic> toMap() {
    return {
      'orderNum': orderNum,
      'price': price,
      'isPicked': isPicked,
      'isOpened': isOpened,
    };
  }

  // turn the map into a state
  factory SuitCase.fromMap(Map<String, dynamic> map) {
    return SuitCase(
      map['orderNum'],
      map['price'],
      map['isPicked'],
      map['isOpened'],
    );
  }

}

class GameState
{
  final List<SuitCase> suitcases; // list of SuitCase 
  final SuitCase? playerSuitcase;
  final bool holdsSuitcase;
  final bool showMessage;
  final bool isGameFinished;
  final double dealerOffer;
  final bool isDealOffered;
  final bool hasPlayerAcceptedDeal;
  final double moneyWon;

  GameState(
  {
    required this.suitcases, 
    this.playerSuitcase, 
    this.holdsSuitcase = false,
    this.showMessage = false,
    this.isGameFinished = false,
    this.dealerOffer = 0.0,
    this.isDealOffered = false,
    this.hasPlayerAcceptedDeal = false,
    this.moneyWon = 0.0
  });

  // turn the state into JSON
  Map<String, dynamic> toMap(){
    return{
      'suitcases': suitcases.map((sc) => sc.toMap()).toList(),
      'playerSuitcase': playerSuitcase?.toMap(),
      'holdsSuitcase': holdsSuitcase,
      'showMessage': showMessage,
      'isGameFinished': isGameFinished,
      'dealerOffer': dealerOffer,
      'isDealOffered': isDealOffered,
      'hasPlayerAcceptedDeal': hasPlayerAcceptedDeal,
      'moneyWon': moneyWon
    };

  }

  // turn the JSON into a state
  factory GameState.fromMap(Map<String, dynamic> map)
  {return GameState(
    suitcases: List<SuitCase>.from(map['suitcases'].map((sc) => SuitCase.fromMap(sc))),
    playerSuitcase: map['playerSuitcase'] != null ? SuitCase.fromMap(map['playerSuitcase']) : null,
    holdsSuitcase: map['holdsSuitcase'],
    showMessage: map['showMessage'],
    isGameFinished: map['isGameFinished'],
    dealerOffer: map['dealerOffer'],
    isDealOffered: map['isDealOffered'],
    hasPlayerAcceptedDeal: map['hasPlayerAcceptedDeal'],
    moneyWon: map['moneyWon']
    );
  }

  // turn the object into JSON
  String toJson() => json.encode(toMap());

  // turn the JSON into an object
  factory GameState.fromJson(String source) {
    return GameState.fromMap(json.decode(source));

  }

}

class DealNoDealCubit extends HydratedCubit<GameState> {

  DealNoDealCubit() : super(GameState(suitcases: [])) {

    // restart the game if the list of suitcases is empty
    if (state.suitcases.isEmpty){    
      initializeGame();
    }
  }

  // function to initialize the game
  void initializeGame(){
    
      // create ten random numbers from 0 to 9
       List<int> randomNumbers = [];
      var random = Random();
      for (int i = 0; i < 10; i++){

        int randomNum = random.nextInt(10);
        while (randomNumbers.contains(randomNum)){
          randomNum = random.nextInt(10);
        }

        randomNumbers.add(randomNum);
      }

      // create 10 suitcases with the random numbers
      List<SuitCase> suitcases = [];
      for (int i = 0; i < 10; i++){

        double suitcasePrice = prices[randomNumbers[i]];

        SuitCase sc = SuitCase(i + 1, suitcasePrice, false, false);

        suitcases.add(sc);
      }

      emit(GameState(suitcases: suitcases));
  }

  // function to restart the game
  void restartGame(){
    initializeGame();
  }
  
  // function to open a suitcase
  void openSuitcase(int orderNum){

    List<SuitCase> updatedSuitcases = state.suitcases.map((sc) {
      if (sc.orderNum == orderNum){
        return SuitCase(sc.orderNum, sc.price, sc.isPicked, true);
      }
      return sc;
    }).toList();

    // calculate the offer and update the state
    double offer = calculateOffer(updatedSuitcases);


    // check if there are no more suitcases left
    int unopenedSuitcasedCount = 0;
    for (SuitCase sc in updatedSuitcases){
      if (!sc.isOpened && !sc.isPicked){
        unopenedSuitcasedCount++;
      }
    }

    // if there are no more suitcases left, end the game
    bool hasGameEnded = unopenedSuitcasedCount == 0;
    double rewardMoney = 0.0;
    
    if (hasGameEnded){
      // calculate the reward money from the player's suitcase
      rewardMoney = state.playerSuitcase?.price ?? 0.0;
    }

    emit(GameState(
      suitcases: updatedSuitcases,
      playerSuitcase: state.playerSuitcase,
      holdsSuitcase: state.holdsSuitcase,
      dealerOffer: offer,
      isDealOffered: true,
      isGameFinished: hasGameEnded,
      moneyWon: rewardMoney
      
      ));
  }

  // function to pick a suitcase
  void pickSuitcase(int orderNum){

    SuitCase? playerCase;

    List<SuitCase> suitcases = state.suitcases.map((sc) {
      if (sc.orderNum == orderNum){
        playerCase = SuitCase(sc.orderNum, sc.price, true, sc.isOpened);
        return SuitCase(sc.orderNum, sc.price, true, sc.isOpened);
      }
      return sc;
    }).toList();

    emit(GameState(
      suitcases: suitcases,
      playerSuitcase: playerCase,
      holdsSuitcase: true,
      showMessage: true, 
      ));

    Future.delayed(Duration(seconds: 3), () {   // wait for 3 seconds before displaying the next message
      emit(GameState(
       suitcases: suitcases,
       playerSuitcase: playerCase,
       holdsSuitcase: true,
       showMessage: false, 
      ));
    });
  }

  // function to calculate the offer
  double calculateOffer(List<SuitCase> suitcases) {
      double totalValue = 0;
      int remainingCases = 0;

      for (SuitCase sc in suitcases) {
        if (!sc.isOpened && !sc.isPicked) {
          totalValue += sc.price;
          remainingCases++;
        }
      }

      // check for division by zero
      if (remainingCases == 0) return 0;

      // Calculate expected value and take 90%
      double expectedValue = (totalValue / remainingCases).toDouble();
      return (expectedValue * 0.9);
  }

  // function to accept the deal
  void acceptDeal() {
    emit(GameState(
      suitcases: state.suitcases,
      playerSuitcase: state.playerSuitcase,
      holdsSuitcase: true,
      dealerOffer: state.dealerOffer,
      isDealOffered: false,
      hasPlayerAcceptedDeal: true,
      isGameFinished: true,
      moneyWon: state.dealerOffer.toDouble(),

    ));
  }

  // function to reject the deal
  void rejectDeal() {
    emit(GameState(
      suitcases: state.suitcases,
      playerSuitcase: state.playerSuitcase,
      holdsSuitcase: state.holdsSuitcase,
      dealerOffer: state.dealerOffer,
      isDealOffered: false,
    ));
  }
  
  @override
  GameState? fromJson(Map<String, dynamic> json) {
    return GameState.fromMap(json);
  }
  
  @override
  Map<String, dynamic>? toJson(GameState state) {
    return state.toMap();
  }


}


void main() async{

  WidgetsFlutterBinding.ensureInitialized();

  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorage.webStorageDirectory
        : await getApplicationDocumentsDirectory(),
      );

  runApp(DealNoDeal());
}

class DealNoDeal extends StatelessWidget{

  DealNoDeal({super.key});

  @override
  Widget build(BuildContext context){
    return MaterialApp
    (
      title: "Deal or No Deal",
      home: TopBloc(),
    );
  }
}

class TopBloc extends StatelessWidget{

  TopBloc({super.key});

  @override
  Widget build(BuildContext context){

    return BlocProvider<DealNoDealCubit>
    (
      create: (context) => DealNoDealCubit(),
      child: BlocBuilder<DealNoDealCubit, GameState>
      (
        builder: (context, state) => Home(),
      ),
    );
  }
}



class Home extends StatelessWidget{

  Home({super.key});


  // method to handle key press
  void pressKey(LogicalKeyboardKey key, DealNoDealCubit dndc){

    if (key == LogicalKeyboardKey.keyD && dndc.state.isDealOffered){  // Deal Button
      if (dndc.state.isDealOffered){
        dndc.acceptDeal();
      }
    } else if (key == LogicalKeyboardKey.keyN && dndc.state.isDealOffered){  // No Deal Button
      if (dndc.state.isDealOffered){
        dndc.rejectDeal();
      }
    } else if (!dndc.state.isGameFinished && !dndc.state.isDealOffered){  // Number Buttons
      int? number;

      if (key == LogicalKeyboardKey.digit1 || key == LogicalKeyboardKey.numpad1) number = 1;
      else if (key == LogicalKeyboardKey.digit2 || key == LogicalKeyboardKey.numpad2) number = 2;
      else if (key == LogicalKeyboardKey.digit3 || key == LogicalKeyboardKey.numpad3) number = 3;
      else if (key == LogicalKeyboardKey.digit4 || key == LogicalKeyboardKey.numpad4) number = 4;
      else if (key == LogicalKeyboardKey.digit5 || key == LogicalKeyboardKey.numpad5) number = 5;
      else if (key == LogicalKeyboardKey.digit6 || key == LogicalKeyboardKey.numpad6) number = 6;
      else if (key == LogicalKeyboardKey.digit7 || key == LogicalKeyboardKey.numpad7) number = 7;
      else if (key == LogicalKeyboardKey.digit8 || key == LogicalKeyboardKey.numpad8) number = 8;
      else if (key == LogicalKeyboardKey.digit9 || key == LogicalKeyboardKey.numpad9) number = 9;
      else if (key == LogicalKeyboardKey.digit0 || key == LogicalKeyboardKey.numpad0) number = 10;

      if (number != null){

        // find the corresponding suitcase
        SuitCase? selectedSuitcase;
        for (SuitCase sc in dndc.state.suitcases){
          if (sc.orderNum == number){
            selectedSuitcase = sc;
            break;
          }
        }

        if(selectedSuitcase != null && !selectedSuitcase.isOpened &&
        !(dndc.state.holdsSuitcase && dndc.state.playerSuitcase?.orderNum == selectedSuitcase.orderNum)){
          
          if (!dndc.state.holdsSuitcase){  // player is not holding a suitcase
            dndc.pickSuitcase(number);
          } else if (dndc.state.playerSuitcase?.orderNum != number){
            dndc.openSuitcase(number);
          }
        }
      }
    }
  }


  @override
  Widget build(BuildContext context){
    
    DealNoDealCubit dndc = BlocProvider.of<DealNoDealCubit>(context);

    return Scaffold
    (
      backgroundColor: Colors.brown[900],
      appBar: AppBar(
        title: Text("Deal or No Deal"),
        actions: [
          ElevatedButton(
              onPressed:() => dndc.restartGame(), child: Text("Restart Game"),
            ),
        ]
       ),
      body: 
      KeyboardListener(
        focusNode: focusNode,
        autofocus: true,
        onKeyEvent: (event){
          pressKey(event.logicalKey, dndc);
        },
        
             child: Center
          (
              child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [

                SizedBox(height: 10,),

                // check the game state and show the appropriate message
                if (dndc.state.isGameFinished)
                  Container 
                  ( 
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(width: 2),
                      borderRadius: BorderRadius.circular(4),
                      color: Colors.grey[200],
                    ),
                    child: Text(
                      dndc.state.hasPlayerAcceptedDeal
                      ? "Game Over! You won \$${dndc.state.moneyWon.toStringAsFixed(2)}"
                      : "Game Over! Your suitcase had \$${dndc.state.playerSuitcase?.price.toStringAsFixed(2)}",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),


                 // Create two rows of 5 suitcases each with a price from the list
                for (int i = 0; i < 2; i++)
                  Row(
                  mainAxisAlignment: MainAxisAlignment.center, 
                  children: [
                    for (int j = 0; j < 5; j++)
                      Container(
                        width: 125, 
                        height: 75,
                        margin: EdgeInsets.all(4), 
                        decoration: BoxDecoration(
                          border: Border.all(width: 1),
                          borderRadius: BorderRadius.circular(4),
                          color: dndc.state.suitcases[i * 5 + j].isPicked ?
                           Colors.yellow :
                            dndc.state.suitcases[i * 5 + j].isOpened ? Colors.brown[900] : Colors.grey[200],
                          
                        ),
                        child: ElevatedButton(
                          // if the suitcase is opened, show the price, else show the suitcase number
                          onPressed:() {

                              if (dndc.state.isGameFinished || dndc.state.isDealOffered || dndc.state.suitcases[i * 5 + j].isOpened) {
                                return null;
                              }
                          
                              // check for the first suitcase the player picks
                              if (dndc.state.holdsSuitcase == false) {
                                dndc.pickSuitcase(dndc.state.suitcases[i * 5 + j].orderNum);
                              } 
                              else if (dndc.state.holdsSuitcase && dndc.state.playerSuitcase?.orderNum != dndc.state.suitcases[i * 5 + j].orderNum){   // open any other suitcase the player picks except for the one they picked
                                dndc.openSuitcase(dndc.state.suitcases[i * 5 + j].orderNum);
                              }

                         
                          },
                          // if the suitcase is picked, color the player's suitcase yellow, else keep the original color
                          // once the suitcase is opened, show the price then 
                          style: ElevatedButton.styleFrom(
                            backgroundColor: dndc.state.suitcases[i * 5 + j].isOpened 
                            ? Colors.brown[900]
                            : dndc.state.playerSuitcase?.orderNum == dndc.state.suitcases[i * 5 + j].orderNum
                            ? Colors.yellow
                            : Colors.grey[200],
                            foregroundColor: dndc.state.suitcases[i * 5 + j].isOpened 
                            ? Colors.white
                            : Colors.brown[900],

                          ),
                          child: Text(
                            dndc.state.suitcases[i * 5 + j].isOpened 
                            ? "${dndc.state.suitcases[i * 5 + j].price.toStringAsFixed(0)}" 
                            : "${dndc.state.suitcases[i * 5 + j].orderNum}",
                            style: TextStyle(fontSize: 15),
                          ),
                        ),
                      )
                  ],
                ),

                SizedBox(height: 10,),

                // display the dealer's offer

                if (dndc.state.isDealOffered && !dndc.state.isGameFinished)
                  Container 
                  (
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all (width: 2),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Column(
                      children: [

                        Text( 
                          "The dealer offers you \$${dndc.state.dealerOffer.toStringAsFixed(2)}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          )
                        ),

                        SizedBox(height: 10,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                
                              onPressed: () => dndc.acceptDeal(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: Text("Deal", style: TextStyle(fontSize: 15),),
                            ),

                            SizedBox(width: 20,),

                            ElevatedButton(
                              onPressed: () => dndc.rejectDeal(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: Text("No Deal", style: TextStyle(fontSize: 15),),
                              )
                          ]
                        )
                      ]
                    )
                  ),

              SizedBox(height: 10,),

              // welcome message and instrutions
              Container(
                padding: EdgeInsets.all(10),
                child: 
                !dndc.state.holdsSuitcase     // player doesnt have a suitcase
                ? Text (
                  "Welcome to Deal or No Deal! \n"
                  "Click on a suitcase to pick it.", 
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                )

                : dndc.state.showMessage // player has a suitcase
                  ? Text (
                    "You've picked suitcase #${dndc.state.playerSuitcase?.orderNum}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  )
                  : dndc.state.isDealOffered
                  ? Text(
                    "Deal or No Deal?",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ) 
                  : !dndc.state.isGameFinished
                  ? Text(
                    "Choose a suitcase to open",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                    ) : Text(
                      "Game Over",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                      )

              ),

              SizedBox(height: 10,),
                Wrap(

                // crossAxisAlignment: CrossAxisAlignment.start,
                alignment: WrapAlignment.spaceBetween,
                children: [
                    
                    Column(


                      // Vertical list of first five prices still to be opened
                      children: [
                        for (int i = 0; i < 5; i++)
                          Container(
                            height: 25,
                            width: 125,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1),
                              borderRadius: BorderRadius.circular(4),
                              // if the suitcase is revealed, change the color, else keep the original color
                              color: dndc.state.suitcases.any((sc) => sc.price == prices[i] && sc.isOpened) ? Colors.lime[900] : Colors.amber[300],
                            ),
                            margin: EdgeInsets.only(bottom: 5),
                            child: Padding(
                              padding: EdgeInsets.only(right: 3),
                              child: Text(" \$ ${prices[i].toStringAsFixed(0)}", style: TextStyle(fontSize: 15),
                              textAlign: TextAlign.right,)
                            ),
                            
                          )
                          
                      ]
                    ),

                    
                    !dndc.state.isGameFinished? 
                    SizedBox(width: 400) 
                    :

                    Padding(
                      padding: const EdgeInsets.fromLTRB(70, 0, 70, 0),
                      child: Column(
                        children:[
                            Text(
                                dndc.state.hasPlayerAcceptedDeal
                                    ? "You accepted the deal!"
                                    : "You kept your suitcase!",
                                style: TextStyle(fontSize: 24, color: Colors.amber),
                              ),
                              
                              Text(
                                dndc.state.hasPlayerAcceptedDeal
                                    ? "You won \$${dndc.state.moneyWon.toStringAsFixed(2)}"
                                    : "Your suitcase contained \$${dndc.state.playerSuitcase?.price.toStringAsFixed(2)}",
                                style: TextStyle(fontSize: 24, color: Colors.amber, fontWeight: FontWeight.bold),
                              ),
                              if (dndc.state.hasPlayerAcceptedDeal)
                                Text(
                                  "Your suitcase\ncontained \$${dndc.state.playerSuitcase?.price.toStringAsFixed(2)}",
                                  style: TextStyle(fontSize: 20, color: Colors.grey[300]),
                                ),
       
                          ],
                       ),
                    ),


                    Column(
                      // Vertical list of last five prices still to be opened
                      children: [
                        for (int i = 5; i < 10; i++)
                          Container(
                            height: 25,
                            width: 125,
                            decoration: BoxDecoration(
                              border: Border.all(width: 1),
                              borderRadius: BorderRadius.circular(4),
                              // if the suitcase is revealed, change the color, else keep the original color
                              color: dndc.state.suitcases.any((sc) => sc.price == prices[i] && sc.isOpened) ? Colors.lime[900] : Colors.amber[300],
                            ),
                            margin: EdgeInsets.only(bottom: 5),
                            child: Padding(
                              padding: EdgeInsets.only(right: 3),
                              child: Text(" \$ ${prices[i].toStringAsFixed(0)}", style: TextStyle(fontSize: 15),
                              textAlign: TextAlign.right,)
                            ),
                            
                          )
                          
                      ]
                    ),

                  ],
                ),

              ],
            ),
      
        ),
      ),
    );
    
  }


}


