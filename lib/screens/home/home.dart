import 'package:flutter/material.dart';
import 'package:predixinote/pages/account_page_view.dart';
import 'package:predixinote/pages/new_project_view.dart';
import 'package:predixinote/pages/project_list_view.dart';
import 'package:predixinote/services/auth.dart';
import 'package:predixinote/types/aquanote.dart';
import 'package:predixinote/types/user.dart';
import 'package:predixinote/widgets/user_card.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  final PUser user;
  HomePage({Key key, this.user}) : super(key: key);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final AuthService authService = AuthService();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool initialized = false;
  Widget content;
  String title;

  Future<PUser> fetchLastUser() async {
    final SharedPreferences prefs = await _prefs;
    try {
      PUser lastUser = PUser(
          uid: prefs.get("uid"),
          username: prefs.get("username"),
          name: prefs.get("name"),
          surname: prefs.get("surname"),
          email: prefs.get("email"));
      if (!lastUser.isValid()) {
        AuthService().signOut();
      }
      print(lastUser.toJson());

      return lastUser;
    } catch (e) {
      await prefs.clear();
      await AuthService().signOut();
      return null;
    }
  }

  Stream<Widget> get contentWidget {
    return widgetStreamController.stream;
  }

  Stream<Widget> get bottomNavWidget {
    return bottomNavBarStreamController.stream;
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    navigator.add(ProjectListView());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    navigator.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (activeUser == null) {
      fetchLastUser().then((value) {
        if (value != null) {
          activeUser = value;
        } else {
          AuthService().signOut();
        }
      }).whenComplete(() => setState(() {}));
    }

    return WillPopScope(
        child: new Scaffold(
          key: homeState,
          body: StreamBuilder<Widget>(
            initialData: navigator.first,
            stream: contentWidget,
            builder: (BuildContext context, AsyncSnapshot<Widget> snapshot) {
              if (snapshot.hasData) {
                content = snapshot.data;
              }
              return content;
            },
          ),
          drawer: Drawer(
              child: SingleChildScrollView(

            child: Column(

              children: <Widget>[
                Container(
                  child: Image.asset(
                    'assets/caption.png',
                  ),
                  margin: EdgeInsets.only(left: 47, right: 47, top: 31),
                ),
                UserCardAdvanced(
                  user: activeUser,
                ),
                ListTile(
                  title: Text("Yeni proje"),
                  onTap: () {
                    Navigator.of(context).pop();
                    goto(NewProjectView());
                  },
                ),
                ListTile(
                  title: Text("Projeler"),
                  onTap: () {
                    Navigator.of(context).pop();
                    goto(ProjectListView());
                  },
                ),
                ListTile(
                  title: Text("Hesap bilgileri"),
                  onTap: () {
                    Navigator.of(context).pop();
                    goto(AccountPageView());
                  },
                ),
                ListTile(
                  title: Text("Çıkış yap"),
                  onTap: () async {
                    await AuthService().signOut();
                  },
                )
              ],
            ),
          ) // Populate the Drawer in the next step.
              ),
          bottomNavigationBar: StreamBuilder<Widget>(
            initialData: SizedBox(
              height: 0,
            ),
            stream: bottomNavWidget,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                content = snapshot.data;
              } else {
                content = SizedBox(
                  height: 0,
                );
              }
              return content;
            },
          ),
        ),
        onWillPop: () => goback());
  }

  String generatePUID() {
    return 'PP${Uuid().v1()}';
  }
}
