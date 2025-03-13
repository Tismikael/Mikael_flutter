// Mikael Yikum
// Weather Lab

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

// weather info class
class WeatherInfoState
{
  
  String temp;
  String city;
  WeatherInfoState(this.temp, this.city);
}

class WeatherInfoCubit extends Cubit<WeatherInfoState>
{
  WeatherInfoCubit() : super(WeatherInfoState("", ""));

  // method to update the info
  void updateTemp(String temp, String city) {
    emit(WeatherInfoState(temp, city));
  }
}

void main() {
  runApp( const Weather() );
}

class Weather extends StatelessWidget {

  const Weather({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Weather",
      home: TopBloc(), 
    );
  }
}

class TopBloc extends StatelessWidget {

  const TopBloc({super.key});

  @override
  Widget build(BuildContext context){
    return BlocProvider<WeatherInfoCubit> (
      create: (context) => WeatherInfoCubit(),
      child: BlocBuilder<WeatherInfoCubit, WeatherInfoState>
      (builder: (context, state) => WeatherHome()),
    );
  }
}

class WeatherHome extends StatelessWidget {

  WeatherHome({super.key});
  TextEditingController tec = TextEditingController();

  @override
  Widget build(BuildContext context) {
      WeatherInfoCubit wic = BlocProvider.of<WeatherInfoCubit>(context);

      return Scaffold
      (
        appBar: AppBar(title: Text("Weather App"), ),
        body:
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
              Center(
                child: 
                  Column(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
              
                    children: 
                    [
                      Text("Enter the zip code below", textAlign: TextAlign.center,),

                      SizedBox(height: 10,),

                      Row
                      (
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                              Container
                                (
                                  width: 200,
                                  height: 45,
                                  
                                  decoration: BoxDecoration(
                                    border: Border.all(width: 2),
                                  ),
                                  child: TextField
                                (
                                  controller: tec,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(fontSize: 15),
                                ),
                              ),

                              SizedBox(width: 10,),

                              ElevatedButton
                              (onPressed: () async
                                {
                                  // retrieve the temperature and city
                                  List<String> result = await calcTemp(tec.text);
                                  String city = result[0];
                                  String temp = result[1];
                                  await Future.delayed( Duration(milliseconds: 2000) );
                                  wic.updateTemp(temp, city);
                                },
                                child: Text("get temp"),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue[400],
                                  foregroundColor: Colors.white,
                                    shape: const RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(4)),
                                    ),  
                                )
                              
                              ),


                        ],
                      ),
                    ],
                  )
                
              ),

              SizedBox(height: 15,),

              Column
              (
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Zip code maps to the city of ", style: TextStyle(fontSize: 15)),
                      Text(wic.state.city, style: TextStyle(fontSize: 15),),
                    ],
                  ), 

                    Text("Current temperature is ${wic.state.temp} °F", style: TextStyle(fontSize: 15)),

                ],
              )
          ],
        ),

      );

  }

  Future<List<String>> calcTemp(String zipcode) async
  {
    List<String> res = [];
    String input = 'http://api.weatherapi.com/v1/current.json?key=077009a77f24467e8e800600251303&q=' + zipcode + '&aqi=no';
    final url = Uri.parse(input);

    final response = await http.get(url);

    Map<String, dynamic> dataAsMap = jsonDecode(response.body);
    Map<String, dynamic> locationData = dataAsMap["location"];    // to retrieve city name
    Map<String , dynamic> currentData = dataAsMap["current"];     // to retrieve current temp


    String city = locationData["name"];
    double tempF = currentData["temp_f"];

    String tempFstr = tempF.toString();

    res.add(city);
    res.add(tempFstr);

    return res;
  }
}