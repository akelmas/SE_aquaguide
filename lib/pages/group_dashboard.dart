import 'package:flutter/material.dart';
import 'package:predixinote/services/database.dart';
import 'package:predixinote/types/plant.dart';
import 'package:predixinote/types/plant_group.dart';
import 'package:predixinote/widgets/quick_calc.dart';

class GroupDashboard extends StatefulWidget{
  final PlantGroup plantGroup;

  const GroupDashboard({Key key, this.plantGroup}) : super(key: key);

  @override
  _GroupDashboardState createState() => _GroupDashboardState();
}

class _GroupDashboardState extends State<GroupDashboard> {
  bool isExportTriggered=false;

  var dateController;
  @override
  void initState() {
    super.initState();
    isExportTriggered=false;
    dateController=new TextEditingController(text: "${widget.plantGroup.dateCreated.day}/${widget.plantGroup.dateCreated.month}/${widget.plantGroup.dateCreated.year}");
  }

  void updateState(){
    setState(() {

    });
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            SizedBox(height: 25,),
            Container(
              child: TextFormField(
                initialValue: widget.plantGroup.name,
                keyboardType: TextInputType.text,
                style: TextStyle(fontSize: 20),
                onChanged: (value) {
                  widget.plantGroup.name = value;
                },
                onEditingComplete: ()=>DatabaseService().updatePlantGroup(widget.plantGroup),
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
              margin: EdgeInsets.symmetric(horizontal: 10),
            ),

            SizedBox(height: 10,),
            Container(
              child: TextFormField(
                initialValue: widget.plantGroup.info,
                keyboardType: TextInputType.multiline,
                textInputAction: TextInputAction.done,
                style: TextStyle(fontSize: 20),
                onChanged: (value){
                  widget.plantGroup.info=value;
                },
                onEditingComplete: (){

                  FocusScope.of(context).requestFocus(new FocusNode());
                  DatabaseService().updatePlantGroup(widget.plantGroup);
                },
                decoration: InputDecoration(
                  labelText: "Açıklama",
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.black54,width: 2.0,style: BorderStyle.solid))
                  ,
                  hintStyle: TextStyle(fontSize: 20,fontStyle: FontStyle.italic),
                ),
                maxLines: null,
              ),
              margin: EdgeInsets.all(10),
            ),
            FutureBuilder(
              future: groupSummary(widget.plantGroup),
              initialData: Container(
                margin: EdgeInsets.all(10),
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 10,),
                    Text("Veriler yükleniyor...")
                  ],
                ),
              ),
              builder: (context, snapshot) {
                final table=snapshot.data;
                return table;
              },

            )


          ],
        ),
      ),
    );
  }


  Future <Widget> groupSummary(PlantGroup plantGroup)async{
    List<TableRow> rows=List<TableRow>();
    TableRow plantRow(Plant plant, Map<String, double> data) {
      return TableRow(
          children: [
            Container(
                padding: EdgeInsets.all(3),
                child: Text(plant.name,)),
            Container(padding: EdgeInsets.all(3),child: Text(plant.type)),
            Container(padding: EdgeInsets.all(3),child: Text("${(data["Debi"]??0).toStringAsFixed(3)}")),
            Container(padding: EdgeInsets.all(3),child: Text("${data["Toplam güç"].toStringAsFixed(3)}")),
            Container(padding: EdgeInsets.all(3),child: Text("${data["Basma yüksekliği"].toStringAsFixed(3)}")),
            Container(padding: EdgeInsets.all(3),child: Text("${data["Hidrolik verim"].toStringAsFixed(3)}")),
            Container(padding: EdgeInsets.all(3),child: Text("${data["Su hızı"].toStringAsFixed(3)}")),
          ]);
    }

    //rows.add(TableRow(children: [Text(plantGroup.name)]));
    rows.add(TableRow(


        children: [
          Padding(child:           Text("Ölçüm adı",style: TextStyle(fontWeight: FontWeight.bold,),), padding: EdgeInsets.all(3)),
          Padding(child:           Text("Tür",style: TextStyle(fontWeight: FontWeight.bold),), padding: EdgeInsets.all(3)),
          Padding(child:           Text("Debi (m\u00B3/h)",style: TextStyle(fontWeight: FontWeight.bold),), padding: EdgeInsets.all(3)),
          Padding(child:           Text("Toplam güç (kW)",style: TextStyle(fontWeight: FontWeight.bold),), padding: EdgeInsets.all(3)),
          Padding(child:           Text("Hm (mSS)",style: TextStyle(fontWeight: FontWeight.bold),), padding: EdgeInsets.all(3)),
          Padding(child:           Text("Hidrolik verim (%)",style: TextStyle(fontWeight: FontWeight.bold),),padding: EdgeInsets.all(3)),
          Padding(child:           Text("Su hızı (m/s)",style: TextStyle(fontWeight: FontWeight.bold),), padding: EdgeInsets.all(3)),
        ]
    ));
    final plantData=await DatabaseService().getPlantsByGroup(plantGroup);
    await Future.forEach(plantData.values.where((plant) => plant.groupId==plantGroup.uid), (element) => QuickCalcOffline(element).getSummary().then((value) => rows.add(plantRow(element,value))));

    return Scrollbar(

      child: SingleChildScrollView(

        scrollDirection: Axis.horizontal,
        child: Container(
          width: 1000,
          padding: EdgeInsets.all(10),
          child: Table(



              border: TableBorder.all(color: Theme.of(context).accentColor),
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,


              columnWidths: {
                0:FlexColumnWidth(4),//plant title
                1:FlexColumnWidth(2),//plant type
                2:FlexColumnWidth(3),//debi
                3:FlexColumnWidth(3),//total power
                4:FlexColumnWidth(3),//hm
                5:FlexColumnWidth(3),//nPump
                6:FlexColumnWidth(3),//water speed
              },
              children: rows
          ),
        ),
      ),
    );
  }


}
