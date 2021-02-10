import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:predixinote/pages/group_view.dart';
import 'package:predixinote/services/database.dart';
import 'package:predixinote/types/aquanote.dart';
import 'package:predixinote/types/plant.dart';
import 'package:predixinote/types/plant_group.dart';
import 'package:predixinote/types/project.dart';
import 'package:uuid/uuid.dart';

class GroupListView extends StatefulWidget{
  final Project project;

  const GroupListView({Key key,this.project}) : super(key: key);

  @override
  _GroupListViewState createState() => _GroupListViewState();
}

class _GroupListViewState extends State<GroupListView> {


  String searchPhrase;
  TextEditingController searchController=new TextEditingController();
  String newGroupName;
  String error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Flex(
        mainAxisSize: MainAxisSize.max,
        direction: Axis.vertical,
        children: <Widget>[
          Card(
            child: TextFormField(
              controller: searchController,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.done,
              style: TextStyle(fontSize: 20),
              onChanged: (value){
                setState(() {
                  searchPhrase=value;
                });
              },
              decoration: InputDecoration(
                  hintText: "Ara",
                  border: OutlineInputBorder(),
                  hintStyle: TextStyle(fontSize: 20,fontStyle: FontStyle.italic),
                  suffixIcon: ["",null].contains(searchPhrase)?Icon(Icons.search):IconButton(icon: Icon(Icons.clear), onPressed: ()=>setState((){searchPhrase="";searchController.clear();}))

              ),

              onEditingComplete: (){
                searchController.clear();
                FocusScope.of(context).requestFocus(FocusNode());
              },),

            margin: EdgeInsets.all(10),
            elevation: 0,
          ),

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: DatabaseService().plantGroupsCollection.where('projectId',isEqualTo: widget.project.uid).orderBy("lastChange",descending: true).snapshots(),
              builder:
                  (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return const Text('Yükleniyor...');
                final int plantGroupCount = snapshot.data.docs.length;
                if(plantGroupCount==0){
                  return Text("Henüz nokta eklenmedi.");
                }

                return Scrollbar(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: plantGroupCount,

                    itemBuilder: (_, int index) {
                      final DocumentSnapshot document =
                      snapshot.data.docs[index];
                      try{
                        final _plantGroup=PlantGroup.fromJson(document.data());


                        if(searchPhrase!=null)
                          if(searchPhrase.isNotEmpty)
                            if(!(_plantGroup.name).toUpperCase().contains(searchPhrase.toUpperCase())) return SizedBox(height: 0);

                        return ListTile(
                          onLongPress: ()async{
                            await displayPlantGroupSettings(_plantGroup);
                          },
                          onTap: () {
                            goto(GroupView(plantGroup: _plantGroup,));
                          },
                          title: Text("${index+1}. ${_plantGroup.name}"),
                          subtitle: Text( "Son değişiklik: ${_plantGroup.lastChange.toString().substring(0,_plantGroup.lastChange.toString().indexOf("."))}" )
                        ,
                        );
                      }catch(e){
                        //print(e);
                        return SizedBox(height: 0,);
                      }


                    },
                  ),
                );
              },

            ),
          ),


        ],
      ),
      floatingActionButton:
      Card(
        elevation: 1,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        borderOnForeground: false,
        margin: EdgeInsets.all(1),
        child: RawMaterialButton(
          padding: EdgeInsets.all(0),
          child: Icon(Icons.add,size: 48),
          onPressed: (){
            displayAddGroupDialog();




            /*FirebaseFirestore.instance.collection('projects').get().then((query) =>query.docs.map(


                    (doc)
                {
                  DatabaseService().plantGroupsCollection.doc(doc.data()["uid"]).get().then((value) {
                    if(!value.exists){
                      String gid=Uuid().v1();
                        DatabaseService().addPlantGroup(PlantGroup(gid, doc.data()["uid"], "grup 1")).whenComplete(() {
                          FirebaseFirestore.instance.collection('plants').where("projectId",isEqualTo: doc.data()["uid"]).get().then((plantquery) {
                            plantquery.docs.forEach((plantdoc) {
                              final Plant _plant= Plant.fromJson(plantdoc.data());
                              _plant.groupId=gid;
                              DatabaseService().addPlant(_plant).whenComplete(() => print(_plant.name));
                            });
                          });
                        });
                      print(doc.data());
                    }
                  });
                  //DatabaseService().addPlantGroup(PlantGroup.fromProject(Project.fromJson(doc.data()),"a89d3a40-f742-11ea-9b7d-abdf48daf7bb"));
                }



            ).toList());*/
            //FirebaseFirestore.instance.collection('plants').get().then((resp) => resp.docs.map((doc) => DatabaseService().addPlant(Plant.fromJson(doc.data()))).toList());
            //FirebaseFirestore.instance.collection('parameters').get().then((resp) => resp.docs.map((doc) => DatabaseService().setParameter(Parameter.fromJson(doc.data()))).toList());
          },
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
  Future showDeleteConfirmationDialog(PlantGroup plantGroup) async{

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
                            children: <TextSpan>[
                              TextSpan(
                                  text:
                                  "Bu işlem geri alınamaz. "
                              ),
                              TextSpan(
                                  text:
                                  "${plantGroup.name} ",
                                  style: TextStyle(fontWeight: FontWeight.bold)
                              ),
                              TextSpan(
                                  text: " adlı nokta kalıcı olarak silinecektir."
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
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                              errorText: error,

                              hintText: plantGroup.name
                          ),
                        ),

                        ButtonBar(
                          children: <Widget>[
                            FlatButton(
                              child: Text('SİL'),
                              onPressed: ()  {
                                if(confirmationText==plantGroup.name){
                                  setDialogState(() {
                                    print("delete");
                                    isDeletionConfirmed=true;
                                    DatabaseService().deletePlantGroup(plantGroup);
                                  });

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

  Future<void> displayPlantGroupSettings(PlantGroup plantGroup){
    return  showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          contentPadding: EdgeInsets.all(10),
          title: Text("${plantGroup.name} ayarları",),
          content: ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[

              FlatButton(

                  child: Text('Sil'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await showDeleteConfirmationDialog(plantGroup);
                  }
              ),
              FlatButton(
                child: Text('İptal'),
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
  Future<void> displayAddGroupDialog(){
    newGroupName=null;
    error=null;
    var progress=false;
    return  showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          contentPadding: EdgeInsets.all(10),
          title: Text("Ölçüm noktası ekle", ),
          content: StatefulBuilder(builder: (context, setDialogState) =>
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child:progress?Container(
                  child: CircularProgressIndicator(),
                ):Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[

                    TextField(
                      onChanged: (val){
                        newGroupName=val;

                      },
                      decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          labelText: "Ölçüm noktası adı",
                          errorText: error
                      ),
                    ),

                    ButtonBar(
                      children: <Widget>[
                        FlatButton(
                          child: Text('EKLE'),
                          onPressed: () async {


                            if([null,"",false].contains(newGroupName)){
                              error="Ölçüm adı boş bırakılamaz";

                            }
                            else{
                              progress=true;
                              setDialogState((){});
                              error=null;
                              DatabaseService().addPlantGroup(new PlantGroup(Uuid().v1(),widget.project.uid,newGroupName)).then((value) => Navigator.of(context).pop(),onError: (err){
                                print(err);
                                progress=false;

                                setDialogState((){});
                                if(err is PlatformException){
                                  error=err.message;
                                }else{
                                  error="Hata oluştu. Tekrar deneyin";
                                }
                                if(mounted){
                                  setDialogState(() { });
                                }

                              });
                            }
                            setDialogState(() {
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
              ))

        );
      },
    );


  }


}