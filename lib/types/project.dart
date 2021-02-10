import 'package:predixinote/types/aquanote.dart';
import 'package:predixinote/types/plant_group.dart';
import 'package:predixinote/types/user.dart';

class Project{
  String uid;
  String name;
  List<PUser> members=new List<PUser>();
  String info;
  DateTime lastUpdate;
  Project({this.uid,this.name,this.info});

  Project.fromJson(Map<String,dynamic> json)
  : name=json['name'],
  members=(json['members'] as List).cast<Map<String,dynamic>>().map((json)=>(PUser.fromJson(json))).toList(),
  uid=json['uid'],
  info=json['info'],
  lastUpdate=DateTime.parse(json['lastUpdate']);

  Map<String,dynamic> toJson()=>{
    'name':name,
    'members':members.map((user)=>user.toJson()).toList(),
    'uid':uid,
    'info':info,
    'lastUpdate':(lastUpdate??DateTime.now()).toIso8601String()
  };

  Project.create(String uid){
    this.uid=uid;
    this.name="";
    this.info="";
    this.lastUpdate=DateTime.now();
  }

  Project.fromPlantGroup(PlantGroup plantGroup):
      name=plantGroup.name,
      uid=plantGroup.uid,
      lastUpdate=plantGroup.dateCreated??DateTime.now(),members=<PUser>[activeUser],
      info=plantGroup.info;

}