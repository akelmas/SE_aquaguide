import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:predixinote/services/auth.dart';
import 'package:predixinote/services/database.dart';
import 'package:predixinote/services/predixi_auth.dart';
import 'package:predixinote/types/aquanote.dart';
import 'package:predixinote/types/user.dart';

class SignIn extends StatefulWidget {

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  static const int PROGRESS=123234;
  static const int MAIN=23535;
  int state=MAIN;

  String username;
  String password;

  String uError;
  String pError;

  PUser user;
  FocusNode usernamefocus = FocusNode();
  FocusNode passwordfocus = FocusNode();
  FocusNode buttonfocus = FocusNode();
  final AuthService authService = AuthService();
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {

    super.initState();
  }

  Future<bool> setLastUser(PUser user)async{
    try{
      final SharedPreferences prefs = await _prefs;
      await prefs.setString("uid", user.uid);
      await prefs.setString("username", user.username);
      await prefs.setString("name", user.name);
      await prefs.setString("surname", user.surname);
      await prefs.setString("email", user.email);
      return true;
    }catch(e){
      return false;
    }




  }

  Future<void> addIfNonExisting(PUser user)async{

    if(!(await DatabaseService().isExistingUser(user.uid))){
      print("non existin user");
      await DatabaseService().addUser(user);
    }

  }





  @override
  Widget build(BuildContext context) {


        return new Scaffold(
          body: Center(
            child: Container(
              width: 300,
              padding: EdgeInsets.symmetric(horizontal: 25.0),
              child: (state==MAIN)?SingleChildScrollView(
                  child: Form(
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[

                        Container(
                          child: Image.asset('assets/caption.png',height: 192,width: 192,),
                        ),


                        SizedBox(
                          height: 25.0,
                        ),
                        TextFormField(
                          initialValue: username,
                          onChanged: (term) {
                            username = term;
                          },
                          focusNode: usernamefocus,
                          textInputAction: TextInputAction.next,
                          onFieldSubmitted: (term) {
                            FocusScope.of(context).requestFocus(passwordfocus);
                          },
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Predixi ID',
                              prefixIcon: Icon(Icons.person),
                              errorText: uError
                          ),

                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                        TextFormField(
                          initialValue: password,
                          obscureText: true,
                          onChanged: (term) {
                            password = term;
                          },
                          focusNode: passwordfocus,
                          onFieldSubmitted: (term) {
                            FocusScope.of(context).requestFocus(buttonfocus);
                          },
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: 'Şifre',
                              prefixIcon: Icon(Icons.vpn_key),
                              errorText: pError
                          ),
                        ),
                        SizedBox(
                          height: 25.0,
                        ),
                        ButtonTheme(
                          child: RaisedButton(
                            elevation: 2.0,
                            child: Text(
                              'Giriş yap',
                              style: TextStyle(fontSize: 18),
                            ),
                            onPressed: () async {
                              if(!isValidData()){
                                setState(() {

                                });
                              }

                              setState(() {
                                state=PROGRESS;
                              });
                              print('success!');

                              final PUser user = await PredixiAuth()
                                  .authenticate(username, password).timeout(Duration(seconds: 10),onTimeout: (){
                                if(mounted){
                                  setState(() {
                                    state=MAIN;
                                  });
                                }
                                return null;
                              });
                              if (user == null) {
                                uError=pError="Kullanıcı adı/şifre hatalı";
                                setState(() {
                                  state=MAIN;
                                });
                              } else {
                                pError=uError=null;
                                if(user.isValid()){

                                  AuthService().signInAnon().then((value) async {
                                    activeUser=user;
                                    state=MAIN;
                                    await  addIfNonExisting(user);


                                    await setLastUser(user);

                                  }).catchError((e){
                                    uError="Hata oluştu";
                                    state=MAIN;
                                    print(e.toString());
                                  });
                                }else{
                                  setState(() {
                                    uError="Predixi hesabınızı gözden geçirin. Adınız, soyadınız ve e-posta bilgilerinizin doğruluğundan emin olun.";
                                    state=MAIN;
                                  });
                                }


                              }
                              setState(() {});

                            },
                            focusNode: buttonfocus,
                            focusElevation: 1.0,
                            textColor: Colors.black54,
                            color: Colors.white,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20.0)),
                          ),
                          minWidth: 148,
                          height: 50,
                        ),




                        SizedBox(
                          height: 25.0,
                        ),




                      ],
                    ),
                  )):Align(alignment: Alignment.center,child: CircularProgressIndicator(),),
            ),
          ),
        );
  }
  bool isValidData(){
    bool isValid=true;
    if(["",null].contains(username)){
      isValid=false;
      uError="Kullanıcı adı  alanı boş bırakılamaz";
    }else{
      uError=null;
    }

    if(["",null].contains(password)){
      isValid=false;
      pError="Şifre alanı boş bırakılamaz";
    }else{
      pError=null;
    }
    return isValid;

  }
}


