import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_bloc/flutter_bloc.dart';

// api key = 2952c8b3ce1284d5d8e90e46
class ExchangeRateModel
{

  late String baseCountry;
  late List<Map<String, dynamic>> rates;

  ExchangeRateModel(String country, List<Map<String, dynamic>> list)
   : baseCountry = country,
     rates = list;

  ExchangeRateModel.p2
  (this.baseCountry, this.rates);

  ExchangeRateModel.fromJson(dynamic response){

    baseCountry = jsonDecode(response.body)["base_code"];

    // country = jsonDecode(response.body)["base_code"];

    // display rates for base country, AUD, GBP, CAD, and EUR
    // store currency and rate as a map
     rates = [

      {"USD": jsonDecode(response.body)["conversion_rates"]["USD"] ?? 0.0 },
      {"AUD": jsonDecode(response.body)["conversion_rates"]["AUD"] ?? 0.0 },
      {"BGN": jsonDecode(response.body)["conversion_rates"]["BGN"] ?? 0.0 },
      {"GBP": jsonDecode(response.body)["conversion_rates"]["GBP"] ?? 0.0 },
      {"CAD": jsonDecode(response.body)["conversion_rates"]["CAD"] ?? 0.0 },
      {"EUR": jsonDecode(response.body)["conversion_rates"]["EUR"] ?? 0.0 },
      {"CHF": jsonDecode(response.body)["conversion_rates"]["CHF"] ?? 0.0 },
      {"CNY": jsonDecode(response.body)["conversion_rates"]["CNY"] ?? 0.0 },
      {"EGP": jsonDecode(response.body)["conversion_rates"]["EGP"] ?? 0.0 },
    ];


  }

    
}

class ExchangeRateCubit extends Cubit<ExchangeRateModel>
{
  ExchangeRateCubit() : super(ExchangeRateModel("", []));

  Future<void> update(String country) async
  {

    String apiUrl = "https://v6.exchangerate-api.com/v6/2952c8b3ce1284d5d8e90e46/latest/$country";
    final url = Uri.parse(apiUrl);

    final response = await http.get(url);
    emit(ExchangeRateModel.fromJson(response));
  }
}

