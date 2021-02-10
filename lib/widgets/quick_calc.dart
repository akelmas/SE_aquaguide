import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:predixinote/services/database.dart';
import 'package:predixinote/types/constants.dart';
import 'package:predixinote/types/parameter.dart';
import 'package:predixinote/types/plant.dart';

Map<String, dynamic> calcDB=new Map<String,dynamic>();
void updateCalcDB(Parameter parameter,Plant plant) {

  calcDB[parameter.name]=parameter.value;
  calcDB["TP"]=calculateTP();
  calcDB["HM"]=calculateHm(plant);
  calcDB["NPUMP"]=calculateNPump(plant);
}

double calculateNPump(Plant plant) {
  try {
    double q = calcDB["Debi"]??0;
    double hm = calculateHm(plant);
    double p = calculateTP();
    double nm=calcDB["Motor Verimi"]??0;

    return (q * hm) / (367 * p*nm) *10000;
  } catch (e) {
    return 0;
  }
}

double calculateWaterVelocity(){
  try{
    double q=calcDB["Debi"]??0;
    double A=calcDB["Basma Çapı"]??calcDB["Çıkış Çapı"]??0;
    return q/(pi*A*A/4000000*3600);
  }catch(e){
    return 0;
  }
}

double calculateHm(Plant plant) {
  try {
    switch (plant.type) {
      case Plant.KUYU:
        double p = calcDB["Basınç"]??0;
        double ds= calcDB["Dinamik Seviye"]??0;
        return p*10 +  ds+ 3;
      case Plant.TERFI:
        double bb = calcDB["Basma Basıncı"]??0;
        double eb = calcDB["Emme Basıncı"]??0;
        return (bb - eb) * 10 + 1;
      default:
        return 0;
    }
  } catch (e) {
    print(e);
    return 0;
  }
}

double calculateTP() {
  try {
    double p1 = calcDB["Güç (L1)"]??0;
    double p2 = calcDB["Güç (L2)"]??0;
    double p3 = calcDB["Güç (L3)"]??0;
    return p1 + p2 + p3;
  } catch (e) {
    return 0;
  }
}

class QuickCalcOffline{

  final Plant plant;

  QuickCalcOffline(this.plant);

  Future<Map<String, double>> getSummary()async{
    await DatabaseService().parametersCollection.where('plantId',isEqualTo: plant.uid).get().then((event) {
      for(final doc in event.docs){
        final Parameter parameter=Parameter.fromJson(doc.data());
        calcDB[parameter.name]=parameter.value;
      }
    });
    return {
      "Toplam güç":calculateTP()??0,
      "Basma yüksekliği":calculateHm(plant)??0,
      "Hidrolik verim":calculateNPump(plant)??0,
      "Su hızı":calculateWaterVelocity()??0,
      "Debi":calcDB["Debi"],
    };

  }

}


class QuickCalc extends StatefulWidget {
  final Plant plant;

  const QuickCalc({Key key, this.plant}) : super(key: key);

  @override
  _QuickCalcState createState() => _QuickCalcState();
}

class _QuickCalcState extends State<QuickCalc> {
  bool collapsed=true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    DatabaseService().parametersCollection.where('plantId',isEqualTo: widget.plant.uid).snapshots().listen((event) {
      for(final doc in event.docs){
        final Parameter parameter=Parameter.fromJson(doc.data());
        calcDB[parameter.name]=parameter.value;
        if(mounted){
          setState(() {
          });
        }
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    switch (widget.plant.type) {
      case Plant.DEPO:
        return SizedBox(
          height: 0,
        );

      default:
        return Container(
          padding: EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              collapsed?SizedBox(height: 0,):Table(
                columnWidths: {
                  0:FlexColumnWidth(5),
                  1:FlexColumnWidth(5),
                  2:FlexColumnWidth(2)
                },
                children: [
                  result(
                      title: "Toplam güç",
                      value: calculateTP(),
                      unit: units["power"],
                      color: Colors.white),
                  result(
                      title: "Basma yüksekliği",
                      value: calculateHm(widget.plant),
                      unit: units["hm"],
                      color: Colors.white),
                  result(
                      title: "Hidrolik verim",
                      value: calculateNPump(widget.plant),
                      unit: units["percentage"],
                      color: Colors.white),
                  result(
                      title: "Su hızı",
                      value: calculateWaterVelocity(),
                      unit: units["speed"],
                      color: Colors.white),
                ],
              ),
              OutlineButton.icon(
                borderSide: BorderSide.none,
                label: Text("QuickCalc"),
                icon: Icon(collapsed?Icons.keyboard_arrow_down_sharp:Icons.keyboard_arrow_up_sharp),
                onPressed: (){
                  setState(() {
                    collapsed=!collapsed;
                  });
                },

              )
            ],
          )
        );
    }
  }

  TableRow result({String title, double value, String unit,Color color}) {

    return TableRow(
        children:[
          TableCell(
              child:Text(
                "$title",
                style: GoogleFonts.roboto(color: color),
              )
          ),
          TableCell(
            child: Text(
              "${(value==double.nan)?"-0":value.toStringAsFixed(2)}",
              style: GoogleFonts.robotoMono(fontSize: 16,color: color,fontWeight: FontWeight.bold),textAlign: TextAlign.end,
            ),
          ),

          TableCell(
              child:Text(
                " $unit",
                style: GoogleFonts.robotoMono(fontSize: 16,color: color),
              )
          ),
        ]
    );

  }
}
