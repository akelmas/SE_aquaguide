import 'package:flutter/material.dart';
import 'package:predixinote/services/database.dart';
import 'package:predixinote/types/user.dart';

class UserCardBasic extends StatelessWidget{
  final PUser user;
  final bool isSelected;

  const UserCardBasic({Key key, this.user, this.isSelected}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      alignment: Alignment(-0.9,0) ,
      height: 60,

      decoration: BoxDecoration(
          color: (isSelected?Theme.of(context).accentColor:Colors.transparent)
      ),
      width: double.maxFinite,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text("${user.name} ${user.surname}".toUpperCase(),style: TextStyle(fontSize: 16,),),
          Container(
            height: 48,
            width: 48,
            alignment: Alignment.center,
            child: Text(
                "${user.name[0]}${user.surname[0]}".toUpperCase()),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(24)),
              border: Border.all()
            ),
          )

        ],
      ),
    );
  }

}
class UserCardAdvanced extends StatelessWidget{
  final PUser user;

  const UserCardAdvanced({Key key, this.user}) : super(key: key);
  @override
  Widget build(BuildContext context) {

    return ListTile(
      leading: Container(
        height: 48,
        width: 48,
        alignment: Alignment.center,
        margin: EdgeInsets.only(right: 10),
        child: Text(
            "${user.name[0]}${user.surname[0]}".toUpperCase()),
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(24)),
            border: Border.all()
        ),
      ),
      title: Text("${user.name} ${user.surname}".toUpperCase(),style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),),
      subtitle: Text("${user.username}",overflow: TextOverflow.ellipsis,),
    );
  }

}
class UserCardAsync extends StatefulWidget{
  final String userId;

  const UserCardAsync({Key key, this.userId}) : super(key: key);

  @override
  _UserCardAsyncState createState() => _UserCardAsyncState();
}

class _UserCardAsyncState extends State<UserCardAsync> {


  PUser user;
  @override
  void initState() {
    // TODO: implement initState
    DatabaseService().getUserInformation(widget.userId).then((value) {
      if(mounted){
        setState(() {
          user=value;
        });
      }
    });
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    if(user==null){
      return SizedBox(
        height: 48,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            SizedBox(width: 15,),
            Text("Kullanıcı bilgileri alınıyor"),
            SizedBox(width: 15,),
            CircularProgressIndicator()
          ],
        ),
      );
    }

    return ListTile(
      title: Text("${user.name} ${user.surname}".toUpperCase(),style: TextStyle(color:Colors.blue[200],fontSize: 18,fontWeight: FontWeight.bold,decoration: TextDecoration.underline),),
      onTap: (){
        displayUserInfo(user);
      },
    );
  }
  Future<void> displayUserInfo(PUser user)  {
    return  showDialog<void>(
      context: context,
      barrierDismissible: true, // user must tap button!

      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
          contentPadding: EdgeInsets.all(10),
          content:  UserCardAdvanced(user: user,),
        );
      },
    );
  }
}