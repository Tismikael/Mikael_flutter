import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'lab_api_model.dart';

// list of currencies
List<String> currencies = 
['USD','AUD', 'BGN', 'GBP', 'CAD', 'EUR', 'CHF', 'CNY', 'EGP',];

String errorMessage = "Enter a valid currency code";
bool error = false;

void main() {
  runApp(const ExchangeRate());
}

class ExchangeRate extends StatelessWidget {
  const ExchangeRate({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Exchange Rate",
      home: Scaffold
      (appBar: AppBar(title: Text("Exchange Rate")),
        body: BlocProvider<ExchangeRateCubit>
        ( create: (context) => ExchangeRateCubit(),
          child: BlocBuilder<ExchangeRateCubit,ExchangeRateModel>
          ( builder: (context,state)
            { return ExchangeRate1(); }
          ),
        ),
      ),
      );
  }

}


class ExchangeRate1 extends StatelessWidget {
  const ExchangeRate1({super.key});


  @override
  Widget build(BuildContext context) {

    ExchangeRateCubit erc = BlocProvider.of<ExchangeRateCubit>(context);
    TextEditingController tec = TextEditingController();


    return Column
    (
    
      children: 
      [
        Text("Check the exchange rate for the following currencies:", style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),),
        SizedBox(height: 30,),
            // Display list of exchange rates user can choose from
        Row
        (
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("US Dollar(USD)", style: TextStyle(fontSize: 20),),
            Text("Australian Dollar(AUD)", style: TextStyle(fontSize: 20),),
            Text("Bulgarian Lev(BGN)", style: TextStyle(fontSize: 20),),
          ],
        ),
        Row
        (
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("Great Britain Pound(GBP)", style: TextStyle(fontSize: 20),),
            Text("Canadian Dollar(CAD)", style: TextStyle(fontSize: 20),),
            Text("Euro(EUR)", style: TextStyle(fontSize: 20),),
          ],
        ),
        Row
        (
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Text("Swiss Franc(CHF)", style: TextStyle(fontSize: 20),),
            Text("Chinese Yuan(CNY)", style: TextStyle(fontSize: 20),),
            Text("Egyptian Pound(EGP)", style: TextStyle(fontSize: 20),),
          ]

        ),

        SizedBox(height: 30,),

        Row
        (
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Text("Enter currency code below", style: TextStyle(fontSize: 20),),

            SizedBox
            (
              width: 150,
              height: 50,
              child:
              ElevatedButton
              (
                onPressed: () async {
                  // check if input is valid
                  if (currencies.contains(tec.text.toUpperCase())){
                    error = false;
                    await erc.update(tec.text.toUpperCase());
                  }

                  else 
                     error = true;
                  
                },
                child: Text("Get Rates"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[300],
                  foregroundColor: Colors.white,
                )
              ),
            ),

          ]
        ),

        // Display error message if input is not valid
        if (error)
        Align
        (
          alignment: Alignment.center,
          child: Text(errorMessage, style: TextStyle(color: Colors.red, fontSize: 15),),
        ),

        Align
        (
          alignment: Alignment(-0.5, 0),
          child: 
              Container
            (
              width:150,
              height: 45,
              alignment: Alignment.centerLeft,
              decoration: BoxDecoration(
                border: Border.all(width: 1),
              ),
              child: TextField
            (
              controller: tec,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15),
            ),
          ),
        ),

        SizedBox(height: 20,),

        // Display exchange rates
        if (erc.state.rates.isNotEmpty)
            Align
            (
              alignment: Alignment.center,
              child: Column
              (
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("USD:\t${erc.state.rates[0]['USD']}", style: TextStyle(fontSize: 20),),
                      Text("AUD:\t${erc.state.rates[1]['AUD']}", style: TextStyle(fontSize: 20),),
                      Text("BGN:\t${erc.state.rates[2]['BGN']}", style: TextStyle(fontSize: 20),),
                    ]
                  ),
  
                  Row
                  (
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("GBP:\t${erc.state.rates[3]['GBP']}", style: TextStyle(fontSize: 20),),
                      Text("CAD:\t${erc.state.rates[4]['CAD']}", style: TextStyle(fontSize: 20),),
                      Text("EUR:\t${erc.state.rates[5]['EUR']}", style: TextStyle(fontSize: 20),),
                    ]
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("CHF:\t${erc.state.rates[6]['CHF']}", style: TextStyle(fontSize: 20),),
                      Text("CNY:\t${erc.state.rates[7]['CNY']}", style: TextStyle(fontSize: 20),),
                      Text("EGP:\t${erc.state.rates[8]['EGP']}", style: TextStyle(fontSize: 20),),
                    ]
                  ),

                ],
              ),
            ),
        


      ],
    );
  }

}