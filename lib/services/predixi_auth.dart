import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:predixinote/services/auth.dart';
import 'package:predixinote/services/database.dart';
import 'package:predixinote/types/user.dart' ;
import 'package:http/http.dart' as http;


class PredixiAuth {
    Future<PUser> authenticate(String username,String password)async{
      try{
        final http.Response response = await http.get("https://predixi.com/svclogin/loginfrom?u=$username&p=$password&clientapp=aquanote",);

        var data=json.decode(response.body);
        print(data);
        PUser user=PUser.fromPredixiJson(data);
        if(!user.isValid())throw Exception("PAuthError");
        return  user;
      }catch(e){
        print(e);
        return null;
      }



    }

    Future signup(PUser user,String password )async{
      try{
        User _firebaseUser=await AuthService().createUser(user, password);
        _firebaseUser.sendEmailVerification();
        final PUser _user=AuthService().fromFirebaseUser(_firebaseUser);
        _user.name=user.name;
        _user.surname=user.surname;
        _user.email=user.email;
        _user.username=user.username;

        if(_user==null){
          return null;
        }else{
          print(_user.toJson());
          AuthService().signOut();
          return await DatabaseService().addUser(_user);
        }


      }catch(e){
        print(e);
        throw PlatformException(code:"ERROR",message:"Bu e-posta zaten kayıtlı",details:"Başka bir e-posta adresi ile kaydolmayı deneyin");
      }
    }
}