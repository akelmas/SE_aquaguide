import 'package:flutter/material.dart';
import 'package:predixinote/types/aquanote.dart';
import 'package:predixinote/types/constants.dart';

class AccountPageView extends StatelessWidget{

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:   AppBar(
        centerTitle: true,
        title: Text("Hesap Bilgileri",style: TextStyle(fontSize: 24, fontWeight: FontWeight.w400),textAlign: TextAlign.center),
    backgroundColor: appBarBackgroundColor,
    leading: IconButton(icon: Icon(Icons.arrow_back_ios), onPressed: ()=>goback()),
    ),
      body: Flex(
        mainAxisSize: MainAxisSize.max,
        direction: Axis.vertical,
        children: <Widget>[
          Expanded(
              child:SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    SizedBox(height: 15,),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextFormField(
                            readOnly: true,
                            initialValue: activeUser.username,

                            decoration: InputDecoration(
                                labelText: 'Predixi ID',
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color:
                                        appBarBackgroundColor))),
                          ),
                          SizedBox(
                            height: 25.0,
                          ),
                          Flex(
                            direction: Axis.horizontal,
                            children: <Widget>[

                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  readOnly: true,
                                  initialValue: activeUser.name,
                                  onChanged: (term) {
                                    activeUser.name = term;
                                  },
                                  textInputAction: TextInputAction.next,
                                  keyboardType: TextInputType.text,
                                  decoration: InputDecoration(
                                      labelText: 'Adınız',
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                              appBarBackgroundColor))),
                                ),
                              ),
                              SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                flex: 1,
                                child: TextFormField(
                                  readOnly: true,
                                  initialValue: activeUser.surname,
                                  onChanged: (term) {
                                    activeUser.surname = term;
                                  },
                                  textInputAction: TextInputAction.done,
                                  keyboardType: TextInputType.text,
                                  onEditingComplete: () =>
                                      FocusScope.of(context)
                                          .requestFocus(new FocusNode()),
                                  decoration: InputDecoration(
                                      labelText: 'Soyadınız',
                                      border: OutlineInputBorder(
                                          borderSide: BorderSide(
                                              color:
                                              appBarBackgroundColor))),
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 25.0,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          TextFormField(
                            readOnly: true,
                            initialValue: activeUser.email,
                            onChanged: (term) {
                              activeUser.email = term;
                            },
                            textInputAction: TextInputAction.next,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                                labelText: 'E-posta',
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: appBarBackgroundColor))),
                          ),
                        ],
                      ),
                    )
                  ],
                ),

              )
          )

        ],
      ),
    );
  }
}