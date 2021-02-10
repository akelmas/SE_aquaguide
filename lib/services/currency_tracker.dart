import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:predixinote/types/currency.dart';
class CurrencyTracker{
  static const String TCMB_URL="https://www.tcmb.gov.tr/kurlar/today.xml";
  static const String TRUBCGIL_URL="https://finans.truncgil.com/today.json";



  Future<Currency> usd()async{
    http.Response resp=await http.get(TRUBCGIL_URL);
    final usd=Currency.fromJson('ABD DOLARI',jsonDecode(resp.body)["ABD DOLARI"]);
    return usd;


  }



}