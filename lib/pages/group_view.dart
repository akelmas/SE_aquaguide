
import 'package:flutter/material.dart';
import 'package:predixinote/pages/group_dashboard.dart';
import 'package:predixinote/pages/map_view.dart';
import 'package:predixinote/pages/plant_list_view.dart';
import 'package:predixinote/types/aquanote.dart';
import 'package:predixinote/types/constants.dart';
import 'package:predixinote/types/plant_group.dart';

class GroupView extends StatefulWidget {
  final PlantGroup plantGroup;

  const GroupView({Key key, this.plantGroup}) : super(key: key);

  @override
  _GroupViewState createState() => _GroupViewState();
}

class _GroupViewState extends State<GroupView> {
  GlobalKey<ScaffoldState> groupViewState=new GlobalKey();
  static const LIST_VIEW=0;
  static const MAP_VIEW=1;
  int viewMode=LIST_VIEW;

  @override
  void initState() {
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return DefaultTabController(
      initialIndex: 1,
      length: 2,
      child: Scaffold(

        appBar: AppBar(
          centerTitle: true,
          title: Text(
            "${widget.plantGroup.name}"
            ,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),textAlign: TextAlign.center,


          ),
          leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: ()=>goback()),

          elevation: 2,
          backgroundColor: appBarBackgroundColor,
          actions: [
            IconButton(
              icon: viewMode==LIST_VIEW?Icon(Icons.map):Icon(Icons.list),
              onPressed: (){
                viewMode=(viewMode==LIST_VIEW)?MAP_VIEW:LIST_VIEW;
                setState(() {

                });
              },
            )
          ],

          bottom:viewMode==LIST_VIEW? TabBar(
            indicatorColor: Colors.white,
            isScrollable: false,
            tabs: [
              Tab(
                text: "GENEL BAKIŞ",
              ),
              Tab(
                text: "ÖLÇÜMLER",
              ),
            ],
          ):null,
        ),
        backgroundColor: Colors.white,
        body:  viewMode==MAP_VIEW?
        GroupMapView(plantGroup: widget.plantGroup,):
        TabBarView(
          children: <Widget>[
            GroupDashboard(plantGroup: widget.plantGroup,),
            PlantListView(plantGroup: widget.plantGroup,)
          ],
        ),
      ),
    );
  }
}
