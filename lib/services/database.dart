
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:predixinote/types/aquanote.dart';
import 'package:predixinote/types/exporter.dart';
import 'package:predixinote/types/parameter.dart';
import 'package:predixinote/types/plant.dart';
import 'package:predixinote/types/plant_group.dart';
import 'package:predixinote/types/project.dart';
import 'package:predixinote/types/user.dart';
import 'package:predixinote/widgets/quick_calc.dart';

class DatabaseService {
  static  String uid;
  final CollectionReference projectsCollection=FirebaseFirestore.instance.collection('projects_beta');
  final CollectionReference deletedProjectsCollection=FirebaseFirestore.instance.collection('deleted_projects_beta');
  final CollectionReference plantsCollection=FirebaseFirestore.instance.collection('plants_beta');
  final CollectionReference deletedPlantsCollection=FirebaseFirestore.instance.collection('deleted_plants_beta');
  final CollectionReference parametersCollection=FirebaseFirestore.instance.collection('parameters');
  final CollectionReference plantGroupsCollection=FirebaseFirestore.instance.collection('groups');
  final CollectionReference deletedPlantGroupsCollection=FirebaseFirestore.instance.collection('deleted_groups');
  final CollectionReference usersCollection=FirebaseFirestore.instance.collection('users');

  final CollectionReference oldprojectsCollection=FirebaseFirestore.instance.collection('projects');


  Future updateProject(Project project) async {

    project.lastUpdate=DateTime.now(); //keep as created
    return await projectsCollection.doc(project.uid).update(project.toJson());
  }
  Future<PUser> getUserInformation(String uid) async {
    final doc=await usersCollection.doc(uid).get();
    return new PUser.fromJson(doc.data());
  }
  Future<bool> isExistingUser(String uid) async {

    try{
      final document=await usersCollection.doc(uid).get();
      print(document.data);

      return  document.exists;
    }catch(e){
      return false;

    }

  }

  //checks if a plant exists with a same name
  Future<bool> isExistingPlant(Plant plant) async {
    final documents= await plantsCollection.where('groupId',isEqualTo: plant.groupId).where('name',isEqualTo: plant.name).get();
    for(final doc in documents.docs){
      final _plant=Plant.fromJson(doc.data());
      if(plant.name==_plant.name){
        return true;
      }
    }
    return false;
  }

  Future<bool> isExistingPlantGroup(PlantGroup plantGroup) async {
    final documents= await plantGroupsCollection.where('projectId',isEqualTo: plantGroup.projectId).where('name',isEqualTo: plantGroup.name).get();
    for(final doc in documents.docs){
      final _plantGroup=PlantGroup.fromJson(doc.data());
      if(plantGroup.name==_plantGroup.name){
        return true;
      }
    }
    return false;
  }


  //checks if a project exists with a same name
  Future<bool> isExistingProject(Project project) async {
    final documents= await projectsCollection.where('name',isEqualTo: project.name).get();
    for(final doc in documents.docs){
      final _project=Project.fromJson(doc.data());
      if(project.name==_project.name){
        return true;
      }
    }
    return false;


  }


  Future addProject(Project project) async {
    return await projectsCollection.doc(project.uid).set(project.toJson());
  }
  Future addPlantGroup(PlantGroup plantGroup) async {
    if(await isExistingPlantGroup(plantGroup)){
      throw PlatformException(code:"ERR_EXISTING_PLANTGROUP",message: "Nokta adı zaten kayıtlı");

    }
    return await plantGroupsCollection.doc(plantGroup.uid).set(plantGroup.toJson());
  }


  Future<void> deleteProject(Project project)async{
    await deletedProjectsCollection.doc(project.uid).set(project.toJson());
    await projectsCollection.doc(project.uid).delete();
  }
  Future<void> deletePlant(Plant plant)async{
    await deletedPlantsCollection.doc(plant.uid).set(plant.toJson());
    await plantsCollection.doc(plant.uid).delete();

  }
  Future addUser(PUser user)async{
    return await usersCollection.doc(user.uid).set(user.toJson());
  }

  Future addPlant(Plant plant)async {
    if (await isExistingPlant(plant)){
      throw PlatformException(code:"ERR_EXISTING_PLANT",message: "Ölçüm adı zaten kayıtlı");
    }
    await setParameterList(plant);
   return await plantsCollection.doc(plant.uid).set(plant.toJson());
  }
  Future updatePlant(Plant plant)async{
    plant.lastChange=DateTime.now();
    return await plantsCollection.doc(plant.uid).update(plant.toJson());
  }

  Future setParameter(Parameter parameter)async{
    await plantsCollection.doc(parameter.plantId).set({"lastChange":DateTime.now().toIso8601String()},SetOptions(merge: true));
    return await parametersCollection.doc(parameter.uid).set(parameter.toJson());
  }
  Future<void> setParameterList(Plant plant)async{
    List<Parameter> parameters;
    switch(plant.type){
      case Plant.KUYU:
        parameters=kuyuParameters(plant.uid);
        break;
      case Plant.TERFI:
        parameters=terfiParameters(plant.uid);
        break;
      case Plant.DEPO:
        parameters=depoParameters(plant.uid);
        break;
    }
    for(var param in parameters){
      await setParameter(param);
    }
  }

  Future<void> deletePlantGroup(PlantGroup plantGroup) async {
      await deletedPlantGroupsCollection.doc(plantGroup.uid).set(plantGroup.toJson());
      await plantGroupsCollection.doc(plantGroup.uid).delete();
  }

  Future<void> updatePlantGroup(PlantGroup plantGroup)async {
    plantGroup.lastChange=DateTime.now();
    await plantGroupsCollection.doc(plantGroup.uid).set(plantGroup.toJson());
  }

  Future<Project> getProjectById(String uid)async{
    return Project.fromJson((await projectsCollection.doc(uid).get()).data());
  }


  Future<PlantGroup> getPlantGroupById(String uid)async{
    return PlantGroup.fromJson((await plantGroupsCollection.doc(uid).get()).data());
  }

  Future<Plant> getPlantById(String uid) async{
    return Plant.fromJson((await plantsCollection.doc(uid).get()).data());
  }


  Future getPlantsByGroup(PlantGroup plantGroup)async{
    final Map<String,Plant> plants=new Map<String,Plant>();

     await plantsCollection.where("groupId",isEqualTo: plantGroup.uid).get().then((snapshot) => snapshot.docs.forEach((element) {plants[element.get("uid")]=Plant.fromJson(element.data());}));
    return plants;
  }
  ///this method will fetch all the [project] related data including photos
  ///it will create structured directories for each plant-group-[project] triples
  Future getProjectAssets(Project project)async{
    //get groups
    final Map<String,PlantGroup> groups=new Map<String,PlantGroup>();
    await plantGroupsCollection.where("projectId",isEqualTo: project.uid).get().then((snapshot) => snapshot.docs.forEach((element) {groups[element.get("uid")]=PlantGroup.fromJson(element.data());}));

    final Map<String,Plant> plants=new Map<String,Plant>();

    /*groups.forEach((key, value) {
      plantsCollection.where("groupId",isEqualTo: key).get().then((snapshot) => snapshot.docs.forEach((element) {plants[element.get("uid")]=Plant.fromJson(element.data());})).then((value) {
        plants.forEach((key, value) {QuickCalcOffline(value).getSummary().then((value) => print(value));});
      });
    });*/
    await Future.forEach(groups.keys, (key) => plantsCollection.where("groupId",isEqualTo: key).get().then((snapshot) => snapshot.docs.forEach((element) {plants[element.get("uid")]=Plant.fromJson(element.data());})));
    print("finished fetching plants");
    print(groups);
    print(plants);
    final Map<String,Map> results=new Map<String,Map>();

    await Future.forEach(plants.values, (plant) => QuickCalcOffline(plant).getSummary().then((value) => results[plant.uid]=value));
    return await ProjectExporter(project,groups,plants).exportAsPDF();


    print("fineshed fetching result");
    print(results);








  }

  Future downloadPlantSummary(Plant plant){


  }



}