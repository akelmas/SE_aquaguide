
import 'package:flutter/material.dart';
import 'package:predixinote/pages/group_list_view.dart';
import 'package:predixinote/types/aquanote.dart';
import 'package:predixinote/types/constants.dart';
import 'package:predixinote/types/project.dart';
import 'package:predixinote/pages/project_info.dart';

class ProjectView extends StatefulWidget {
  final Project project;

  const ProjectView({Key key, this.project}) : super(key: key);

  @override
  _ProjectViewState createState() => _ProjectViewState();
}

class _ProjectViewState extends State<ProjectView> {
  GlobalKey<ScaffoldState> projectViewState=new GlobalKey();
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    print(widget.project.uid);
    return DefaultTabController(
      initialIndex: 1,
      length: 2,
      child: Scaffold(

          appBar: AppBar(
            centerTitle: true,
            title: Text(
              "${widget.project.name}"
              ,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),textAlign: TextAlign.center,


            ),
            leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: (){goback();}),
            actions: [

            ],

            elevation: 2,

            bottom: TabBar(
              indicatorColor: Colors.white,
              isScrollable: false,
              tabs: [
                Tab(
                  text: "BİLGİLER",
                ),
                Tab(
                  text: "NOKTALAR",
                ),
              ],
            ),
          ),
          body: TabBarView(
            children: <Widget>[
              ProjectInfo(project: widget.project,),
              GroupListView(project: widget.project,),
            ],
          ),
      ),
    );
  }
}
