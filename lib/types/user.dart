class PUser{
  final String uid;
   String name;
   String surname;
   String username;
   String email;

  PUser({this.uid,this.name,this.surname,this.email,this.username});



  PUser.fromJson(Map<String,dynamic> json):
      uid=json['uid'],
    name=json['name'],
    surname=json['surname'],
    email=json['email'],
    username=json['username'];



  Map<String,dynamic> toJson()=>{
    'uid':uid,
    'name':name,
    'surname':surname,
    'email':email,
    'username':username
  };

  PUser.fromPredixiJson(Map<String,dynamic> json):
        uid=json['id'],
        name=json['uFirstName'],
        surname=json['uLastName'],
        email=json['uMail'],
        username=json['uName'];
  @override
  bool operator ==(other) {
    return uid==other.uid;
  }
  @override
  int get hashCode => uid.hashCode;

  bool isValid() {
    if([null,""].contains(uid)){
      return false;
    }
    if([null,""].contains(name)){
      return false;
    }
    if([null,""].contains(surname)){
      return false;
    }
    if([null,""].contains(email)){
      return false;
    }
    if([null,""].contains(username)){
      return false;
    }
    return true;
  }

}