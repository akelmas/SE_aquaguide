
import 'dart:async';
import 'dart:collection';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:predixinote/pages/project_list_view.dart';
import 'package:predixinote/types/parameter.dart';
import 'package:localstorage/localstorage.dart';
import 'package:predixinote/types/user.dart';
import 'package:rxdart/rxdart.dart';
import 'package:uuid/uuid.dart';
//a common variable to represent current user
PUser activeUser;
StreamController<Widget> widgetStreamController =BehaviorSubject(sync: true);
Queue<Widget> navigator=new Queue<Widget>();
StreamController<Widget> bottomNavBarStreamController =BehaviorSubject();
GlobalKey<ScaffoldState> homeState=new GlobalKey<ScaffoldState>();

showInBottomNav(final Widget widget){
  bottomNavBarStreamController.add(widget);
}
hideBottomNav ()async{
  bottomNavBarStreamController.add(null);
}


goto(final Widget target){
  Type current=navigator.first.runtimeType;
  Type next=target.runtimeType;
  print(current);
  print(next);
  if(next==ProjectListView){
    navigator.clear();
    navigator.addFirst(target);
    widgetStreamController.add(navigator.first);
  }else if(current!=next){
    navigator.addFirst(target);
    widgetStreamController.add(navigator.first);
  }


}
goback(){
  if(navigator.isNotEmpty){
    navigator.removeFirst();
  }
  if(navigator.isEmpty){
    navigator.add(ProjectListView());
  }
  widgetStreamController.add(navigator.first);
}




//kuyu parameters template

List<Parameter> kuyuParameters(String plantId)=><Parameter>[
  Parameter(0,plantId,Uuid().v1(),"Güç (L1)","power",true),
  Parameter(1,plantId,Uuid().v1(),"Güç (L2)","power",true),
  Parameter(2,plantId,Uuid().v1(),"Güç (L3)","power",true),
  Parameter(3,plantId,Uuid().v1(),"Debi","flow",true),
  Parameter(4,plantId,Uuid().v1(),"Dinamik Seviye","distance",true),
  Parameter(5,plantId,Uuid().v1(),"Basınç","pressure",true),
  Parameter(6,plantId,Uuid().v1(),"Motor Verimi","percentage",true),
  Parameter(7,plantId,Uuid().v1(),"Montaj Seviyesi","distance",false),
  Parameter(8,plantId,Uuid().v1(),"Çıkış Çapı","diameter",false),
  Parameter(9,plantId,Uuid().v1(),"Akım (L1)","current",false),
  Parameter(10,plantId,Uuid().v1(),"Akım (L2)","current",false),
  Parameter(11,plantId,Uuid().v1(),"Akım (L3)","current",false),
];
//terfi template
List<Parameter> terfiParameters(String plantId)=><Parameter>[
  Parameter(0,plantId,Uuid().v1(),"Güç (L1)","power",true),
  Parameter(1,plantId,Uuid().v1(),"Güç (L2)","power",true),
  Parameter(2,plantId,Uuid().v1(),"Güç (L3)","power",true),
  Parameter(3,plantId,Uuid().v1(),"Debi","flow",true),
  Parameter(4,plantId,Uuid().v1(),"Emme Basıncı","pressure",true),
  Parameter(5,plantId,Uuid().v1(),"Basma Basıncı","pressure",true),
  Parameter(6,plantId,Uuid().v1(),"Motor Verimi","percentage",true),
  Parameter(7,plantId,Uuid().v1(),"Emme Çapı","diameter",false),
  Parameter(8,plantId,Uuid().v1(),"Basma Çapı","diameter",false),
  Parameter(9,plantId,Uuid().v1(),"Akım (L1)","current",false),
  Parameter(10,plantId,Uuid().v1(),"Akım (L2)","current",false),
  Parameter(11,plantId,Uuid().v1(),"Akım (L3)","current",false),
];
//depo template
List<Parameter> depoParameters(String plantId)=><Parameter>[
  Parameter(0,plantId,Uuid().v1(),"Depo Hacmi","volume",true),
  Parameter(1,plantId,Uuid().v1(),"Giriş Debisi","flow",true),
  Parameter(2,plantId,Uuid().v1(),"Çıkış Debisi","flow",true),
];
class AquaNote{
  static int parameter;
  static int plant;
  static final storage = new LocalStorage('aqdata.json');
  static String searchPhrase;
  static const int PHOTO=-1;
  static const int INFO=-2;
  static const int PDFEXPORT=-3;





}
