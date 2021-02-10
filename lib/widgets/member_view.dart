import 'package:flutter/material.dart';
import 'package:predixinote/services/database.dart';
import 'package:predixinote/types/project.dart';
import 'package:predixinote/widgets/add_member_view.dart';
import 'package:predixinote/widgets/user_card.dart';
import 'package:toast/toast.dart';

class MemberView extends StatefulWidget {
  final Project project;

  const MemberView({Key key, @required this.project}) : super(key: key);

  @override
  _MemberViewState createState() => _MemberViewState();
}

class _MemberViewState extends State<MemberView> {
  GlobalKey<AddMemberViewState> _key=GlobalKey<AddMemberViewState>();

  Future<void> displayAddMenu()  {
    return  showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          title: Text('Üye ekle'),
          contentPadding: EdgeInsets.all(10),
          content:  AddMemberView(key:_key,memberList:widget.project.members,),

          actions: <Widget>[
            FlatButton(
              child: Text('TAMAM'),
              onPressed: () async {
                //widget.notifyParent();
                _key.currentState.update();
                setState(() {
                    //update state
                });
                //await DatabaseService().updateProject();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> displayUserMenu(int index)  {
    return  showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          contentPadding: EdgeInsets.all(10),
          content:  UserCardAdvanced(user: widget.project.members[index],),
          actions: <Widget>[
            FlatButton(
              child: Text('PROJEDEN SİL'),
              onPressed: () async {
                setState(() {
                  widget.project.members.removeAt(index);
                });

                await DatabaseService().updateProject(widget.project);
                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('KAPAT'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Container(
            alignment: Alignment.centerLeft,

            margin: EdgeInsets.only(left: 20,right: 10),
            constraints: BoxConstraints(minWidth: 48, minHeight: 48),

            child: Text(
              "ÜYELER",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.start,
            ),
          ),
          Container(
              margin: EdgeInsets.only(right: 10,top: 10,bottom: 10),
              width: 60,
              height: 60,
              child: FlatButton(
                child: Icon(Icons.add),
                onPressed: ()   {
                    displayAddMenu();
                },
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                    side: BorderSide()),
              )),
          Expanded(
            child: SingleChildScrollView(

              scrollDirection: Axis.horizontal,
              child: Row(
                  children: List.generate(widget.project.members.length, (index){
                    return Container(
                        margin:
                        EdgeInsets.only(right: 10, top: 10, bottom: 10),
                        width: 60,
                        height: 60,
                        child: FlatButton(
                          child: Text(
                            "${widget.project.members[index].name[0].toUpperCase()}${widget.project.members[index].surname[0].toUpperCase()}",
                            style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                          onPressed: () {
                            displayUserMenu(index);
                          },
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                              side: BorderSide()),
                        )
                    );
                  }
                  )

              ),
            )
          ),
          SizedBox(
            width: 10,
          )
        ],


      ),
    );
  }
}
