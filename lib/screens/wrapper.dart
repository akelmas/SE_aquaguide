
import 'package:flutter/material.dart';
import 'package:predixinote/screens/authenticate/authenticate.dart';
import 'package:predixinote/screens/home/home.dart';
import 'package:predixinote/services/database.dart';
import 'package:predixinote/types/user.dart';
import 'package:provider/provider.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }






  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    final _user = Provider.of<PUser>(context);

    //return either login or home
    if (_user == null) {
      return Authenticate();
    } else {
      DatabaseService.uid=_user.uid;
    return HomePage(user: _user,);
    }

  }
  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
