import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:predixinote/types/plant.dart';
import 'package:predixinote/types/user.dart';
import 'package:predixinote/widgets/user_card.dart';
class AssignMemberView extends StatefulWidget {
  final Plant plant;

  const AssignMemberView({Key key, @required this.plant}) : super(key: key);

  @override
  AssignMemberViewState createState() => AssignMemberViewState();
}

class AssignMemberViewState extends State<AssignMemberView> {


  String phrase;
  TextEditingController searchController = new TextEditingController();
  PUser selected;
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Container(
      width: double.maxFinite,
      child: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("users").snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData)
            return const Text('Kullanıcı listesi alınıyor...');
          final int userCount = snapshot.data.docs.length;

          return ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: userCount,
            itemBuilder: (_, int index) {
              final DocumentSnapshot document = snapshot.data.docs[index];
              String uid = document.data()['uid'];
              String name = document.data()['name'];
              String surname = document.data()['surname'];
              final PUser user=PUser(uid: uid,name: name,surname: surname);
              //place a zero-height widget instead of already added user
              if (phrase != null) if (phrase.isNotEmpty) if (!("$name $surname".toUpperCase())
                  .contains(phrase.toUpperCase())) return SizedBox(height: 0);
              //user list will be implemented here

              bool isSelected=widget.plant.userId==uid;
              return GestureDetector(

                child: UserCardBasic(user: user,isSelected: isSelected,),
                onTap: (){
                  setState(() {
                   widget.plant.userId=uid;

                  });
                }
                ,
              );
            },
          );
        },
      ),
    );
  }
}
