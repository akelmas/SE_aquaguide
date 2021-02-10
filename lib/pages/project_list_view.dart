import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:predixinote/pages/project_view.dart';
import 'package:predixinote/services/database.dart';
import 'package:predixinote/types/aquanote.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:predixinote/types/constants.dart';
import 'package:predixinote/types/project.dart';


class ProjectListView extends StatefulWidget {
  final String uid;

  const ProjectListView({Key key, this.uid,}) : super(key: key);

  @override
  _ProjectListViewState createState() => _ProjectListViewState();
}

class _ProjectListViewState extends State<ProjectListView> {
  String searchPhrase;
  TextEditingController searchController=new TextEditingController();

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Projeler",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),textAlign: TextAlign.center
            ,),
        leading: IconButton(icon: Icon(Icons.menu),onPressed: ()=>homeState.currentState.openDrawer(),),
      ),
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
                  hintText: "Ara"

                  ,
                  border: OutlineInputBorder()
                  ,
                  hintStyle: TextStyle(fontSize: 20,fontStyle: FontStyle.italic),
                  suffixIcon: ["",null].contains(searchPhrase)?Icon(Icons.search,):IconButton(icon: Icon(Icons.clear), onPressed: ()=>setState((){searchPhrase="";searchController.clear();}))

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
              stream: DatabaseService().projectsCollection.orderBy('lastUpdate',descending: true).snapshots(),
              builder:
                  (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) return const Text('Yükleniyor...');
                final int projectCount = snapshot.data.docs.length;
                if(projectCount==0){
                  return Text("Henüz proje oluşturulmadı.");
                }

                return Scrollbar(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: projectCount,

                    itemBuilder: (_, int index) {
                      final DocumentSnapshot document =
                      snapshot.data.docs[index];

                      try{
                        final _project=Project.fromJson(document.data());
                        if(searchPhrase!=null)
                          if(searchPhrase.isNotEmpty)
                            if(!(_project.name).toUpperCase().contains(searchPhrase.toUpperCase())) return SizedBox(height: 0);

                        return ListTile(
                          onLongPress: ()async{
                            await displayProjectSettings(_project);
                          },
                          onTap: () {
                            goto(ProjectView(project: _project,));
                          },
                          title: Text("${index+1}. ${_project.name}"),
                          subtitle: Text("Son değişiklik: ${_project.lastUpdate.toString().substring(0,_project.lastUpdate.toString().indexOf("."))}",overflow: TextOverflow.ellipsis,maxLines: 1,),
                        );
                      }catch(e){
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
    );

  }

  Future<void> displayProjectSettings(Project project){
    return  showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          contentPadding: EdgeInsets.all(10),
          title: Text("${project.name} ayarları", ),
          content: ButtonBar(
            alignment: MainAxisAlignment.center,
            children: <Widget>[

              FlatButton(

                  child: Text('Sil'),
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await showDeleteConfirmationDialog(project);
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
  Future showDeleteConfirmationDialog(Project project) async{

    bool isDeletionConfirmed=false;
    String confirmationText;
    String error;
    return  showDialog<void>(
      barrierDismissible: true, // us
      context: context,// er must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
            title: Text('Projeyi sil'),
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
                                  "${project.name} ",
                                  style: TextStyle(fontWeight: FontWeight.bold)
                              ),
                              TextSpan(
                                  text: "projesi kalıcı olarak silinecektir."
                              ),
                              TextSpan(
                                  text: "\n\nİşlemi onaylamak için proje adını kutucuğa yazın.\n"
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
                              border: OutlineInputBorder(),
                              errorText: error,

                              hintText: project.name
                          ),
                        ),

                        ButtonBar(
                          children: <Widget>[
                            FlatButton(
                              child: Text('SİL'),
                              onPressed: () async {
                                if(confirmationText==project.name){
                                  setDialogState(() {
                                    isDeletionConfirmed=true;});
                                  await DatabaseService().deleteProject(project);
                                  Navigator.of(context).pop();
                                }else{
                                  setDialogState((){
                                    error="Proje adı eşleşmiyor.";
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

}
