import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:predixinote/pages/editor.dart';
import 'package:predixinote/services/database.dart';
import 'package:predixinote/types/aquanote.dart';
import 'package:predixinote/types/constants.dart';
import 'package:predixinote/types/parameter.dart';
import 'package:predixinote/types/plant.dart';
import 'package:predixinote/widgets/quick_calc.dart';
class PlantParameters extends StatefulWidget {
  final Plant plant;

  const PlantParameters({Key key,@required this.plant,}) : super(key: key);


  @override
  PlantParametersState createState() => PlantParametersState();
}

class PlantParametersState extends State<PlantParameters> {


  @override
  void initState() {

    //showInBottomNav(QuickCalc(plant: widget.plant,));
    super.initState();
  }



  Future<void> displayEditParameterDialog(Parameter parameter){
    return  showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
            contentPadding: EdgeInsets.all(10),
            content:Editor(parameter: parameter,onSubmit:(){
              updateCalcDB(parameter, widget.plant);
              setState(() {

              });
              Navigator.of(context).pop();
            }),


        );
      },
    );


  }
  @override
  Widget build(BuildContext context) {


    return SingleChildScrollView(


      physics: ClampingScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          QuickCalc(plant: widget.plant,),
          StreamBuilder<QuerySnapshot>(
            stream: DatabaseService().parametersCollection.where("plantId",isEqualTo: widget.plant.uid).orderBy('index').snapshots(),
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) return const Text('Yükleniyor...');
              final documents=snapshot.data.docs;
              final int parameterCount = documents.length;
              return Scrollbar(
                child: GridView.count(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  crossAxisCount: MediaQuery.of(context).orientation == Orientation.portrait ? 3 : 6,
                  children: List.generate(
                      parameterCount,
                          (index) {

                        final Parameter parameter=Parameter.fromJson(documents[index].data());
                        return Card(
                            child:InkWell(

                              onTap:()=>displayEditParameterDialog(parameter),
                              child: Container(
                                  padding: EdgeInsets.all(5),
                                  decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                            color:
                                            parameter.isEssential ? Colors.redAccent : Colors.amberAccent,
                                            width: 5),
                                        left: BorderSide(width: 0.2),
                                        right: BorderSide( width: 0.2),
                                        bottom: BorderSide( width: 0.2),
                                      )),
                                  child: GridTile(
                                    header:Container(
                                      alignment: Alignment(0, 0.5),
                                      height: 40,
                                      child:  Text("${parameter.name}"
                                        ,
                                        overflow: TextOverflow.clip,
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        style: TextStyle(
                                            fontSize: 15,fontWeight: FontWeight.w400
                                        ),
                                      ),
                                    ),
                                    child: Container(
                                      alignment: Alignment(0,0.3),
                                      child: (parameter.value==null)?Icon(Icons.check_circle):Text("${parameter.type=="diameter"?"DN${parameter.value.floor()}":parameter.value.toStringAsFixed(1)}",
                                        style: TextStyle(fontSize: 24),
                                        overflow: TextOverflow.ellipsis,),
                                    ),
                                    footer: parameter.type=="diameter"?null:Text(units[parameter.type],textAlign: TextAlign.center,),
                                  )
                              ),
                            )
                        );
                      }
                  )) ,
              );
            },
          ),

          //QuickCalc(plant: widget.plant,)
        ],
      ),
    );



      /*Flex(
      direction: Axis.vertical,
      children: <Widget>[
        Expanded(
          child: ,
        ),



      ],
    );*/

  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    //hideBottomNav();
  }


}

