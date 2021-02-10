import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:predixinote/services/database.dart';
import 'package:predixinote/types/aquanote.dart';
import 'package:predixinote/types/constants.dart';
import 'package:predixinote/types/project.dart';
import 'package:predixinote/types/user.dart';
import 'package:predixinote/widgets/member_view.dart';
import 'package:toast/toast.dart';
import 'package:uuid/uuid.dart';

class NewProjectView extends StatefulWidget{

  final String projectId;
  final PUser user;

  NewProjectView({Key key, this.projectId, this.user}) : super(key: key);

  @override
  _NewProjectViewState createState() => _NewProjectViewState();
}

class _NewProjectViewState extends State<NewProjectView> {

  bool isWaiting=false;
  String nameError;
  @override
  Widget build(BuildContext context) {

    Project project;
    project=new Project.create(Uuid().v1());
    project.members.add(activeUser);
    String name;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Yeni proje"),
        backgroundColor: appBarBackgroundColor,
        leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: ()=>goback()),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              child: TextFormField(
                initialValue: name,

                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 20),
                onChanged: (value){
                  name=value;
                },
                decoration: InputDecoration(
                  errorText: nameError,

                  labelText: "Proje adı"

                  ,
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black54,width: 2.0,style: BorderStyle.solid))
                  ,
                  hintStyle: TextStyle(fontSize: 20,fontStyle: FontStyle.italic),

                ),
              ),

              margin: EdgeInsets.all(10),
            ),
            MemberView(project: project,),

            Container(
              child: TextFormField(
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 20),
                onChanged: (value){
                  project.info=value;
                },
                decoration: InputDecoration(
                  labelText: "Açıklama"
                  ,
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black54,width: 2.0,style: BorderStyle.solid))
                  ,
                  hintStyle: TextStyle(fontSize: 20,fontStyle: FontStyle.italic),
                ),
                maxLines: 5,
              ),
              margin: EdgeInsets.all(10),
            ),
            RaisedButton(
              child: Text("Oluştur"),
              onPressed: () async {
                setState(() {
                  isWaiting=true;
                });

                if(["",null].contains(name)){
                  Toast.show("Proje adı boş bırakılamaz", context);
                }else {
                  project.name=name;
                  if(!(await DatabaseService().isExistingProject(project))){
                    isWaiting=false;
                    nameError=null;
                    await DatabaseService().addProject(project);
                    goback();
                  }else{
                    if(mounted){
                      setState(() {
                        nameError="Bu proje adı kayıtlı";
                      });
                    }
                  }

                }
              },
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),)
            )

          ],
        ),
      ),
    );
  }
}