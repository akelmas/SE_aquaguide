import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:predixinote/screens/wrapper.dart';
import 'package:predixinote/services/auth.dart';
import 'package:predixinote/types/user.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(new NoteApp());



}

class NoteApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return  StreamProvider<PUser>.value(
      value: AuthService().user,
      child: MaterialApp(
        title: 'Aquaguide',
        theme:ThemeData.dark(),
        home: Wrapper(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}


