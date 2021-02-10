import 'package:flutter/material.dart';
import 'package:predixinote/services/database.dart';
import 'package:predixinote/types/project.dart';

import '../widgets/member_view.dart';

class ProjectInfo extends StatefulWidget{
  final Project project;

  const ProjectInfo({Key key,@required this.project}) : super(key: key);

  @override
  _ProjectInfoState createState() => _ProjectInfoState();
}

class _ProjectInfoState extends State<ProjectInfo> {
  String newName;
  FocusNode focusName=FocusNode();
  String error;
  bool busy=false    ;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return SingleChildScrollView(
      child: Column(
        children: <Widget>[
          Container(
            child: TextFormField(
              enableInteractiveSelection: true,
              focusNode: focusName,
              initialValue: widget.project.name,
              keyboardType: TextInputType.text,
              style: TextStyle(fontSize: 20),
              onChanged: (value){
                widget.project.name=value;
              },
              onEditingComplete: ()=> DatabaseService().updateProject(widget.project),
              decoration: InputDecoration(
                errorText: error,

                labelText: "Proje adı"

                ,
                border: OutlineInputBorder(borderSide: BorderSide())
                ,
                hintStyle: TextStyle(fontSize: 20,fontStyle: FontStyle.italic),

              ),
            ),

            padding: EdgeInsets.all(10),
          ),
          MemberView(project: widget.project,),

          Container(
            child: TextFormField(
              initialValue: widget.project.info,
              textInputAction: TextInputAction.done,
              keyboardType: TextInputType.multiline,
              style: TextStyle(fontSize: 20),
              onChanged: (value){
                widget.project.info=value;
              },
              onEditingComplete: (){DatabaseService().updateProject(widget.project);
              FocusScope.of(context).requestFocus(new FocusNode());
              },
              decoration: InputDecoration(

                labelText: "Açıklama",
                alignLabelWithHint: true,
                border: OutlineInputBorder(borderSide: BorderSide())
                ,
                hintStyle: TextStyle(fontSize: 20,fontStyle: FontStyle.italic),
              ),

              maxLines: null,
            ),
            padding: EdgeInsets.all(10),
          ),
          Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(horizontal: 45,vertical: 12),
            child: ListTile(
              leading: SizedBox(
                height: 24,

                width: 24,
                child:busy?CircularProgressIndicator():Icon(Icons.picture_as_pdf_rounded,color: Colors.red,),
              ),
              title: Text(busy?"Dışa aktarılıyor...":"Dışa aktar (PDF)"),

              onTap: ()async{
                if (busy )return;
                setState((){busy=true;});
                DatabaseService().getProjectAssets(widget.project).then((value) => setState((){
                  busy=false;
                }));
              },
            ),
          )






        ],
      ),
    );

  }


}