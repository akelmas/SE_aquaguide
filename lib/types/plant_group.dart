import 'package:predixinote/types/project.dart';

class PlantGroup{

  String uid;
  String projectId;
  String name;
  String info;
  DateTime dateCreated;
  DateTime lastChange;

  PlantGroup.fromJson(Map<String, dynamic> json):
      uid=json['uid'],
      projectId=json['projectId'],
      name=json['name'],
      info=json['info'],
  dateCreated=DateTime.parse(json["dateCreated"]??DateTime.now().toIso8601String()),
  lastChange=DateTime.parse(json["lastChange"]??DateTime.now().toIso8601String());

  Map<String,dynamic> toJson()=>{
    'uid':uid,
    'projectId':projectId,
    'name':name,
    'info':info,
    "dateCreated":(dateCreated??DateTime.now()).toIso8601String(),
    "lastChange":(lastChange??DateTime.now()).toIso8601String()
  };

  PlantGroup(this.uid,this.projectId,this.name):
      dateCreated=DateTime.now();

  PlantGroup.fromProject(Project project, String targetProjectUID):
      uid=project.uid,
      name=project.name,
      info=project.info,
      projectId=targetProjectUID,
      dateCreated=project.lastUpdate;
}
