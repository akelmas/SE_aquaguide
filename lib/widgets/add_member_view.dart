import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:predixinote/types/user.dart';
import 'package:predixinote/widgets/user_card.dart';
class AddMemberView extends StatefulWidget {
  final List<PUser> memberList;
  final List<PUser> selection=new List<PUser>();
   AddMemberView({Key key, this.memberList}) : super(key: key);

  @override
  AddMemberViewState createState() => AddMemberViewState();
}

class AddMemberViewState extends State<AddMemberView> {
  String phrase;
  TextEditingController searchController = new TextEditingController();


  void update() {
    // TODO: implement dispose
    widget.selection.forEach((user){
      widget.memberList.add(user);
    });
    widget.selection.clear();
  }
  @override
  void dispose() {
    update();
    super.dispose();
  }

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
          if(userCount==widget.memberList.length)
            return Container(
              margin: EdgeInsets.all(10),
              child: const Text("Tüm kullanıcılar zaten eklendi"),
            );
          return ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: userCount,
            itemBuilder: (_, int index) {
try{
  final DocumentSnapshot document = snapshot.data.docs[index];
  final PUser user=PUser.fromJson(document.data());
  //place a zero-height widget instead of already added user
  if(!user.isValid()){
    return SizedBox(height: 0,);

  }
  if(widget.memberList.contains(user)){
    return SizedBox(height: 0,);
  }
  if (phrase != null) if (phrase.isNotEmpty) if (!("${user.name} ${user.surname}")
      .contains(phrase)) return SizedBox(height: 0);
  //user list will be implemented here
  int indexOfMember=widget.selection.indexOf(user);
  bool isSelected=indexOfMember>-1;
  return GestureDetector(

    child: UserCardBasic(user: user,isSelected: isSelected,),
    onTap: () {
      setState(() {
        if (isSelected) {
          widget.selection.removeAt(indexOfMember);
        } else {
          widget.selection.add(user);
        }

      });
    },
  );
}catch(e){
  print(e);
  return SizedBox(height: 0,);
}
            },
          );
        },
      ),
    );
  }
}
