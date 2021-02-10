
import 'dart:convert';
import "package:http/http.dart" as http;
import 'package:predixinote/pages/map_view.dart';


Future<Place> searchByQuery(String query)async{
  final res=await  http.get("https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=$query&inputtype=textquery&fields=formatted_address,name,geometry/location&key=AIzaSyBd2vUKIoKROLoIAkPtLaO1GMXEcFFx9J4");
  final json=jsonDecode(res.body);
  final status=json["status"];
  if(status!="OK"){
    return null;
  }
  final candidates=json["candidates"];
  return Place.fromJson(candidates[0]);
}