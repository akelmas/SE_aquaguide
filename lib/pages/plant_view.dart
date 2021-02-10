
import 'package:flutter/material.dart';
import 'package:predixinote/pages/plant_info.dart';
import 'package:predixinote/pages/plant_parameters.dart';
import 'package:predixinote/types/aquanote.dart';
import 'package:predixinote/types/constants.dart';
import 'package:predixinote/types/plant.dart';
import 'package:predixinote/pages/plant_images.dart';

class PlantView extends StatelessWidget {
  final Plant plant;
  const PlantView({Key key,@required this.plant}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(


        appBar: AppBar(


          centerTitle: true,
          title: Text(
            "${plant.name}"
            ,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),textAlign: TextAlign.center,



          ),
          leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: ()=>goback()),

          elevation: 2,

          bottom: TabBar(
            indicatorColor: Colors.white,
            isScrollable: false,
            tabs: [
              Tab(
                text: "BİLGİLER",
              ),
              Tab(
                text: "VERİLER",
              ),
              Tab(
                text: "GALERİ",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            PlantInfo(plant: plant,),
            PlantParameters(plant:plant,),
            PlantImages(plant: plant,)
          ],
        ),
      ),
    );

  }
}
