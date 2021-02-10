import 'package:flutter/material.dart';
import 'package:predixinote/services/database.dart';
import 'package:predixinote/types/exporter.dart';
import 'package:predixinote/types/plant.dart';
import 'package:predixinote/types/project.dart';
import 'package:predixinote/widgets/gps_info.dart';
import 'package:predixinote/widgets/user_card.dart';
import 'package:uuid/uuid.dart';

class PlantInfo extends StatefulWidget {

  final Project project;
  final Plant plant;



  const PlantInfo({Key key, this.project, this.plant}) : super(key: key);

  @override
  _PlantInfoState createState() => _PlantInfoState();
}

class _PlantInfoState extends State<PlantInfo> {

  bool isExportTriggered=false;
  @override
  void initState() {
    super.initState();
    isExportTriggered=false;
  }
  @override
  void dispose() {
    // TODO: implement dispose
    DatabaseService().updatePlant(widget.plant);
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 25,),
            Container(
              child: TextFormField(
                initialValue: widget.plant.name,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
                style: TextStyle(fontSize: 20),
                onChanged: (value) {
                  widget.plant.name = value;
                },
                onEditingComplete: ()=>DatabaseService().updatePlant(widget.plant),
                decoration: InputDecoration(
                  labelText: "Nokta adı",
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          color: Colors.black54,
                          width: 2.0,
                          style: BorderStyle.solid)),
                  hintStyle: TextStyle(fontSize: 20, fontStyle: FontStyle.italic,),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10),
            ),
            Container(

              child: TextFormField(
                readOnly: true,
                initialValue: widget.plant.type,
                style: TextStyle(fontSize: 20),
                decoration: InputDecoration(
                  labelText: "Nokta tipi",
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                          width: 2.0,
                          style: BorderStyle.solid)),
                  hintStyle: TextStyle(fontSize: 20, fontStyle: FontStyle.italic,),
                ),
              ),
              padding: EdgeInsets.symmetric(horizontal: 10,vertical: 23),
            ),

            GpsInfo(plant: widget.plant,readonly:true),



            Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Flex(
                direction: Axis.horizontal,
                children:
                <Widget>[
                  Text(
                    "YETKİLİ:",
                    style: TextStyle(fontSize: 18),
                    textAlign: TextAlign.start,
                  ),
                  Expanded(child:
                  UserCardAsync(userId: widget.plant.userId,))
                ],
              ),
            ),

            Container(
              child: TextFormField(
                initialValue: widget.plant.additionalInfo,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.done,
                style: TextStyle(fontSize: 20),
                onChanged: (value){
                  widget.plant.additionalInfo=value;
                },
                onEditingComplete: (){

                  FocusScope.of(context).requestFocus(new FocusNode());
                  DatabaseService().updatePlant(widget.plant);
                },
                decoration: InputDecoration(
                  labelText: "Açıklama",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder()
                  ,
                  hintStyle: TextStyle(fontSize: 20,fontStyle: FontStyle.italic),
                ),
                maxLines: null,
              ),
              padding: EdgeInsets.all(10),
            ),
                /**/
            Card(
              margin: EdgeInsets.symmetric(horizontal: 45,vertical: 12),
              child: ListTile(
                leading: SizedBox(
                  height: 24,

                  width: 24,
                  child: (isExportTriggered)?CircularProgressIndicator():Icon(Icons.picture_as_pdf,color: Colors.red,),
                ),
                title: Text("Rapor oluştur"),

                onTap: ()async{setState(() {
                  isExportTriggered=true;
                });
                  await PlantExporter(widget.plant).exportPlantReportAsPDF().then((value) {
                    if(mounted){
                      setState(() {
                        isExportTriggered=false;
                      });
                    }
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String generatePUID() {
    return '${Uuid().v1()}';
  }
}
