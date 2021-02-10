import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:predixinote/pages/map_view.dart';
import 'package:predixinote/pages/plant_view.dart';
import 'package:predixinote/services/database.dart';
import 'package:predixinote/types/aquanote.dart';
import 'package:predixinote/types/plant.dart';
import 'package:predixinote/types/plant_group.dart';
import 'package:predixinote/widgets/assign_member_view.dart';
import 'package:uuid/uuid.dart';
class PlantListView extends StatefulWidget {
  final PlantGroup plantGroup;

  const PlantListView({Key key, this.plantGroup}) : super(key: key);

  @override
  _PlantListViewState createState() => _PlantListViewState();
}

class _PlantListViewState extends State<PlantListView> {

  String phrase;
  TextEditingController searchController = new TextEditingController();

  Future<void> displayAssignMenu(Plant plant){
    return  showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          contentPadding: EdgeInsets.all(10),
          title: Text("Üye seçin"),
          actions: <Widget>[
            FlatButton(
              child: Text('Tamam'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          content: AssignMemberView(plant:  plant,),

        );
      },
    );
  }
  Future<void> displayPointSettings(Plant plant){
    return  showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          contentPadding: EdgeInsets.all(10),
          title: Text("${plant.name} ayarları", ),
          content: ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[
              FlatButton(
                child: Text('Devret'),
                onPressed: () async {
                  print("neler oluyor");

                  Navigator.of(context).pop();
                  await displayAssignMenu(plant);
                  setState(() {
                    //update
                  });
                },
              ),
              FlatButton(

                  child: Text('Sil'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    showDeleteConfirmationDialog(plant);

                  }
              ),
              FlatButton(
                child: Text('Vazgeç'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),

        );
      },
    );
  }
  Future showDeleteConfirmationDialog(Plant plant) async{

    bool isDeletionConfirmed=false;
    String confirmationText;
    String error;
    return  showDialog<void>(
      barrierDismissible: true, // us
      context: context,// er must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
            title: Text('Noktayı sil'),
            contentPadding: EdgeInsets.all(10),
            content:StatefulBuilder(
                builder: (BuildContext context, StateSetter setDialogState){

                  return isDeletionConfirmed? Container(height: 232,alignment:Alignment.center,child: CircularProgressIndicator(),):Container(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child:Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        RichText(text: TextSpan(
                            style: TextStyle(color: Colors.black87),
                            children: <TextSpan>[
                              TextSpan(
                                  text:
                                  "Bu işlem geri alınamaz. "
                              ),
                              TextSpan(
                                  text:
                                  "${plant.name} ",
                                  style: TextStyle(fontWeight: FontWeight.bold)
                              ),
                              TextSpan(
                                  text: "noktası kalıcı olarak silinecektir."
                              ),
                              TextSpan(
                                  text: "\n\nİşlemi onaylamak için nokta adını kutucuğa yazın.\n"
                              ),



                            ]
                        )),
                        TextField(
                          enableInteractiveSelection: true,
                          onChanged: (val){
                            confirmationText=val;
                          },
                          decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 10),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10),borderSide: BorderSide(color: error==null?Colors.black:Colors.red)),
                              errorText: error,
                              hintText: plant.name
                          ),
                        ),

                        ButtonBar(
                          children: <Widget>[
                            FlatButton(
                              child: Text('SİL'),
                              onPressed: () async {
                                if(confirmationText==plant.name){
                                  setDialogState(() {
                                    isDeletionConfirmed=true;});
                                  DatabaseService().deletePlant(plant);

                                  Navigator.of(context).pop();
                                }else{
                                  setDialogState((){
                                    error="Nokta adı eşleşmiyor.";
                                  });
                                }

                                setState(() {
                                  //update state
                                });
                              },
                            ),
                            FlatButton(
                              child: Text('VAZGEÇ'),
                              onPressed: ()  {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        )
                      ],
                    ),
                  );


                })
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Flex(
          direction: Axis.vertical,
          children:
          <Widget>[
            Card(
              child: TextFormField(
                controller: searchController,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 20),
                onChanged: (value) {
                  setState(() {
                    phrase = value;
                  });
                },
                decoration: InputDecoration(
                    hintText: "Ara",
                    border: OutlineInputBorder(
                        borderSide: BorderSide(
                            width: 2.0,
                            style: BorderStyle.solid)
                    ),
                    hintStyle:
                    TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                    suffixIcon: Icon(
                      Icons.search,
                    )
                ),
                onEditingComplete: () {
                  searchController.clear();
                },
              ),
              margin: EdgeInsets.all(10),
              elevation: 0,
            ),
            Expanded(
              child:StreamBuilder(

                  stream:DatabaseService().plantsCollection.orderBy('lastChange',descending: true).where("groupId",isEqualTo: widget.plantGroup.uid).snapshots(),
                  builder:
                      (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {


                    if (!snapshot.hasData)return const Text('Kayıtlı nokta yok');
                    final int plantCount = snapshot.data.docs.length;
                    if(plantCount==0){
                      return Text("Henüz ölçüm noktası eklenmedi");
                    }
                    return Scrollbar(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount:plantCount,
                        itemBuilder: (_, int index) {
                          final document=snapshot.data.docs[index];
                          try{
                            final Plant plant=Plant.fromJson(document.data());
                            if (phrase != null) if (phrase.isNotEmpty) if (!(plant.name.toUpperCase())
                                .contains(phrase.toUpperCase())) return SizedBox(height: 0);
                            return ListTile(
                              onTap: () {
                                goto(PlantView(plant: plant));
                              },
                              onLongPress: () {
                                displayPointSettings(plant);
                              },
                              title: Text("${index+1}. ${plant.name} (${plant.type})"),
                              subtitle: Text("Son değişiklik: ${plant.lastChange.toString()}"),

                            );

                          }catch(e){
                            //there is a placeholder dummy document in database. it will throw an error each time, it is not an error :)
                            return SizedBox(height: 0,);

                          }
                        },
                      ),
                    );
                  }

              )

            ),
          ]
      ),floatingActionButton:
        Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          
          borderOnForeground: false,
          margin: EdgeInsets.all(1),
          child: RawMaterialButton(
            padding: EdgeInsets.all(0),
            child: Icon(Icons.add,size: 48),
            onPressed: (){
              addPlantDialog();
            },
          ),
        ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

    );

  }

  Future addPlantDialog() async{
    String name;

    String error;
    bool progress=false;
    return  showDialog<void>(
      barrierDismissible: true, // us
      context: context,// er must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
            title: Text('Yeni ölçüm'),

            contentPadding: EdgeInsets.all(10),
            content:StatefulBuilder(
                builder: (BuildContext context, StateSetter setDialogState){

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        Card(
                          child: TextFormField(
                            initialValue: name,

                            keyboardType: TextInputType.text,
                            style: TextStyle(fontSize: 20),
                            onChanged: (value) {
                              name = value;
                            },
                            decoration: InputDecoration(
                              errorText: error,

                              labelText: "Ölçüm adı",
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      width: 2.0,
                                      style: BorderStyle.solid)),
                              hintStyle: TextStyle(fontSize: 20, fontStyle: FontStyle.italic,),
                            ),
                          ),
                          margin: EdgeInsets.symmetric(horizontal: 10),
                          elevation: 0,
                        ),
                        progress?Padding(padding: EdgeInsets.all(10),child: CircularProgressIndicator(),):ButtonTheme(
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          child: ButtonBar(
                            alignment: MainAxisAlignment.center,
                            children: [
                              RaisedButton(
                                child: Text("Kuyu",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
                                onPressed:()async{
                                  if(["",null,false].contains(name)){
                                    error="Ölçüm adı boş bırakılamaz";
                                    setDialogState((){});
                                    return;
                                  }
                                  progress=true;
                                  setDialogState((){});

                                  final Plant plant=new Plant.kuyu(uid:Uuid().v1(),name: name,groupId: widget.plantGroup.uid);
                                  print(plant.toJson());
                                  await DatabaseService().addPlant(plant).then((value){
                                    Navigator.of(context).pop();
                                    goto(PlantView(plant: plant));
                                  }).catchError(( err){
                                    print(err);
                                    error=err.message;
                                    progress=false;
                                    setDialogState((){});
                                  }).whenComplete(() => print("completed"));
                                },
                              ),
                              RaisedButton(
                                child: Text("Terfi",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
                                onPressed:()async{
                                  if(["",null,false].contains(name)){
                                    error="Ölçüm adı boş bırakılamaz";
                                    setDialogState((){});
                                    return;
                                  }
                                  progress=true;
                                  setDialogState((){});

                                  final Plant plant=new Plant.terfi(uid:Uuid().v1(),name: name,groupId: widget.plantGroup.uid);
                                  print(plant.toJson());
                                  await DatabaseService().addPlant(plant).then((value){
                                    Navigator.of(context).pop();
                                    goto(PlantView(plant: plant));
                                  }).catchError(( err){
                                    print(err);
                                    error=err.message;
                                    progress=false;
                                    setDialogState((){});
                                  }).whenComplete(() => print("completed"));
                                },
                              ),
                              RaisedButton(
                                child: Text("Depo",style: TextStyle(fontSize: 16,fontWeight: FontWeight.w700),),
                                onPressed:()async{
                                  if(["",null,false].contains(name)){
                                    error="Ölçüm adı boş bırakılamaz";
                                    setDialogState((){});
                                    return;
                                  }
                                  progress=true;
                                  setDialogState((){});

                                  final Plant plant=new Plant.depo(uid:Uuid().v1(),name: name,groupId: widget.plantGroup.uid);
                                  print(plant.toJson());
                                  await DatabaseService().addPlant(plant).then((value){
                                    Navigator.of(context).pop();
                                    goto(PlantView(plant: plant));
                                  }).catchError(( err){
                                    print(err);
                                    error=err.message;
                                    progress=false;
                                    setDialogState((){});
                                  }).whenComplete(() => print("completed"));

                                },
                              )

                            ],
                          ),
                        )


                      ],
                    ),

                  );


                })
        );
      },
    );
  }




}

